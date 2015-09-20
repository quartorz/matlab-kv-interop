function [status, output] = clang (sources, executable)
% sources    : cell array of source files
% executable : name of executable file (optional)

command = ['clang -std=c++1z -O3 -DNDEBUG -I./include ' strjoin(sources)];

if nargin >= 2
    command = [command ' -o ' executable];
end

[status, output] = system(command);

end