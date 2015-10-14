% Lorenz方程式をkv::ode_maffine2を使って計算するサンプルプログラム
% t = 0.0からt = 23.0までを3000等分
% Taylor展開の次数7
% 初期値 [1;0;0]
% パラメータ [10;28;8/3]
% Affine Arithmeticのダミー変数が150個以上になったら130個に減らす

t_last = 23.0;
n = 3000;
p = 7;
init = [1;0;0];
params = [10;28;intval(8)/3];

[status, data] = kv_maffine2('lorenz-maffine2', 0.0, t_last, n, p, init, params, 130, 150);

if status == Status.Incomplete
    disp(['t = ' num2str(mid(data(end, 1))) 'までしか計算できなかった']);
end

plot3(mid(data(:, 2)),mid(data(:, 3)),mid(data(:, 4)));
%PlotCube(data(:, 2), data(:, 3), data(:, 4), 'vs', 'o');