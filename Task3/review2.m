clear all

SNR                 = 10;
rx_filterlen_array  = [2 5 7 10 15 20];
tx_filterlen        = 20; % tx_filterlen > rx_filterlen
os_factor           = 4; % oversampling factor

len = 10^5;
bitstream = randi([0 1], 1,len);
% Convert to QPSK symbol diracs
symbol1d            = 2*(bitstream-0.5);
symbol2s            = zeros(1,os_factor*(len/2));
symbol2s(1:os_factor:end)   = 1/sqrt(2)*(symbol1d(1:2:end) + 1i*symbol1d(2:2:end));

% Create RRC pulse 
rolloff_factor = 0.22;
pulse = rrc(os_factor, rolloff_factor, tx_filterlen);

% Shape the symbol diracs with pulse
signal = conv(symbol2s,pulse.','full');

% convert SNR from dB to linear
SNRlin = 10^(SNR/10);

% add AWGN
rx_signal = signal + sqrt(1/(2*SNRlin)) * (randn(size(signal)) + 1i*randn(size(signal))); 

% Simulate BER for each RX filter length
for i=1:length(rx_filterlen_array)
    rx_filterlen = rx_filterlen_array(i);
    
    pulse_rx = rrc(os_factor, rolloff_factor, rx_filterlen);
    
    filtered_rx_signal = conv(rx_signal,pulse_rx.','full');

    sampled_signal = filtered_rx_signal(1+tx_filterlen+rx_filterlen:os_factor:end-tx_filterlen-rx_filterlen);

    decoded_bits = demapper(sampled_signal);

    ber(i) = sum(bitstream ~= decoded_bits.')/len;
end

% Plot results
figure
semilogy(rx_filterlen_array,ber);
xlabel('Filter-length');
ylabel('BER');

