function [PL,QPSK]=BER_Calc(txbits, num_data)
    % Mapping to QPSK symbols(in fig 1.4)
    % [11,01,00,10] -->[11,-11,-1-1,1-1]
    txbits_2 = txbits*2 - ones(num_data,2);
    QPSK = complex(txbits_2(:,1),txbits_2(:,2))/sqrt(2);

    SNR=-6;
    i = 1;
    while SNR <=12  
        
        % Add AWGN to QPSK signal
        Noised_Signal = awgn(QPSK,SNR);
        
        % Noised signal to QPSK (Angle = theta)
        % (x1,x2), x1=cos(theta)/|cos(theta)|, x2=sin(theta)/|sin(theta)|
            % theta in (0,pi/2) --> 11
            % theta in (pi/2,pi) --> -11
            % theta in (pi,3/2pi) --> -1-1
            % theta in (3/2pi,2pi) --> 1-1
        QPSK_WN = [cos(angle(Noised_Signal))./abs(cos(angle(Noised_Signal))),sin(angle(Noised_Signal))./abs(sin(angle(Noised_Signal)))];
        
        % QPSK signal to bits: [11,-11,-1-1,1-1] --> [11,01,00,10]
        rxbits = (QPSK_WN+ones(num_data,2))*0.5;
        
        % Error count
        error = nnz(txbits - rxbits);
        BER = error/num_data;
        
        % Record SNR and Correspondet BER
        PL(i,1)=SNR;
        PL(i,2)=BER;
        
        % Repeat with other SNR
        SNR = SNR + 2;
        i = i + 1;
    end
end
