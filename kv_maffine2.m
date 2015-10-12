%% kv_maffine2
% make_kv_maffine2で生成したプログラムで計算して結果を返す関数
function [data] =  kv_maffine2(name, t_init, t_last, n, order, u,  parameter, ep_reduce, ep_limit)

%%
% 引数

% n         : tの分割数([t_init, t_last]をn分割する)
% order     : Taylor展開のオーダー
% u         : 初期値
% t_init    : 今は無視される
% ep_reduce : kv::ode_param<T>::ep_reduce
%             (詳細はhttp://verifiedby.me/kv/ode/index.htmlを参照)
% ep_limit  : kv::ode_param<T>::ep_reduce_limit
%             (詳細はhttp://verifiedby.me/kv/ode/index.htmlを参照)

%%

t_init = intval(0.0);

%% プログラムの実行
% プログラムを実行するための引数を用意する

command = [
    '"' fullfile(name, 'exec.exe') '" ' ...
    '"' fullfile(name, 'output.csv') '" ' ...
    int2str(order) ' ' int2str(n) ' ' int2str(ep_reduce) ' ' int2str(ep_limit)
];

itv = intval(t_last);
[a, b, c] = tools.decomp_double(inf(itv));
command = [command ' ' int2str(a) ' ' int2str(b) ' ' int2str(c)];
[a, b, c] = tools.decomp_double(sup(itv));
command = [command ' ' int2str(a) ' ' int2str(b) ' ' int2str(c)];

for i = 1:length(u)
    itv = intval(u(i));    
    [a, b, c] = tools.decomp_double(inf(itv));
    command = [command ' ' int2str(a) ' ' int2str(b) ' ' int2str(c)];
    [a, b, c] = tools.decomp_double(sup(itv));
    command = [command ' ' int2str(a) ' ' int2str(b) ' ' int2str(c)];
end

for i = 1:length(parameter)
    itv = intval(parameter(i));    
    [a, b, c] = tools.decomp_double(inf(itv));
    command = [command ' ' int2str(a) ' ' int2str(b) ' ' int2str(c)];
    [a, b, c] = tools.decomp_double(sup(itv));
    command = [command ' ' int2str(a) ' ' int2str(b) ' ' int2str(c)];
end

%%
% プログラムを実行する
disp(command);
system(command);

%% 実行結果を得る
data = tools.get_last_result(name);

end