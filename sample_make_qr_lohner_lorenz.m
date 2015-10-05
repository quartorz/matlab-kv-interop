syms x y z sigma rho beta;

u = [x;y;z];
f = [sigma * (y - x); x * (rho - z) - y; x * y - beta * z];
parameter = [sigma;rho;beta];

make_kv_qr_lohner(u, f, parameter, 'lorenz-qr-lohner');