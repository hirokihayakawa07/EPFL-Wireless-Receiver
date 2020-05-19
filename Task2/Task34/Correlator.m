function [Cn,De]=Correlator(n, Np, P, signal_WGN)
%Function to calculate denominator De
k1=n-(Np-1);
% P1=P;
% P2=signal_WGN(k1:n,1);
Cn = P.' * signal_WGN(k1:n,1);
De = abs(Cn)^2 / (abs(signal_WGN(k1:n,1)).'*abs(signal_WGN(k1:n,1)));

end