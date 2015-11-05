f = {'sigma * (y - x)', 'x * (rho - z) - y', 'x * y - beta * z'};
u = {'x', 'y', 'z'};
parameters = {'sigma', 'rho', 'beta'};

make_kv_qr_lohner('lorenz-qr-lohner', f, u, parameters);