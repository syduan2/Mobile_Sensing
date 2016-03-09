data = csvread('CSL_Building_1457222144.csv');
[x, y] = size(data);
x_vals = 1:x

direction = cumsum(data(:, 6));
compass = zeros(x, 1)
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
plot(x_vals, direction);
plot(x_vals, compass);
axis([0, x, 0, 360]);