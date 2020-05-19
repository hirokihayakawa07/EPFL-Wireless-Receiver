function ex3_3_2_demodpulse
% ex3_3_2 - Task 3.3.2
%    Demodulate root raised cosine shaped pulses
%    
% 
% Author(s): Nicholas Preyss
% Copyright (c) 2012 TCL.
% 

SNR           = 10;
rx_filterlen  = 12; % length of receive filter
os_factor     = 4;  % oversampling factor
alpha = 0.22; % rolloff_factor

% load shaped symbols
load ./task3.mat
data_length = prod(image_size) * 8 / 2;

% convert SNR from dB to linear
SNRlin = 10^(SNR/10);

% add awgn channel
rx_signal = signal + sqrt(1/(2*SNRlin)) * (randn(size(signal)) + 1i*randn(size(signal)) );

% apply matched filter
g_rrc = rrc(os_factor, alpha, rx_filterlen);
z_len = length(rx_signal) - 2*rx_filterlen;
z = zeros(1, z_len);
for i=1:length(z)
    z(i) = rx_signal(i:i+2*rx_filterlen).' * g_rrc;
end

% find start of data frame
beginning_of_data = frame_sync(z.', os_factor); % Index of the first data symbol

% decode image
image_decoder(demapper(z(beginning_of_data : os_factor : beginning_of_data + os_factor * (data_length - 1))), image_size);