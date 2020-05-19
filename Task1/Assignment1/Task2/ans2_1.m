clear all
load image.mat
num_data = 1000000;

% Source: Generate random bits
txbits = randi([0 1],num_data,2);

% Call function to calculate BER (Fig.14)
[PL,QPSK] = BER_Calc(txbits,num_data);
% Call function to calculate BER (Fig.16)
[PL2,QPSK] = BER_Calc2(txbits,num_data);

% Comparing plots of noisy constellations
figure(1)
plot(txbits(:,1),txbits(:,2),"o");
hold on
plot(QPSK,"*");
hold off

% log scale plot SNR-BER
figure(2)
semilogy(PL(:,1),PL(:,2));
hold on
semilogy(PL2(:,1),PL2(:,2),'*');
hold off
grid on
xlabel('SNR')
ylabel('BER')
legend('fig.14','fig.16')


% Comparing BER plots generated from the two mapping schemes, we found
% the mapping scheme shown in Fig 1.4 generates smaller BER.
% In the mapping scheme shown in Fig 1.6, value of 1st bit is used to
% decode 2nd bid, which means noise on the 1st bit affect the 2nd bit and
% worsen the error rate of the decoded signal.


