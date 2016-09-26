# Synthetic-Power-Grid-Data  

使用MatPower和PSAT模块生成电力仿真数据，包括静态潮流数据和暂态时域仿真数据。

This project focuses on generating synthetic power grid data using matlab. 

PowerFlow module can generate a quadratic load curve and the bus voltages and angles with respect to. Modify the variables in genLoadCurve to control the simulation parameters. Matpower is required to run this module.

TimeDomainSimulation can generate timeseris of varies situations. It is helpful for machine learning purpose. Current implementation simulates the circumstances of short circuiting a random transmission line and then restore it after a random period. If the short circuit made the power grid unstable(by checking the generator angles), the simulation result would fall into the 'unstable' sub folder, Otherwise, into the 'stable' folder. 

## 参考文献
[1] 王亚俊, 王波, 唐飞,等. 基于响应轨迹和核心向量机的电力系统在线暂态稳定评估[J]. 中国电机工程学报, 2014(19):3178-3186.