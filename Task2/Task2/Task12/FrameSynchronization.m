clear
% Define value of Np
Np=100;

% Call function to generate preamble
[P] = Preamble(Np);

%load signal file and add Gaussian noise for a given SNR value
load task2

SNR = -5;
n = Np+100;
i = 1;
A = zeros(16,2);% to store caluculated value of denominator

% Add Gaussian noise for a given SNR value
signal_WGN = awgn(signal,SNR);

% Caluculate denominator in eq2.2
while SNR <= 10
    [Cn,De] = Correlator(n, Np, P, signal_WGN);
    A(i,1)= SNR;
    A(i,2)= De;
    SNR = SNR+1;
    i = i + 1;
end

plot(A(:,1),A(:,2));
xlabel('SNR')
ylabel('Denominator')

% The decision threshold gamma in eq2.2 = 10
    % If no white noise is added, eq2.2 is 100, where Np =100.
    % Even if white noise is added, eq2.2 would be the value close to 100
    % In case that r[n] does not include preamble, the value of denominator is less than 10 for any SNR in [-15,10] 