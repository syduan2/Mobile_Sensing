data = csvread('CSL_Building_1457222144.csv');
[x, y] = size(data);
x_vals = 1:x;

direction = cumsum(data(:, 6));
compass = zeros(x, 1);
true = zeros(x,1);

true(1:1000) = 0
true(1001:2000) = 90;
true(2001:4000) = 180;
true(4001:6000) = 90;
true(6001:7800) = 270;
true(7801:8000) = 180;
true(8001:9400) = 270;
true(9401:9600) = 0;
true(9601: 12000) = 270;
true(12001:13000) = 180;
true(13001: 15000) = 90;
true(15001: 16500) = 0;
true(16501: 17000) = 90;
true(17001:end) = 180;

cumulative_adjust = 0;
cumulative_adjust_comp = 0;
for i = 1:x
    if  direction(i) + cumulative_adjust > 360
       cumulative_adjust = cumulative_adjust - 360;
    end
    if direction(i) + cumulative_adjust < 0
       cumulative_adjust = cumulative_adjust + 360;
    end
    direction(i) = direction(i) + cumulative_adjust;
    
    if data(i, 1) > 0
        compass(i) = radtodeg(atan(data(i,2) / data(i, 1)));
    else
        compass(i) = radtodeg(atan(data(i,2) / data(i, 1))) + 180;
    end
    if  compass(i) + cumulative_adjust_comp > 360
       cumulative_adjust_comp = cumulative_adjust_comp - 360;
    end
    if compass(i) + cumulative_adjust_comp < 0
       cumulative_adjust_comp = cumulative_adjust_comp + 360;
    end
    compass(i) = compass(i) + cumulative_adjust_comp;
end

figure

hold on;
%plot(x_vals, direction);
plot(x_vals, compass);
plot(x_vals, true);
axis([0, x, 0, 360]);