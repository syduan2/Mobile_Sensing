function [processed_means, processed_variance, processed_max, processed_zeros] = stage_4 ()
raw_data = csvread('../data/Walking_1455415552.csv');
cur = raw_data(1, 11);
max_time = raw_data(end, 11);
[m, n] = size(raw_data);

last_i = 1;
num_lines = floor((max_time - cur) / 4) - 1;
processed_means = zeros(num_lines, 10);
processed_variance = zeros(num_lines, 10);
processed_max = zeros(num_lines, 10);
processed_zeros = zeros(num_lines, 10);
j=1;
for i = 1:m
   if (raw_data(i, 11) - cur > 4)
       cur_data = raw_data(last_i: i-1, 1:end-1);
       processed_means(j, :) = mean(cur_data, 1);
       processed_variance(j, :) = var(cur_data, 1);
       processed_max(j, :) = max(cur_data);
       for y = 1: size(cur_data, 1) - 1
           for x = 1: size(cur_data, 2)
               if (cur_data(y, x) * cur_data(y+1, x) < 0)
                   processed_zeros(j, x) = processed_zeros(j, x) + 1;
               end
           end
       end
       cur = raw_data(i, 11);
       j = j + 1;
   end
end
end