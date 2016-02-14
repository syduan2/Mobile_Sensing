function  plot_3dscatter()
jump_data = csvread('../csv_data_3/Jumping_1455483776.000000.csv');
walk_data = csvread('../csv_data_3/Walking_1455483520.000000.csv');
run_data = csvread('../csv_data_3/Running_1455483648.000000.csv');
stairs_data = csvread('../csv_data_3/Stairs_1455483904.000000.csv');

[jmeans, jvar, jmax, jzeros] = stage_4 (jump_data)

for i = 1:size(jmeans, 1)
    hold on;
    scatter(jmeans(i), jvar(i), jzeros(i));
end
end

