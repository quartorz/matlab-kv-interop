function build_tools (compiler)

if nargin < 1
    disp('The argument ''compiler'' of build_tools is empty.');
    disp('Use Microsoft Visual C++ compiler as default.');
    compiler = @msvc_compiler;
end

disp('building MATLAB2C++');
[status, out] = compiler({'tools/matlab2c++.cpp'}, 'tools/MATLAB2C++.exe');

if status ~= 0
    disp('build MATLAB2C++ failed');
    disp(out);
else
    disp('build MATLAB2C++ succeeded');
end

!del *.obj

end