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

for i = 1:length(sources)
    command = [command ' ' char(sources(i))];
end

if nargin >= 2
    command = [command ' -o ' executable];
end

command = [command ' -lstdc++'];

[status, output] = system(command);

end
