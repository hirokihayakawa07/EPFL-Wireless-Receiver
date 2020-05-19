clear all
load image.mat
num_data = 1000000;

% Source: Generate random bits
txbits = randi([0 1],num_data,2);

% Call function to calculate BER
[PL,QPSK] = BER_Calc2(txbits,num_data);

% Comparing plots of noisy constellations
figure(1)
plot(txbits(:,1),txbits(:,2),"o");
hold on
plot(QPSK,"*");
hold off

% log scale plot SNR-BER
figure(2)
semilogy(PL(:,1),PL(:,2));
grid on
xlabel('SNR')
ylabel('BER')

