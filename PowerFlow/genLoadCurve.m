define_constants;
timedelta = 30;
total = 3600 / timedelta * 5;
rst = zeros(total,39,6);
load_curve = zeros(1,total);
base = loadcase(case39);
jacs = zeros(total,78,78);
a = -4/total^2;
b = 4/total;

theta = 0.01;
sigma = 0.005;
dt = timedelta;
rng(9);

load_central = zeros(1,total);
for i = 1:total
    load_central(i) = a * i^2 + b * i + 1;
end

load_curve(1) = load_central(1);
%Ornstein Uhlenbeck process
for i = 1:total - 1
    load_curve(i + 1) = load_curve(i) + load_central(i+1) - load_central(i) + ...
        theta * (load_central(i) - load_curve(i)) * dt + sigma * sqrt(dt) * randn();
end

% plot(load_central);
% pause;
% plot(load_curve);
op = base;
for i = 1:total
    pop = op;
    op = base;
    op.gen(:, [PG QG]) = op.gen(:, [PG QG]) * load_curve(i);% increased generation
    op.bus(:, [PD QD]) = op.bus(:, [PD QD]) * load_curve(i); % and increased load
    result = runpf(op,mpoption('verbose',0,'out.all',0));
    rst(i,:,1) = result.bus(:,VM);
    rst(i,:,2) = result.bus(:,VA);
    if mod(i,100) == 0
        disp(i);
    end
end
