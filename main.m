% 仿真名称
Sim.Name = 'Massive MIMO Linear Detection'; 

% 配置参数
Sim.ID = randi(100);
[Sim] = param(Sim);

% 仿真开始显示仿真参数配置
DisplayMessage('仿真参数设置如下：',1);
fprintf('仿真名称：%s\n',Sim.Name);
fprintf('仿真SNR范围：%4.1f (dB) -- %4.1f (dB)\n',Sim.SNR(1),Sim.SNR(end));
fprintf('仿真循环次数：%d\n',Sim.NumOfLoops);
fprintf('仿真比特数：%d\n',Sim.NumOfBits);
fprintf('检测简化算法：%s\n',Sim.DecScheme);
fprintf('检测对比算法：MMSE加权矩阵精确求逆\n');
DisplayMessage('MIMO系统参数设置如下：',1);
fprintf('调制阶数：%d\n',Sim.Modu);
fprintf('调制方式：%s\n',Sim.ModScheme);
fprintf('发射天线数目：%d\n',Sim.TxNum);
fprintf('接收天线数目：%d\n',Sim.RxNum);

DisplayMessage('仿真实时结果如下：',1);
%% 定义算法性能存储变量
 SimResultNumError.MMSE = zeros(Sim.TxNum+1,length(Sim.SNR));
 SimResultNumError.MMSE_Simplified = zeros(Sim.TxNum+1,length(Sim.SNR),length(Sim.iteration));
 
 SimResult.BER_MMSE = zeros(Sim.TxNum+1,length(Sim.SNR));
 SimResult.BER_MMSE_Simplified = zeros(Sim.TxNum+1,length(Sim.SNR),length(Sim.iteration));
 
 if Sim.Det>10
     SimResultNumError.MMSE_Simplified1 = zeros(Sim.TxNum+1,length(Sim.SNR),length(Sim.iteration));
     SimResult.BER_MMSE_Simplified1 = zeros(Sim.TxNum+1,length(Sim.SNR),length(Sim.iteration));
     
     SimResultNumError.MMSE_Simplified2 = zeros(Sim.TxNum+1,length(Sim.SNR),length(Sim.iteration));
     SimResult.BER_MMSE_Simplified2 = zeros(Sim.TxNum+1,length(Sim.SNR),length(Sim.iteration));
 end
 
%% MIMO链路代码部分
SNR_Index = 0;

for SNR = Sim.SNRStart:Sim.SNRStep:Sim.SNREnd
    
    SNR_Index = SNR_Index + 1;
  
  for LoopIndex = 1:Sim.NumOfLoops
      
       %%用户发送端
       [SourceBits,ModSym ] = Tx(Sim);
       Sim.SymLen = Sim.NumOfBits/Sim.Modu;%调制过后符号的长度
       % 生成信道矩阵
       Sim.ChannelMatrixH = complex(randn(Sim.RxNum,Sim.TxNum,Sim.SymLen),randn(Sim.RxNum,Sim.TxNum,Sim.SymLen));  
       %定义接收信号储存变量
       ReceivedSignal = zeros(Sim.RxNum,Sim.SymLen);  
       Sim.SingnalPWR=Sim.TxNum;
       Sim.NoisePWR = sqrt(Sim.SingnalPWR*0.5/(10^(SNR/10)));  % 仿真中的AWGN噪声功率，用于产生随机噪声变量。
       sigma=Sim.NoisePWR;
       % 发射信号过信道加噪声
       for i = 1:Sim.SymLen
          CurrentH = Sim.ChannelMatrixH(:,:,i);
          ReceivedSignal(:,i) = CurrentH*ModSym(:,i) + Sim.NoisePWR * complex(randn(Sim.RxNum,1),randn(Sim.RxNum,1));
       end

       %% MIMO接收机端(信号接收、检测、解调) 先根据检测到的数据计算误码数，在再计算误码率
        
       [ReceiveBits] = Rx(Sim,ReceivedSignal,SNR);

       %% MIMO接收端，差错bit评估,并实时显示 %%先根据检测到的数据计算误码数，在再计算误码率
       [SimResultNumError] = Checkbits(Sim,SourceBits,ReceiveBits,SNR_Index,SNR,LoopIndex,SimResultNumError);

  end %% for LoopIndex

       %% 计算每个SNR下BER
       [SimResult] = BER_Compu(Sim,SNR_Index,SimResult,SimResultNumError);
end % % for SNR

%% 结果图形显示
Result_plot;
%Result_plot2;
%仿真时长统计
disp(['仿真消耗时间：' num2str(toc) '秒，约' num2str(toc/3600) ' 小时']);

%% 保存当前仿真参数配置下的结果数据，待今后调用
savefileName = ['Results_SimID_' num2str(Sim.ID) '_' num2str(Sim.TxNum) 'x' num2str(Sim.RxNum) '_' Sim.ModScheme  '_' datestr(now,30)];
save(savefileName);
