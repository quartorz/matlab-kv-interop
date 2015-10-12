function build_tools (compiler)

if ispc
    exe_ext = '.exe';
else
    exe_ext = '.out';
end

if exist(fullfile('tools', ['MATLAB2C++' exe_ext]), 'file') == 2
    return;
end

if nargin < 1
    disp('the argument ''compiler'' of build_tools is empty');
    disp('use Microsoft Visual C++ compiler as default');
    compiler = @compilers.msvc;
end

disp('building MATLAB2C++');
[status, out] = compiler({fullfile('tools', 'matlab2c++.cpp')}, fullfile('tools', ['MATLAB2C++' exe_ext]));

if status ~= 0
    disp('build of MATLAB2C++ failed');
    disp(out);
else
    disp('build of MATLAB2C++ succeeded');
end

!del *.obj

end