function prepare (compiler)

if nargin >= 1
    build_tools(compiler);
else
    build_tools();
end

if exist('include/kv', 'dir') ~= 7
    disp('downloading kv...');

    c = urlread('http://verifiedby.me/kv/download/');
    v = regexpi(c, '"kv-(?<major>\d+)\.(?<minor>\d+)\.?(?<build>\d+)?\.tar\.gz"', 'names');
    vers = zeros(length(v), 3);

    for i = 1 : length(v)
        vers(i, 1) = str2double(v(i).major);
        vers(i, 2) = str2double(v(i).minor);
        if ~isempty(v(i).build)
            vers(i, 3) = str2double(v(i).build);
        end
    end

    vers = sortrows(vers, 3);
    vers = sortrows(vers, 2);
    vers = sortrows(vers, 1);

    version = [num2str(vers(end, 1)) '.' num2str(vers(end, 2))];

    if vers(end, 3) ~= 0
        version = [version '.' num2str(vers(end, 3))];
    end

    url = ['http://verifiedby.me/kv/download/kv-' version '.tar.gz'];

    disp(['latest version: ' version]);
    disp(['download from ' url]);

    mkdir('tmp');
    untar(url, 'tmp');
    movefile(fullfile('tmp', ['kv-' version], 'kv'), 'include');
    rmdir('tmp', 's');

    disp('download completed.');
end

end