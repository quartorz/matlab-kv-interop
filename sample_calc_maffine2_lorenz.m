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

figure;
plot3(mid(data(:, 2)),mid(data(:, 3)),mid(data(:, 4)));
xlabel('x');
ylabel('y');
zlabel('z');

% t = 30.0での計算結果を表すAffine多項式をプロットする
% ダミー変数の数が多いと描画が終わらないので17個まで減らしてプロットする
figure;
subplot(2, 2, 1);
tools.plot_affine(a(:, 1), a(:, 2), a(:, 3), 'FaceColor', 'flat', 'EpsilonLimit', 17);
xlabel('x');
ylabel('y');
zlabel('z');

% 2次元でプロットすればダミー変数が多くてもプロットできる
subplot(2, 2, 2);
tools.plot_affine(a(:, 1), a(:, 2), 'FaceColor', 'r');
xlabel('x');
ylabel('y');
subplot(2, 2, 3);
tools.plot_affine(a(:, 2), a(:, 3), 'FaceColor', 'g');
xlabel('y');
ylabel('z');
subplot(2, 2, 4);
tools.plot_affine(a(:, 3), a(:, 1), 'FaceColor', 'b');
xlabel('z');
ylabel('x');

%PlotCube(data(:, 2), data(:, 3), data(:, 4), 'vs', 'o');