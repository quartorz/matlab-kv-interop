% Roessler方程式をkv::ode_maffine2を使って計算するサンプルプログラム
% t = 0.0からt = 30.0までを3000等分
% Taylor展開の次数7
% 初期値 [1;0;0]
% Affine Arithmeticのダミー変数が18個以上になったら20個に減らす

t_last = 100.0;
n = 3000;
p = 7;
init = [1;0;0];
params = [intval('0.2');intval('0.2');intval('5.7')];

[status, data] = kv_maffine2('roessler-maffine2', 0.0, t_last, n, p, init, params, 18, 20);

if status == Status.Incomplete
    disp(['t = ' num2str(mid(data(end, 1))) 'までしか計算できなかった']);
end

plot3(mid(data(:, 2)),mid(data(:, 3)),mid(data(:, 4)));