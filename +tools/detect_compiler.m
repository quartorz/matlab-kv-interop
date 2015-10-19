%% tools.detect_compiler
% コンパイラを探す
% Visual C++、Clang、GCCの順で探す

function compiler = detect_compiler ()

if ispc
    [status, output] = system(fullfile('tools', 'get-vs-path.bat'));
    if status == 0 && ~isempty(output)
        compiler = @compilers.msvc;
        return;
    end
end

paths = getenv('path');
delims = [strfind(paths, pathsep), length(paths) + 1];

% find clang

if ispc
    clang = 'clang.exe';
else
    clang = 'clang';
end

first = 1;
for j = 1 : length(delims)
    last = delims(j) - 1;
    if exist(fullfile(paths(first:last), clang), 'file') ~= 0
        compiler = @compilers.clang;
        return;
    end
    first = last + 2;
end

% find gcc

if ispc
    gcc = 'g++.exe';
else
    gcc = 'g++';
end

first = 1;
for j = 1 : length(delims)
    last = delims(j) - 1;
    if exist(fullfile(paths(first:last), gcc), 'file') ~= 0
        compiler = @compilers.gcc;
        return;
    end
    first = last + 2;
end

error('no compilers found');

end