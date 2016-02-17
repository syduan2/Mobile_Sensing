function  plot_3dscatter()
jump_data = csvread('../data/jumping.csv');
walk_data = csvread('../data/walking.csv');
run_data = csvread('../data/running.csv');
stairs_data = csvread('../data/stairs.csv');

[jmeans, jvar, jmax, jzeros] = stage_4 (jump_data);
[smeans, svar, smax, szeros] = stage_4 (stairs_data);
[wmeans, wvar, wmax, wzeros] = stage_4 (walk_data);
[rmeans, rvar, rmax, rzeros] = stage_4 (run_data);

figure;
for i = 2:size(jmeans, 1)
    scatter3(jmeans(i, 8), jvar(i, 9), jvar(i, 3),'MarkerEdgeColor', 'red');
    hold on;
    scatter3(wmeans(i, 8), wvar(i, 9), jvar(i, 3),'MarkerEdgeColor', 'blue');
    scatter3(smeans(i, 8), svar(i, 9), svar(i, 3),'MarkerEdgeColor', 'green');
    scatter3(rmeans(i, 8), rvar(i, 9), rvar(i, 3),'MarkerEdgeColor', 'black');
    
end
end

