function [means, var_vals, max_vals, zero_vals] = stage_4 (raw_data)
cur = raw_data(1, 11);
max_time = raw_data(end, 11);
[m, n] = size(raw_data);

last_i = 1;
num_lines = floor((max_time - cur) / 0.2) + 1;
means = zeros(num_lines, 10);
var_vals = zeros(num_lines, 10);
max_vals = zeros(num_lines, 10);
zero_vals = zeros(num_lines, 10);
j=1;
for i = 1:m
   if (raw_data(i, 11) - cur > 0.2)
       cur_data = raw_data(last_i: i-1, 1:end-1);
       means(j, :) = mean(cur_data, 1);
       var_vals(j, :) = var(cur_data, 1);
       max_vals(j, :) = max(cur_data);
       for y = 1: size(cur_data, 1) - 1
           for x = 1: size(cur_data, 2)
               if (cur_data(y, x) * cur_data(y+1, x) < 0)
                   zero_vals(j, x) = zero_vals(j, x) + 1;
               end
           end
       end
       cur = raw_data(i, 11);
       j = j + 1;
   end
end
end