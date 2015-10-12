syms x y z sigma rho beta;

u = [x;y;z];
f = [sigma * (y - x); x * (rho - z) - y; x * y - beta * z];
parameter = [sigma;rho;beta];

make_kv_maffine2('lorenz-maffine2', f, u, parameter);