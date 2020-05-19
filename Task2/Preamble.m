function [P]=Preamble(Np)

%Generate preamble as descrived in fig 2.2
%Np=100;

% Imput = ones
% Tap =[6 5 4]
state = ones(8,1);
P = ones(Np,1);
n = 1;
while n <= Np
    P(n, 1) = state(1,1);
    a1 = xor(state(1,1),state(3,1));
    a2 = xor(state(4,1), a1);
    a3 = xor(state(5,1), a2);
    state(1:7,1) = state(2:8,1);
    state(8,1) = a3;
    n = n+1;
end

P = P*-2 + ones(Np,1);

end
