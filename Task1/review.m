clear all;

load image
SNR = -6:2:12;
BER = zeros(size(SNR));
BER2 = zeros(size(SNR));
% SNRlin = 10^(0.1*SNR);
% %Add AWGN
% noise_signal = signal + sqrt(1/(2*SNRlin))*(randn(size(signal)) + 1i*randn(size(signal)));

% a= noise_signal;
% b = [real(a) imag(a)] >0;
% 
% % Convert the matrix "b" to a vector, reading the elements of "b" rowwise.
% b = b.';
% b = b(:);
% 
% b = double(b);
% 
% % Display image
% image_decoder(b,image_size);

% cos_plot = [real(noise_signal), imag(noise_signal)];
% plot(cos_plot);
% plot(noise_signal, '.');

num_data = 1000000;
% Source: Generate random bits

bits = randi([0 1], num_data,1);
bits2 = zeros(num_data/2 ,2);
bits2(:,1) = bits(1:2:num_data);
bits2(:,2) = bits(2:2:num_data);
i = 1;
while i < length(SNR)+1
    SNRlin = 10^(0.1*SNR(1,i));
    QPSK = 2*bits2 -1;
    QPSK = sqrt(1/2)*(QPSK(:,1) + 1i*QPSK(:,2));
    QPSK_noise = QPSK + sqrt(1/(2*SNRlin))*(randn(size(QPSK))+ 1i*randn(size(QPSK)));
    aa = QPSK_noise;
    bb = [real(aa) imag(aa)] >0;
    bb = bb.';
    bb = bb(:);
    err = nnz(bits - bb)/num_data;
    BER(1,i) = err;
    i = i + 1;
end
i = 1;
while i < length(SNR)+1
    SNRlin = 10^(0.1*SNR(1,i));
    QPSK2 = 2*bits2 -1;
    QPSK2 = sqrt(1/2)*(QPSK2(:,1) + 1i*QPSK2(:,2));
    QPSK2_noise = QPSK2 + sqrt(1/(2*SNRlin))*(randn(size(QPSK2))+ 1i*randn(size(QPSK2)));
    aa = QPSK2_noise;
    bb = [real(aa) imag(aa)] >0;
    bb = bb.';
    bb = bb(:);
    err = nnz(bits - bb)/num_data;
    BER2(1,i) = err;
    i = i + 1;
end


semilogy(SNR, BER, 'bx-' ,'LineWidth',3); hold on
semilogy(SNR, BER2, 'bx-' ,'LineWidth',3); 
xlabel('SNR (dB)')
ylabel('BER')
legend('Gray Mappig')
grid on