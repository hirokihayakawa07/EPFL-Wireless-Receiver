clear
A = [3,3;-3,3;-3,-3;3,-3];
PA_av =18;
A_n = A/sqrt(PA_av);

B=[3,0;0,3;-3,0;0,-3;6,6;-6,-6];
PB_av = 30;
B_n = B/sqrt(PB_av);

plot(A_n(:,1),A_n(:,2),'o','color','red');
hold on
plot(B_n(:,1),B_n(:,2),'o','color','blue');
hold off
grid on
xlabel('Real')
ylabel('Imag')
%
