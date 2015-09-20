function [status, output] = msvc (sources, executable)
% sources    : cell array of source files
% executable : name of executable file (optional)

command = ['vcvarsall && cl /Ox /EHsc /MT /DNDEBUG /I.\include ' strjoin(sources)];

if nargin >= 2
    command = [command ' /Fe' executable];
end

[status, output] = system(command);

end