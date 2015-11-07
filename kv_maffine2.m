%% kv_maffine2
% make_kv_maffine2で生成したプログラムで計算して結果を返す関数

function [status, data, varargout] =  kv_maffine2(name, t_init, t_last, n, order, u,  parameters, ep_reduce, ep_limit)

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
% 戻り値

% status    : 計算できたかどうかを表す
%             ・State.Succeeded
%               t_lastまで計算できた
%             ・State.Failed
%               計算を始められなかった
%               ・コマンドライン引数がおかしい(ライブラリのバグ)
%               ・出力ファイルを開けなかった(ライブラリのバグではない)
%               詳細はコマンドウィンドウに出力される
%             ・State.Incomplete
%               途中までしか計算できなかった
% data      : 計算結果を表す区間行列
%             1列目がtで他の列はu
% varargout : 戻り値が3つ要求された時にAffine多項式を返す。

%%
% |[s, d, a] = kv_maffine2(...);| のように呼び出すと |a| に $t=\mathtt{t\_last}$
% でのAffine多項式の係数が入る。各列が |u| に対応する。
% 1行目は定数項、それ以外の行はダミー変数の係数を表す。

%%

t_init = intval(0.0);

%% プログラムの実行
% プログラムを実行するための引数を用意する

command = [
    '"' fullfile('.', name, 'exec') '" ' ...
    '"' fullfile('.', name, 'output.csv') '" ' ...
    '"' fullfile('.', name, 'last-affine.csv') '" ' ...
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

for i = 1:length(parameters)
    itv = intval(parameters(i));    
    [a, b, c] = tools.decomp_double(inf(itv));
    command = [command ' ' int2str(a) ' ' int2str(b) ' ' int2str(c)];
    [a, b, c] = tools.decomp_double(sup(itv));
    command = [command ' ' int2str(a) ' ' int2str(b) ' ' int2str(c)];
end

%%
% プログラムを実行する

disp(command);
[status, out] = system(command);

%%
% 最後まで計算できなかったときはメッセージを出力する
if status ~= Status.Succeeded
        disp(out);

        if status ~= Status.Incomplete
            error(['failed (status: ' int2str(status) ')']);
        end
end

%% 実行結果を得る
data = tools.get_latest_result(name);

%%
% 最終的なAffine多項式が必要な時はそれも返す
if nargout > 2
    varargout{1} = tools.get_last_affine(name);
end

end