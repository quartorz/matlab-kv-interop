syms x y z a b c

u = [x;y;z];
f = [- y - z; x + a * y; b + x * z - c * z];
parameter = [a;b;c];

make_kv_maffine2(u, f, parameter, 'roessler-maffine2');