% Lorenz方程式をkv::odelong_qr_lohnerを使って計算するサンプルプログラム
% t = 0.0からt = 20.0まで
% Taylor展開の次数5
% 初期値 [1;0;0]
% パラメータ [10;28;8/3]
% Affine Arithmeticのダミー変数が130個以上になったら120個に減らす

t_last = 20.0;
p = 5;
init = [1;0;0];
params = [10;28;intval(8)/3];

[status, data] = kv_qr_lohner('lorenz-qr-lohner', 0.0, t_last, p, init, params);

if status == Status.Incomplete
    disp(['t = ' num2str(mid(data(end, 1))) 'までしか計算できなかった']);
end

plot3(mid(data(:,2)),mid(data(:,3)),mid(data(:,4)));
