clear

load task3
SNR                 = 10;
tx_filterlen        = 41;
os_factor           = 4;
alpha = 0.22;

num_data = 10000;
% random bits 0 or 1
txbits = randi([0 1],1,num_data);

% QPSK symbol diracs
QPSK = 2*txbits - 1;
QPSK_symbol = zeros(1, os_factor * num_data/2);
QPSK_symbol(1:os_factor:end) = complex(QPSK(1:2:end),QPSK(2:2:end)) / sqrt(2);

% g_rrc
g_rrc = rrc(os_factor, alpha, tx_filterlen);

% sigma a * g_rrc 
signal = conv(QPSK_symbol, g_rrc.','full');

% convert SNR from dB to linear
SNRlin = 10^(SNR/10);

% add AWGN
rx_signal = signal + sqrt(1/(2*SNRlin)) * (randn(size(signal)) + 1i*randn(size(signal)) );

% calculate BER
j = 1;
for i=1:5:tx_filterlen
    g_rrc_rx = rrc(os_factor, alpha, i);
    z = conv(rx_signal,g_rrc_rx.','full');
    temp = z(1 + tx_filterlen + i : os_factor : end - tx_filterlen - i);
    temp_decoded = demapper(temp);
    BER(j) = sum(txbits ~= temp_decoded.')/num_data;
    len(j) = i;
    j = j+1;
end

% log scale plot rxlen-BER
figure
semilogy(len,BER);
xlabel('Filter-length');
ylabel('BER');
