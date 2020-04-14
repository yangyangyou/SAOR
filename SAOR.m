function rx_SAORMMSE = SAORMMSE_Detector(y,H,Sim,SNR,iteration)
W = H'*H +(1/10^(SNR/10))*eye(Sim.TxNum,Sim.TxNum);
D = diag(diag(W));
L = tril(W)-D;
a = (1+sqrt(Sim.TxNum/Sim.RxNum))^2-1;
w = 2/(1+sqrt(1-a^2));
r=1.25;
D_1 = inv(D);
DL_1 = inv(D+w*L);
DLH_1 = inv(D+w*L');
b = H'*y;
s0 =D_1*b;
rx_SAORMMSE = s0;
%rx_SAORMMSE = DL_1*((1-w)*D*rx_SAORMMSE-(w-r)*L*rx_SAORMMSE-w*L'*rx_SAORMMSE+w*b);

for t=2:1:iteration
rx_SAORMMSE = DL_1*((1-r)*D*rx_SAORMMSE-r*L'*rx_SAORMMSE-(r-w)*L*rx_SAORMMSE+r*b);
rx_SAORMMSE = DLH_1*((1-r)*D*rx_SAORMMSE-(r-w)*L'*rx_SAORMMSE-w*L*rx_SAORMMSE+r*b);

end

end
