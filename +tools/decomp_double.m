function [sign, exponent, significand] = decomp_double (d)
    if d < 0.0
        sign = 1;
    else
        sign = 0;
    end
    
    d = abs(d);
    
    if d < 1.0
        exponent = 0;
        while d ~= uint64(d)
            d = d * 2.0;
            exponent = exponent - 1;
        end
        significand = uint64(d);
    else
        exponent = 0;
        while d > 1.0
            d = d / 2.0;
            exponent = exponent + 1;
        end
        exponent = exponent - 53;
        significand = uint64(d * 9007199254740992);
    end
end