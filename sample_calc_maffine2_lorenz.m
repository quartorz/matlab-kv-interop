% t = 0.0からt = 23.0までを3000等分
% Taylor展開の次数7
% 初期値 [1;0;0]
% パラメータ[10;28;8/3]

n = 3000;
p = 7;
init = [1;0;0];
t_last = 23.0;

data = kv_maffine2(n, p, init, 0.0, t_last, [10;28;intval(8)/3], 'lorenz-maffine2');
plot3(mid(data(:, 2)),mid(data(:, 3)),mid(data(:, 4)));
PlotCube(data(:, 2), data(:, 3), data(:, 4), 'vs', 'o');