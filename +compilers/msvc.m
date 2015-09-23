function [status, output] = msvc (sources, executable)
% sources    : cell array of source files
% executable : name of executable file (optional)

persistent msvc_dir

if ~ischar(msvc_dir)
    [status, output] = system('"tools/get-msvc-env.bat');

    if status ~= 0 || isempty(output)
        disp('Visual C++ not found.');
        return
    end

    t = strsplit(output, '=');
    msvc_dir = char(t(2));
    msvc_dir = msvc_dir(1:end-1);
end

command = [ ...
    '"' char(msvc_dir) '\VC\vcvarsall.bat"' ...
    '&& cl /Ox /EHsc /MT /DNDEBUG /I.\include ' ...
    strjoin(sources)
];

if nargin >= 2
    command = [command ' /Fe' executable];
end

[status, output] = system(command);

end