function [status, output] = clang (sources, executable)
% sources    : cell array of source files
% executable : name of executable file (optional)

command = ['clang -std=c++1z -O3 -DNDEBUG -I./include'];

for i = 1:length(sources)
    command = [command ' ' char(sources(i))];
end

if nargin >= 2
    command = [command ' -o ' executable];
end

command = [command ' -lstdc++'];

[status, output] = system(command);

end
