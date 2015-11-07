%% get_last_affine
% ÅŒã‚ÌŒvZŒ‹‰Ê‚ğ•\‚·Affine‘½€®‚ğ“¾‚é

function [ data ] = get_last_affine( name )

d = csvread(fullfile(name, 'last-affine.csv'));
s = size(d);
data(s(1), s(2) / 3) = 0.0;

for i = 0 : s(2) / 3 - 1
    data(:, i + 1) = ...
        (-1) .^ d(:, i * 3 + 1) .* 2 .^ d(:, i * 3 + 2) .* d(:, i * 3 + 3);
end

end