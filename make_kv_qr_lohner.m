function make_kv_qr_lohner (u, f, parameter, name, compiler)
% make verification program
% 

if nargin <= 4
    disp('the argument ''compiler'' of make_kv is empty.');
    disp('use Microsoft Visual C++ compiler as default.');
    compiler = @compilers.msvc;
end

build_tools(compiler);

mkdir(name);

source = fullfile(name, 'main.cpp');
executable = fullfile(name, 'exec.exe');

matlab2cpp = fullfile('tools', 'MATLAB2C++.exe');

dim = length(f);

%--------------------------------------------------------------------------
% generate source file
%--------------------------------------------------------------------------

disp(['generating source file (file name: ' source ')']);

fp = fopen(source, 'wt');

% preprocessors

fprintf(fp, '// eliminate deprecation warnings\n');
fprintf(fp, '#if defined(_MSC_VER)\n');
fprintf(fp, '# define _CRT_SECURE_NO_WARNINGS\n');
fprintf(fp, '#endif\n\n');
fprintf(fp, '#include <cstdlib>\n');
fprintf(fp, '#include <iostream>\n');
fprintf(fp, '#include <fstream>\n');
fprintf(fp, '#include <utility>\n\n');
fprintf(fp, '#include <boost/numeric/ublas/vector.hpp>\n\n');
fprintf(fp, '#include <kv/interval.hpp>\n');
fprintf(fp, '#include <kv/rdouble.hpp>\n');
fprintf(fp, '#include <kv/ode-qr-lohner.hpp>\n');
fprintf(fp, '#include <kv/ode-param.hpp>\n');
fprintf(fp, '#include <kv/ode-callback.hpp>\n\n');
fprintf(fp, '#include <conv.hpp>\n\n');

% function

fprintf(fp, 'struct func{\n');

if length(parameter) > 0
    % definition of members
    fprintf(fp, '\t::kv::interval<double> ');
    
    for i = 1:length(parameter)
        if i ~= 1
            fprintf(fp, ', ');
        end
        fprintf(fp, char(parameter(i)));
    end
    
    fprintf(fp, ';\n\n');
    
    % constructor
    fprintf(fp, '\tfunc(\n');
    
    for i = 1:length(parameter)
        fprintf(fp, ['\t\tconst ::kv::interval<double> &' char(parameter(i))]);
        if i ~= length(parameter)
            fprintf(fp, ',');
        end
        fprintf(fp, '\n');
    end
    
    fprintf(fp, '\t)\n');
    fprintf(fp, '\t\t: ');
    
    for i = 1:length(parameter)
        if i ~= 1
            fprintf(fp, '\t\t, ');
        end
        fprintf(fp, [char(parameter(i)) '(' char(parameter(i)) ')\n']);
    end
    
    fprintf(fp, '\t{\n\t}\n\n');
end

fprintf(fp, '\ttemplate<typename T>\n');
fprintf(fp, '\t::boost::numeric::ublas::vector<T> operator()(\n');
fprintf(fp, '\t\tconst ::boost::numeric::ublas::vector<T> &u,\n');
fprintf(fp, '\t\tconst T &t\n');
fprintf(fp, '\t) const\n');
fprintf(fp, '\t{\n');

for i = 1:length(u)
    fprintf(fp, ['\t\tconst T &' char(u(i)) ' = u(' int2str(i - 1) ');\n']);
end

fprintf(fp, '\n');

fprintf(fp, ['\t\t::boost::numeric::ublas::vector<T> return_value(' int2str(dim) ');\n\n']);

for i = 1:length(f)
    [status out] = system([matlab2cpp ' "' char(f(i)) '"']);
    
    if status ~= 0
        disp(['Failed to parse function "' char(f(i)) '".']);
        disp(out);
        return
    end
    
    fprintf(fp, ['\t\treturn_value(' int2str(i - 1) ') = ' out ';\n']);
end

fprintf(fp, '\n\t\treturn return_value;\n');
fprintf(fp, '\t}\n');
fprintf(fp, '};\n\n');

% callback

fprintf(fp, 'struct callback : ::kv::ode_callback<double>{\n');
fprintf(fp, '\tmutable ::std::ofstream ofs;\n\n');
fprintf(fp, '\tcallback(::std::ofstream &&o)\n');
fprintf(fp, '\t\t: ofs(::std::move(o))\n');
fprintf(fp, '\t{\n');
fprintf(fp, '\t}\n\n');
fprintf(fp, '\tvoid operator()(\n');
fprintf(fp, '\t\tconst ::kv::interval<double>& start,\n');
fprintf(fp, '\t\tconst ::kv::interval<double>& end,\n');
fprintf(fp, '\t\tconst ::boost::numeric::ublas::vector< ::kv::interval<double> >& x_s,\n');
fprintf(fp, '\t\tconst ::boost::numeric::ublas::vector< ::kv::interval<double> >& x_e,\n');
fprintf(fp, '\t\tconst ::boost::numeric::ublas::vector< ::kv::psa< ::kv::interval<double> > >& result\n');
fprintf(fp, '\t) const override\n');
fprintf(fp, '\t{\n');
fprintf(fp, '\t\tofs << end.lower() << '','' << end.upper();\n');

for i = 1:length(u)
    fprintf(fp, '\t\tofs << '','';\n');
    fprintf(fp, ['\t\t::kv::rop<double>::print_down(x_e(' int2str(i - 1) ').lower(), ofs);\n']);
    fprintf(fp, '\t\tofs << '','';\n');
    fprintf(fp, ['\t\t::kv::rop<double>::print_up(x_e(' int2str(i - 1) ').upper(), ofs);\n']);
end

fprintf(fp, '\t\tofs << ::std::endl;\n');

fprintf(fp, '\t}\n};\n\n');

% main

% 初期値と時間の終点とパラメータは区間で表されてコマンドライン引数から受け取る
% コマンドライン引数には下端と上端それぞれを符号ビット(0か1)、指数部(符号付き整数)、仮数部(64ビット以内の整数)の3つに分解したものを渡す

fprintf(fp, 'int main(int argc, char **argv)\n');
fprintf(fp, '{\n');

fprintf(fp, ['\tif(argc < ' int2str(2 + 2 * 3 * (1 + length(u) + length(parameter))) '){\n']);
fprintf(fp, '\t\t::std::cerr << "invalid argument" << ::std::endl;\n');
fprintf(fp, '\t}\n\n');

fprintf(fp, '\t::std::ofstream ofs(argv[1]);\n');
fprintf(fp, '\tofs.setf(ofs.scientific);\n');
fprintf(fp, '\tofs.precision(17);\n\n');

fprintf(fp, '\t::kv::interval<double> t_last(\n');
fprintf(fp, '\t\t::todouble(::std::strtol(argv[3], nullptr, 10), ::std::strtol(argv[4], nullptr, 10), ::std::strtoull(argv[5], nullptr, 10)),\n');
fprintf(fp, '\t\t::todouble(::std::strtol(argv[6], nullptr, 10), ::std::strtol(argv[7], nullptr, 10), ::std::strtoull(argv[8], nullptr, 10)));\n\n');

fprintf(fp, ['\t::boost::numeric::ublas::vector<::kv::interval<double>> u(' int2str(length(u)) ');\n\n']);

for i = 1:length(u)
    fprintf(fp, [ ...
        '\tu(' int2str(i - 1) ') = ::kv::interval<double>(\n' ...
        '\t\t::todouble(::std::strtol(argv[' int2str(i * 6 + 3) '], nullptr, 10), ::std::strtol(argv[' int2str(i * 6 + 4) '], nullptr, 10), ::std::strtoull(argv[' int2str(i * 6 + 5) '], nullptr, 10)),\n' ...
        '\t\t::todouble(::std::strtol(argv[' int2str(i * 6 + 6) '], nullptr, 10), ::std::strtol(argv[' int2str(i * 6 + 7) '], nullptr, 10), ::std::strtoull(argv[' int2str(i * 6 + 8) '], nullptr, 10)));\n\n']);
end

bias = 6 * length(u) + 2;

for i = 1:length(parameter)
    fprintf(fp, [ ...
        '\t::kv::interval<double> ' char(parameter(i)) '(\n' ...
        '\t\t::todouble(::std::strtol(argv[' int2str(i * 6 + bias + 1) '], nullptr, 10), ::std::strtol(argv[' int2str(i * 6 + bias + 2) '], nullptr, 10), ::std::strtoull(argv[' int2str(i * 6 + bias + 3) '], nullptr, 10)),\n' ...
        '\t\t::todouble(::std::strtol(argv[' int2str(i * 6 + bias + 4) '], nullptr, 10), ::std::strtol(argv[' int2str(i * 6 + bias + 5) '], nullptr, 10), ::std::strtoull(argv[' int2str(i * 6 + bias + 6) '], nullptr, 10)));\n\n']);
end

clear bias;

fprintf(fp, '\tofs << "0.0,0.0"');

for i = 1:length(u)
    fprintf(fp, ['\n\t    << '','' << u(' int2str(i - 1) ').lower() << '','' << u(' int2str(i - 1) ').upper()']);
end

fprintf(fp, ' << ::std::endl;\n\n');

fprintf(fp, '\tint r = ::kv::odelong_qr_lohner(\n');
fprintf(fp, '\t\tfunc(');

for i = 1:length(parameter)
    if i ~= 1
        fprintf(fp, ', ');
    end
    fprintf(fp, char(parameter(i)));
end

fprintf(fp, '),\n');
fprintf(fp, '\t\tu,\n');
fprintf(fp, '\t\t::kv::interval<double>(0.0),\n');
fprintf(fp, '\t\tt_last,\n');
fprintf(fp, '\t\t::kv::ode_param<double>().set_order(::std::strtol(argv[2], nullptr, 10)),\n');
fprintf(fp, '\t\tcallback(::std::move(ofs)));\n\n');
fprintf(fp, '\treturn (r != 0) ? 0 : 1;\n');
fprintf(fp, '}\n');

fclose(fp);

disp('source file was generated.');
disp('compiling...');

[status, out] = compiler({source}, executable);

if status ~= 0
    disp('compilation failed.');
    disp(out);
else
    disp('compilation succeeded.');
end

!del *.obj

end