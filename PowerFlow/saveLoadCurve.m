save_bus = zeros(total,39*2);
for i = 1:total
    save_bus(i,:) = reshape(squeeze(rst(i,:,1:2)),1,39*2);
end

save_load = zeros(total,2);

for i = 1:total
    save_load(i,1) = load_central(i);
    save_load(i,2) = load_curve(i);
end

csvwrite('bus.csv',save_bus);
csvwrite('load.csv',save_load);