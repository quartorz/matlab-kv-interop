p = 20;
init = [1;1;1];
t_last = 3.0;

data = kv_qr_lohner(5, init, 0.0, t_last, [10;28;intval(8)/3], 'lorenz-qr-lohner');
plot3(mid(infsup(data(:,3),data(:,4))),mid(infsup(data(:,5),data(:,6))),mid(infsup(data(:,7),data(:,8))));
