clear all
% Start time measurement
tic();

% Source: Generate random bits
txbits = randi([0 1],1000000,1);

% Mapping: Bits to symbols
% 0-->-1, 1-->1
txbits_MP = 2*txbits - 1;

% Channel: Apply BSC
% Generate vector randval where randval(i)= -1 if rand < 0.2, else randval(i)=1
randval = rand(1000000,1) - ones(1000000,1)*0.2;
randval = ceil(randval);
randval = randval*2 - ones(1000000,1);

% multiplying corresponing elements of randval and Mapped bits, if rand<0.2 corresponding bits will be switched 
rxbits = randval.* txbits_MP;
rxbits2 = (rxbits + ones(1000000,1) )*0.5; 

%error count
error = nnz(txbits - rxbits2);
% % Output result
disp(['BER: ' num2str(error/1000000*100) '%'])

% Stop time measurement
toc()
