function rxbits = rx_flow(rx, conf, parallel_symbols_tx)
% received signals to a bitstream

% downconvertion
time = (0:length(rx) - 1);
time = time ./ conf.fsampling;
dc_signals = 2 * ofdmlowpass(rx .* exp(-1j*2*pi*conf.f_c*time.'), conf, conf.bw * 1.5);

% matched filtering with rrc for frame sync.
pulse = rrc(conf.os_factor, conf.rolloff, conf.filter_len);
filtered_temp = conv(dc_signals, pulse, 'same'); % only for frame sync.

% frame sync. to detect beginning of data
[idx, ~] = frame_sync(filtered_temp, conf.os_factor);
% extract transmitted symbols
extracted_symbols = dc_signals(idx : idx+(conf.nofdm + conf.ntraining)*(conf.nsubc + conf.lpfx)*conf.os_factor-1);

% group the received time symbols in corresponding OFDM symbols
parallel_symbols_rx = reshape(extracted_symbols, (conf.nsubc + conf.lpfx)*conf.os_factor, []);
% remove cyclic prefix
parallel_symbols_rx = parallel_symbols_rx(conf.lpfx*conf.os_factor+1:end, :);

% iterate over ofdm symbols and compute fft
p_rx_infreq = zeros(conf.nsubc, size(parallel_symbols_rx, 2));
% FFT and downsampling of the received signal
for i = 1:size(p_rx_infreq, 2)
    p_rx_infreq(:, i) = osfft(parallel_symbols_rx(:, i), conf.os_factor);
end

% estimate channels for each subcarrier
train = -2 * lfsr_framesync(conf.nsubc) + 1;
channel_training = p_rx_infreq(:, 1:conf.train_interval+1:end) ./ repmat(train, 1, conf.ntraining);

% estimate channels using all the transmitted symbols (debugging)
channel_others = p_rx_infreq ./ parallel_symbols_tx;

% channel compensation
compensated = p_rx_infreq;
[r, c] = size(p_rx_infreq);
theta_hat = zeros(r, c); % phase estimation
abs_hat = zeros(r, c); % abs estimation
tr = 1; % counting the number of training symbols
for init = 1:conf.train_interval + 1:c
    
    % update the channel estimation with the training symbols
    last = init + conf.train_interval;
    theta_hat(:, init) = mod(angle(channel_training(:, tr)), 2*pi);
    init_est = mod(angle(channel_training(:, tr)), 2*pi);
    abs_hat(:, init:last) = repmat(abs(channel_training(:, tr)), 1, last-init+1);
    tr = tr + 1;

    % phase tracking
    for slice = init + 1:last
        for i = 1:r
            deltaTheta = 1 / 4 * angle(-p_rx_infreq(i, slice)^4) + pi / 2 * (-1:4);
            % unroll phase
            [~, ind] = min(abs(deltaTheta-theta_hat(i, slice-1)));
            theta = deltaTheta(ind);
            % lowpass filter phase
            theta_hat(i, slice) = mod(0.2*theta+0.8*theta_hat(i, slice-1), 2*pi);
        end
        % for no tracking case
%         theta_hat(:, slice) = initial_est;
    end

    % compensate channel
    compensated(:, init:last) = p_rx_infreq(:, init:last) ./ abs_hat(:, init:last);
    compensated(:, init:last) = compensated(:, init:last) .* exp(-1j.*theta_hat(:, init:last));
    
    % for no tracking case
%     break
end

% create multiple plots
useful_plot(channel_training, channel_others, theta_hat, conf);

% remove training symbols
compensated(:, 1:conf.train_interval+1:end) = [];
% reshape paralell to vec
symbols_vec = compensated(:);
% demap symbols to bits
rxbits = [real(symbols_vec) > 0, imag(symbols_vec) > 0];
rxbits = reshape(rxbits', 2*length(symbols_vec), 1);

end