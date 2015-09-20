% t = 0.0からt = 23.0までを3000等分
% Taylor展開の次数7
% 初期値 [1;0;0]
% パラメータ[10;28;8/3]

n = 3000;
p = 7;
init = [1;0;0];
t_last = 23.0;

data = kv_maffine2(n, p, init, 0.0, t_last, [10;28;intval(8)/3], 'lorentz-maffine2');
plot3(mid(infsup(data(:,3),data(:,4))),mid(infsup(data(:,5),data(:,6))),mid(infsup(data(:,7),data(:,8))));
%PlotCube(infsup(data(:,3),data(:,4))', infsup(data(:,5),data(:,6))', infsup(data(:,7),data(:,8))', 'vs', 'o');