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

Settings.tf=4;%仿真时间为4s
Settings.fixt=1;%定步长计算
Settings.tstep=0.005;%选择步长为0.005s

idx = 0;
for cutTime = 0.2:0.005:0.8%
    runpsat('pf');
    runpsat('td');
    
    
    for breakLine=1:35  %对35条线路做循环，每一条线路的两端母线三相短路后该线路被切除
        Breaker.store(1)=breakLine;%设置故障线路
        Breaker.store(3:4)=Line.con(breakLine,3:4);
        for leftOrRight=1:2  %对两端母线分别做短路
            faulttype=(breakLine-1)*2+leftOrRight;
            Fault.store(1)=Line.con(breakLine,leftOrRight);%故障时的母线
            Breaker.store(2)=Line.con(breakLine,leftOrRight);
            Breaker.store(7)=cutTime;
            Fault.store(5)=0.1;
            Fault.store(2:3)=Line.con(breakLine,3:4);%
            Fault.store(6)=cutTime;%故障时间储存
            
            caseindex=2*(breakLine-1)+leftOrRight;
            
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

            isStable = 1;

            for i = 1:10
                for j = i+1:10
                    if abs(theta_final(i) - theta_final(j)) > 6.28
                        isStable = 0
                    end
                end
            end
            
            if Varout.t(end)>3.8
                if isStable == 0
                    disp([num2str(idx),' unstable'])
                    dlmwrite(strcat('./data_unstable/',num2str(cutTime),'_',num2str(breakLine),'_',num2str(leftOrRight)),[Varout.vars],'delimiter',',');
                else
                    disp([num2str(idx),' stable'])
                    dlmwrite(strcat('./data_stable/',num2str(cutTime),'_',num2str(breakLine),'_',num2str(leftOrRight)),[Varout.vars],'delimiter',',');
                end
            end
            idx = idx + 1;
        end
    end
end
