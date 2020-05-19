clear all
% close all
clc

% Set parameters
os_factor = 4;
SNR  = 10;

load ber_pn_seq
load pn_sequence

data_length = length(ber_pn_seq)/2; % Number of QPSK data symbols

% convert SNR from dB to linear
SNRlin = 10^(SNR/10);

% add awgn channel
rx_signal = signal + sqrt(1/(2*SNRlin)) * (randn(size(signal)) + 1i*randn(size(signal)) );

% Matched filter
filtered_rx_signal = matched_filter(rx_signal, os_factor, 6);

% Frame synchronization
data_idx = frame_sync(filtered_rx_signal, os_factor); % Index of the first data symbol

data = zeros(1,data_length);
data2 = zeros(1,data_length);

cum_err = 0;
diff_err = zeros(1,data_length);
epsilon  = zeros(1,data_length);

frame_sync_length = 100;

% Use preamble symbols to improve timing offset estimation (Task 3)
for ii = floor(data_idx/os_factor)-frame_sync_length:floor(data_idx/os_factor)-1
    
    idx_start  = ii*os_factor;
     
    idx_range  = idx_start:idx_start+os_factor-1;
    segment    = filtered_rx_signal(idx_range);
    
    % Estimate timing error epsilon
    pwr         = abs(segment).^2;
    diff_err = [1 -1j -1 1j]*pwr;
    cum_err     = cum_err + diff_err;
    
end

for ii=1:data_length
    
     idx_start  = data_idx+(ii-1)*os_factor;
     
     idx_range  = idx_start:idx_start+os_factor-1;
     segment    = filtered_rx_signal(idx_range);
    
     % Estimate timing error epsilon
     pwr         = abs(segment).^2;
     diff_err(ii) = [1 -1j -1 1j]*pwr;
     cum_err     = cum_err + diff_err(ii);
     epsilon(ii)  = -1/(2*pi)*angle(cum_err);
     
     % Interpolate
     sample_diff   = floor(epsilon(ii)*os_factor); % integer
     int_diff      = mod(epsilon(ii)*os_factor,1); % interval [0 1)
    
     
     % linear
     y     = filtered_rx_signal(idx_start+sample_diff:idx_start+sample_diff+1);
     y_hat = y(1)+int_diff*(y(2)-y(1));
     data(ii) = y_hat;
     
     % cubic
     y2     = filtered_rx_signal(idx_start+sample_diff-1:idx_start+sample_diff+2);
     y_hat2 = cubic_interpolator(y2,int_diff);
     data2(ii) = y_hat2;     


end

BER_lin = mean(demapper(data) ~= ber_pn_seq)
BER_cub = mean(demapper(data2) ~= ber_pn_seq)


% Plot epsilon
figure;
plot(1:data_length, epsilon)
% plot(1:1000, epsilon(1:1000))


% figure;
% semilogy(BER_lin);
% xlabel('Filter-length');
% ylabel('BER linear');
