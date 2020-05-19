clear all
load image.mat

num_data = 1000000;
% Source: Generate random bits[:,2]
txbits = randi([0 1],num_data,2);

function BER_plot2(num_data)
    % Mapping to QPSK symbols in Fig.1.4
    txbits_1 = txbits(:,1)*-2 + ones(num_data,1);
    txbits_2 = 2*txbits_1.*txbits(:,2)-txbits_1.*ones(num_data,1);
    QPSK = complex(txbits_1,txbits_2)/sqrt(2);

    % Comparing plots of noisy constellations
    % plot(txbits(:,1),txbits(:,2),"o");
    % hold on
    % plot(QPSK,"*");
    % hold off

    SNR=-6;
    i = 1;
    while SNR <=12  

        QPSK_WN = awgn(QPSK,SNR);
        DECO = [cos(angle(QPSK_WN))./abs(cos(angle(QPSK_WN))),sin(angle(QPSK_WN))./abs(sin(angle(QPSK_WN)))];
        DECO21 = (DECO(:,1)-ones(num_data,1))*-0.5;
        DECO22 = 0.5*DECO(:,1).*(DECO(:,1)+DECO(:,2));
        DECO2 = [DECO21, DECO22];
        error = txbits - DECO2;
        BER = nnz(error)/num_data;
        P(i,1)=SNR;
        P(i,2)=BER;
        SNR = SNR + 2;
        i = i + 1;
    end
    semilogy(P(:,1),P(:,2));
end



%QPSK_WN = [awgn(QPSK,-6),awgn(QPSK,-4),awgn(QPSK,-2),awgn(QPSK,0),awgn(QPSK,2),awgn(QPSK,4),awgn(QPSK,6),awgn(QPSK,8),awgn(QPSK,10),awgn(QPSK,12)];
