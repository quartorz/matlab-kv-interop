%% plot_affine
% Affine‘½€Ž®‚ðƒvƒƒbƒg‚·‚é

function plot_affine( x, y, varargin )

if ~isempty(varargin) > 0 && ~ischar(cell2mat(varargin(1)))
    dim = 3;
    z = varargin(1);
    varargin = varargin(2 : end);
else
    dim = 2;
end

for i = 0 : length(varargin) / 2 - 1
    if strcmp(varargin(2 * i + 1), 'ColorSpec')
        color = cell2mat(varargin(2 * i + 2));
    end
end

if ~exist('color', 'var')
    color = 'r';
end

if dim == 2
    len = max(length(x), length(y));

    if len > length(x)
        x(len) = 0.0;
    end

    if len > length(y)
        y(len) = 0.0;
    end

    px = x(1);
    py = y(1);

    for i = 2 : len
        px_ = zeros(1, length(px) * 2);
        py_ = zeros(1, length(py) * 2);

        for j = 0 : length(px) - 1
            px_(2 * j + 1) = px(j + 1) - x(i);
            px_(2 * j + 2) = px(j + 1) + x(i);
            py_(2 * j + 1) = py(j + 1) - y(i);
            py_(2 * j + 2) = py(j + 1) + y(i);
        end

        if length(px_) > 2
            k = convhull(px_, py_);
            px = px_(k(:));
            py = py_(k(:));
        else
            px = px_;
            py = py_;
        end
    end

    fill(px, py, color);
else
    error('3d plot is not yet implemented');
end

end