% t = 0.0‚©‚çt = 30.0‚Ü‚Å‚ğ3000“™•ª
% Taylor“WŠJ‚ÌŸ”7
% ‰Šú’l [1;0;0]

n = 3000;
p = 7;
init = [1;0;0];
t_last = 30.0;

data = kv_maffine2(n, p, init, 0.0, t_last, [intval('0.2');intval('0.2');intval('5.7')], 'roessler-maffine2');
plot3(mid(infsup(data(:,3),data(:,4))),mid(infsup(data(:,5),data(:,6))),mid(infsup(data(:,7),data(:,8))));