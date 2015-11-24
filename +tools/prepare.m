function prepare (compiler)

if exist('include/kv', 'dir') ~= 7
    disp('downloading kv...');

    version = get_kv_version();

    disp(['latest version: ' version]);

    download_kv(version);

    disp('download completed.');

    linesep = java.lang.System.getProperty('line.separator').char;

    file = fopen('+tools/prepare_config.txt', 'w');
    fwrite(file, [date linesep]);
    fwrite(file, [version linesep]);
    fclose(file);
else
    file = fopen('+tools/prepare_config.txt', 'r+');

    if file ~= -1
        d = fgetl(file);

        if datenum(date) - datenum(d) > 1
            localVersion = fgetl(file);
            latestVersion = get_kv_version();

            if ~strcmp(localVersion, latestVersion)
                disp('downloading kv...');
                download_kv(latestVersion);
                disp('download completed.');
            end

            linesep = java.lang.System.getProperty('line.separator').char;

            fseek(file, 0, 'bof');
            fwrite(file, [date linesep]);
            fwrite(file, [latestVersion linesep]);
        end

        fclose(file);
    end
end

if nargin >= 1
    tools.build_tools(compiler);
else
    tools.build_tools();
end

end

function version = get_kv_version

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

end

function download_kv (version)

url = ['http://verifiedby.me/kv/download/kv-' version '.tar.gz'];

mkdir('tmp');
untar(url, 'tmp');
movefile(fullfile('tmp', ['kv-' version], 'kv'), 'include');
rmdir('tmp', 's');

end