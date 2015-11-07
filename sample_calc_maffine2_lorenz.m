% Lorenz方程式をkv::ode_maffine2を使って計算するサンプルプログラム
% t = 0.0からt = 30.0までを5000等分
% Taylor展開の次数10
% 初期値 [1;0;0]
% パラメータ [10;28;8/3]
% Affine Arithmeticのダミー変数が130個以上になったら120個に減らす

t_last = 30.0;
n = 5000;
p = 10;
init = [1;0;0];
params = [10;28;intval(8)/3];

[status, data, a] = kv_maffine2('lorenz-maffine2', 0.0, t_last, n, p, init, params, 120, 130);

if status == Status.Incomplete
    disp(['t = ' num2str(mid(data(end, 1))) 'までしか計算できなかった']);
end

plot3(mid(data(:, 2)),mid(data(:, 3)),mid(data(:, 4)));

% 最初の半分のダミー変数をプロットする
figure;
len = length(a);
tools.plot_affine(a(1:len/2,1), a(1:len/2,2), a(1:len/2,3), 'FaceColor', 'flat');

% 残りのダミー変数をプロットする
figure;
tools.plot_affine([0;a(len/2+1:end,1)], [0;a(len/2+1:end,2)], [0;a(len/2+1:end,3)], 'FaceColor', 'w');

%PlotCube(data(:, 2), data(:, 3), data(:, 4), 'vs', 'o');