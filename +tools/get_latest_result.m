function [data] = get_latest_result (name)

d = csvread(fullfile(name, 'output.csv'));
s = size(d);
data(s(1), (s(2) / 3 / 2)) = intval(0.0);

data(:, 1) = infsup( ...
    (-1) .^ d(:, 1) .* 2 .^ d(:, 2) .* d(:, 3), ...
    (-1) .^ d(:, 4) .* 2 .^ d(:, 5) .* d(:, 6));

for i = 1 : (s(2) / 3 / 2) - 1
    data(:, i + 1) = infsup( ...
        (-1) .^ d(:, i * 6 + 1) .* 2 .^ d(:, i * 6 + 2) .* d(:, i * 6 + 3), ...
        (-1) .^ d(:, i * 6 + 4) .* 2 .^ d(:, i * 6 + 5) .* d(:, i * 6 + 6));
end

end