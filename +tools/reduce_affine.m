%% reduce_affine
% Affine‘½€®‚Ìƒ_ƒ~[•Ï”‚ğŒ¸‚ç‚·

function [ result ] = reduce_affine( affine, limit )

linesep = java.lang.System.getProperty('line.separator').char;

inputName = fullfile('.', '+tools', 'reduce_affine_tmpin.csv');
inputFile = fopen(inputName, 'w');

outputName = fullfile('.', '+tools', 'reduce_affine_tmpout.csv');

if inputFile == -1
    error(['cannot open ' inputName]);
end

s = size(affine);

for i = 1 : s(1)
    for j = 1 : s(2)
        [a, b, c] = tools.decomp_double(affine(i, j));
        fprintf(inputFile, '%d,%d,%d', a, b, c);
        if j == s(2)
            fwrite(inputFile, linesep);
        else
            fwrite(inputFile, ',');
        end
    end
end

fclose(inputFile);

status = system([ ...
    '"' fullfile('.', 'tools', 'ReduceAffine') '" ' ...
    inputName ' ' outputName ' ' int2str(limit)
]);

if status == 0
    data = csvread(outputName);
    s = size(data);

    result = zeros(s(1), s(2) / 3);

    for i = 0 : s(2) / 3 - 1
        result(:, i + 1) = ...
            (-1) .^ data(:, 3 * i + 1) ...
            .* 2 .^ data(:, 3 * i + 2) ...
            .* data(:, 3 * i + 3);
    end
end

delete(inputName, outputName);

end

