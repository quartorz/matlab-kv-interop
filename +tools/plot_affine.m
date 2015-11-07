%% plot_affine
% Affine‘½€Ž®‚ðƒvƒƒbƒg‚·‚é

function plot_affine( x, y, varargin )

if ~isempty(varargin) > 0 && ~ischar(cell2mat(varargin(1)))
    dim = 3;
    z = cell2mat(varargin(1));
    varargin = varargin(2 : end);
else
    dim = 2;
end

for i = 0 : length(varargin) / 2 - 1
    % http://jp.mathworks.com/help/matlab/ref/patch.html#zmw57dd0e484034
    if strcmp(varargin(2 * i + 1), 'FaceColor')
        fcolor = cell2mat(varargin(2 * i + 2));
    elseif strcmp(varargin(2 * i + 1), 'EdgeColor')
        ecolor = cell2mat(varargin(2 * i + 2));
    end
end

if ~exist('fcolor', 'var')
    fcolor = 'r';
end

if ~exist('ecolor', 'var')
    ecolor = 'k';
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

        try
            k = convhull(px_, py_, 'simplify', true);
            px = px_(k(:));
            py = py_(k(:));
        catch
            px = px_;
            py = py_;
        end
    end

    fill(px, py, fcolor, 'EdgeColor', ecolor);
else
    len = max(max(length(x), length(y)), length(z));

    if len > length(x)
        x(len) = 0.0;
    end

    if len > length(y)
        y(len) = 0.0;
    end

    if len > length(z)
        z(len) = 0.0;
    end

    px = x(1);
    py = y(1);
    pz = z(1);

    for i = 2 : len
        px_ = zeros(1, length(px) * 2);
        py_ = zeros(1, length(py) * 2);
        pz_ = zeros(1, length(py) * 2);

        for j = 0 : length(px) - 1
            px_(2 * j + 1) = px(j + 1) - x(i);
            px_(2 * j + 2) = px(j + 1) + x(i);
            py_(2 * j + 1) = py(j + 1) - y(i);
            py_(2 * j + 2) = py(j + 1) + y(i);
            pz_(2 * j + 1) = pz(j + 1) - z(i);
            pz_(2 * j + 2) = pz(j + 1) + z(i);
        end

        try
            k = convhull(px_, py_, pz_, 'simplify', true);
            px = px_(k(:));
            py = py_(k(:));
            pz = py_(k(:));
            hx = px_;
            hy = py_;
            hz = pz_;
        catch
            px = px_;
            py = py_;
            pz = pz_;
        end
    end

    trimesh(k, hx, hy, hz, 'FaceColor', fcolor, 'EdgeColor', ecolor);
end

end