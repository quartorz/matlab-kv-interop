function [data] = get_last_result (name)

fp = fopen([name '/output.csv']);

if fp ~= -1
    count = 1;

    linec = 1;
    line = fgetl(fp);

    col = fix((length(strfind(line, ',')) + 1) / 2);

    if mod(length(strfind(line, ',')) + 1, 2) == 1
        error([name '/output.csv is invalid']);
    end

    while true
        line = fgetl(fp);
        if line == -1
            break;
        end
        linec = linec + 1;
    end

    data(linec, col) = infsup(0, 0);

    fseek(fp, 0, 'bof');

    while true
        line = fgetl(fp);

        if line == -1
            break;
        end

        indices = [strfind(line, ',') length(line)+1];

        if length(indices) ~= col * 2
            break;
        end

        b = 1;

        for i = 0 : length(indices) / 2 - 1
            e = indices(2 * i + 1);
            inf = line(b : e - 1);            
            b = e + 1;
            e = indices(2 * i + 2);
            sup = line(b : e - 1);
            
            data(count, i + 1) = hull(intval(inf), intval(sup));

            b = e + 1;
        end

        count = count + 1;
    end

    fclose(fp);
else
    error(['file ' name '/output.csv was not found']);
end

end