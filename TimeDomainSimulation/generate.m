%%未完成

clear;
clc;
%%initialize PSAT and datafile.
dataFile='dataIEEE39'; %系统数据文件
initpsat;
%initLog(['log-',dataFile,'-',datestr(clock,30),'.txt'],1000,'apparent');
clpsat.readfile=0;
clpsat.mesg=0;
runpsat(dataFile,'data');
%%
%%modify operation condition and do power flow
runpsat('pf');
flag=1;

Settings.tf=4;%仿真时间为4s
Settings.fixt=1;%定步长计算
Settings.tstep=0.005;%选择步长为0.005s

casenum=2;%i1*i2*i3 这是一个database文件里的样本数
idx = 0;
for CT = 0.2:0.005:0.8%
    
    filename=strcat('database',num2str(flag));
    
    runpsat('pf');
    runpsat('td');
    
    
    for i2=1:35  %对35条线路做循环，每一条线路的两端母线三相短路后该线路被切除
        Breaker.store(1)=i2;%设置故障线路
        Breaker.store(3:4)=Line.con(i2,3:4);
        for i3=1:2  %对两端母线分别做短路
            faulttype=(i2-1)*2+i3;
            Fault.store(1)=Line.con(i2,i3);%故障时的母线
            Breaker.store(2)=Line.con(i2,i3);
            Breaker.store(7)=CT;
            Fault.store(5)=0.1;
            Fault.store(2:3)=Line.con(i2,3:4);%
            Fault.store(6)=CT;%故障时间储存
            
            caseindex=2*(i2-1)+i3;
            
            runpsat('pf'); %算潮流
            
            indexGen=[31 30 32 33 34 35 36 37 38 39];%发电机的序号
            indexLoad=[3,4,7,8,12,15,16,18,20,21,23,24,25,26,27,28,29,31,39];%负荷的序号
            indexOmega=Syn.omega;
            
            StateVariable=1:1:DAE.n;%状态变量
            VoltageAngles=(DAE.n+1):(DAE.n+Bus.n);%节点电压幅值
            VoltageMagnitudes=(DAE.n+Bus.n+1):(DAE.n+2*Bus.n);%节点电压相角
            %=========================================================================%
            
            %输出的排列顺序为：发电机的转子角、母线电压、母线相角
            %指定的时候应该用列向量
            Varname.fixed=0;

            Varname.idx=[StateVariable(Syn.delta),VoltageMagnitudes,VoltageAngles];
        
            runpsat('td');%暂态计算开始

            %判断样本是否稳定
            theta_final=Varout.vars(end,1:10);%发电机功角的终值

            deltatheta = [];
            for i = 1:10
                for j = 1:10
                    deltatheta(end+1)=theta_final(i)-theta_final(j);
                end
            end
            
            if Varout.t(end)>3.8
                if sum(abs(deltatheta)>6.28)>0
                    isStable=-1;
                    disp([num2str(idx),' unstable'])
                    dlmwrite(strcat('./data_unstable/',num2str(CT),'_',num2str(i2),'_',num2str(i3)),[Varout.vars],'delimiter',',');
                else
                    isStable=1;
                    disp([num2str(idx),' stable'])
                    dlmwrite(strcat('./data_stable/',num2str(CT),'_',num2str(i2),'_',num2str(i3)),[Varout.vars],'delimiter',',');
                end
            end
            idx = idx + 1;
        end
    end
end
