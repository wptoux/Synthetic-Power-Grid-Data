This project focuses on generating synthetic power grid data using matlab. 

PowerFlow module can generate a quadratic load curve and the bus voltages and angles with respect to. Modify the variables in genLoadCurve to control the simulation parameters. Matpower is required to run this module.

TimeDomainSimulation can generate timeseris of varies situations. It is helpful for machine learning purpose. Current implementation simulates the circumstances of short circuiting a random transmission line and then restore it after a random period. If the short circuit made the power grid unstable(by checking the generator angles), the simulation result would fall into the 'unstable' sub folder, Otherwise, into the 'stable' folder. 