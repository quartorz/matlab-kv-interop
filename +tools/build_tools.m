function build_tools (compiler)

if exist('tools/MATLAB2C++.exe', 'file') == 2
    return;
end

if nargin < 1
    disp('the argument ''compiler'' of build_tools is empty');
    disp('use Microsoft Visual C++ compiler as default');
    compiler = @compilers.msvc;
end

disp('building MATLAB2C++');
[status, out] = compiler({'tools/matlab2c++.cpp'}, 'tools/MATLAB2C++.exe');

if status ~= 0
    disp('build of MATLAB2C++ failed');
    disp(out);
else
    disp('build of MATLAB2C++ succeeded');
end

!del *.obj

end