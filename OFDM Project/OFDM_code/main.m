clearvars
close all
rng(77);

%% SYSTEM CONFIGURATION
% OFDM system
conf.nsubc = 1600; % # of subcarriers N
conf.f_c = 8000; % carrier frequency
conf.fspacing = 5; % spacing 1/T
conf.fsampling = 48000; % sampling frequency
conf.lpfx = 400; % length of cyclic prefix

conf.npreamble = 100; % number of preamble symbols
conf.rolloff = 0.22; % rolloff factor

conf.use_image = true; % true=image transmission, false = random bit transmission

% audio system
conf.audiosystem = 'matlab'; % values: 'matlab','native','bypass'
conf.nframes = 1; % number of frames to transmit
conf.bitsps = 16; % bits per audio sample
conf.offset = 0; % frequency offset at the down conversion

%% BITS GENERATOR
if conf.use_image
    % read the image and extract bitstream
    imag = imread('freddie.png');
    [imam_rows, imag_cols, ~] = size(imag);
    rawbits = de2bi(imag, 8).';
    rawbits = rawbits(:);
else
    % transmit just bits instead
    nofdm = 1;
    rawbits = randi([0, 1], nofdm * conf.nsubc * 2, 1);
end

% update system configuration
conf.ndata = length(rawbits);
conf.nofdm = ceil(conf.ndata / (2 * conf.nsubc));

% preprocess bits
[txbits, conf] = preprocessing(rawbits, conf);
nofdm_div = divisors(conf.nofdm);

%% SYSTEM CONFIGURATION (DEPENDENT)
% all calculation that you only have to do once
conf.os_factor = conf.fsampling / (conf.fspacing * conf.nsubc);
conf.nbits = length(txbits);
conf.nsyms = conf.nbits / 2;
conf.train_interval = nofdm_div(end - 2); % Only train once in the beginning
conf.ntraining = (conf.nofdm / conf.train_interval);
conf.bw = conf.fspacing* ceil((conf.nsubc + 1) / 2);
if mod(conf.os_factor, 1) ~= 0
   disp('WARNING: Sampling rate must be a multiple of the symbol rate'); 
end
conf.filter_len = 10 * conf.os_factor; % number of filter taps (can be changed)

%% TRANSMITTER
[txsignal, parallel_symbols] = tx_flow(txbits, conf);

% plot received signal for debgging
% fig = figure;
% plot(tx);
% title('Transmitted Audio')
% saveas(fig, 'Transmitted audio.png');

%% AUDIO TRANSMISSION / BYPASS
[rxsignal, conf] = audio_transmission(txsignal, conf, 6);

%% RECEIVER
rxbits = rx_flow(rxsignal, conf, parallel_symbols);
rawrxbits = xor(rxbits(1:conf.ndata), lfsr_framesync(conf.ndata)); % derandomize

%% BITS REGENERATOR and EVALUATE PERFORMANCES
% reconstruct transmitted image
if conf.use_image
    rawrxbits2 = reshape(rawrxbits, 8, []).';
    img = uint8(bi2de(rawrxbits2));
    img = reshape(img, imam_rows, imag_cols);
    im_fig = figure;
    imshow(img);
    imwrite(img, 'freddie_received.png');
end
% BER calculation
disp(['BER on the received bits: ', num2str(mean(rxbits ~= txbits))]);
disp(['BER on the derandmized bits: ', num2str(mean(rawrxbits ~= rawbits))]);
