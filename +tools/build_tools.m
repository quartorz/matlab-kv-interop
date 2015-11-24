function build_tools (compiler)

if ispc
    exe_ext = '.exe';
else
    exe_ext = '';
end

if ~exist(fullfile('.', 'tools', ['MATLAB2C++' exe_ext]), 'file')
    if nargin < 1
        disp('the argument ''compiler'' of build_tools is empty');
        disp('finding available compiler...');
        compiler = tools.detect_compiler();
    end

    disp('building MATLAB2C++');
    [status, out] = compiler({fullfile('.', 'tools', 'matlab2c++.cpp')}, fullfile('.', 'tools', ['MATLAB2C++' exe_ext]));

    if status ~= 0
        disp(out);
        error('build of MATLAB2C++ failed');
    else
        disp('build of MATLAB2C++ succeeded');
    end

    delete('*.obj');
end

if ~exist(fullfile('.', 'tools', ['ReduceAffine', exe_ext]), 'file')
    if nargin < 1 && ~exist('compiler', 'var')
        disp('the argument ''compiler'' of build_tools is empty');
        disp('find available compiler');
        compiler = tools.detect_compiler();
    end

    disp('building ReduceAffine');
    [status, out] = compiler({fullfile('.', 'tools', 'reduce_affine.cpp')}, fullfile('.', 'tools', ['ReduceAffine' exe_ext]));

    if status ~= 0
        disp(out);
        error('build of ReduceAffine failed');
    else
        disp('build of ReduceAffine succeeded');
    end

    delete('*.obj');
end

end