%% compilers.gcc
% GCCでコンパイルを行うための関数

function [status, output] = gcc (sources, executable)

%%
% 引数

% sources    : ソースファイルのセル配列
% executable : 実行ファイル名(省略可)

%%
% 戻り値

% status : コンパイラの終了コード(0のときコンパイル成功)
% output : コンパイラの標準出力

%%
% プログラム

command = ['g++ -std=c++1z -O3 -DNDEBUG -I./include'];

first = length(command) + 1;

command = [ ...
    command ...
    zeros(1, sum(cellfun(@(x) length(x), sources)) ...
             + length(sources)) ...
];

for i = 1:length(sources)
    source = char(sources(i));
    
    last = first + length(source);
    command(first) = ' ';
    command(first + 1 : last) = source;
    first = last + 1;
end

if nargin >= 2
    command = [command ' -o ' executable];
end

command = [command ' -lstdc++'];

[status, output] = system(command);

end
