clear
%profile on

% Define value of Np
Np=100;

% Call function to generate preamble
[P] = Preamble(Np);

%load signal file
load task2
signal_size = size(signal);
SNR = 0;
n = Np;
C = 0;
gamma = 10;
% The decision threshold gamma in eq2.2 = 10
    % If no white noise is added, eq2.2 is 100, where Np =100.
    % Even if white noise is added, eq2.2 would be the value close to 100
    % In case that r[n] does not include preamble, the value of denominator is less than 10 for any SNR in [-15,10] 

% Calculate denominator untill the value become larger than the decision
% threshold gamma.
% Store the number of interation n and n note the position of the end ot
% the preamble in r.

while n < 10^6
    [Cn,C] = Correlator(n, Np, P, signal);
    if C > gamma
        break
    end
    n = n + 1;

end

% Call function demapper
% n is the position of the end of the preamble in r.
% n+1 means the beginning of the signal.
[b] = demapper(signal(n+1:signal_size,1));
size_b = size(b);

% Call function image_decoder
image_decoder(b, image_size);

% profile viewer
% profsave
% If we pick a very low threshold value such as 1, most part of the shown image is
% just noise and only some characteristic part, Sydney Opera House, remains.
% Iterative calculation of the denominator takes the most of time in this
% code.