
function [Sim] = param(Sim)

% 配置参数
Sim.NumOfBits = 2^10;

% 每个SNR点下的循环仿真总次数
Sim.NumOfLoops=1;

% SNR定义SNR
Sim.SNRStep  = 1;
Sim.SNRStart = 0;
Sim.SNREnd   = 10;
Sim.SNR = Sim.SNRStart:Sim.SNRStep:Sim.SNREnd;

%设置迭代次数或纽曼级数展开项数
Sim.iteration_min=2;
Sim.iteration_max=4;
Sim.iteration=Sim.iteration_min:Sim.iteration_max;

% MIMO系统配置参数，因为基站天线要远大于用户，这里设置如下。
Sim.TxNum = 16;
Sim.RxNum = 64;

% MIMO系统调制参数：1-BPSK，2-QPSK，4-16QAM，6-64QAM
Sim.Modu = 4; % 16QAM
Sim.Constellation = ConstellationGen(Sim);
switch Sim.Modu
    case 1, Sim.ModScheme = 'BPSK';
    case 2, Sim.ModScheme = 'QPSK';
    case 4, Sim.ModScheme = '16QAM';
    case 6, Sim.ModScheme = '64QAM';
end
% MIMO系统上行接收端检测算法：1-Conjugate gradient,2-Gauss-Seidel,3-Neumann series,4-Richardson method
Sim.Det =89
switch Sim.Det
    
    case 89
        Sim.DecScheme= 'Neumann-AOR-SAOR';
        
end
  
return
  
