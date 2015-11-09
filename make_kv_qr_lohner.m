%% make_kv_qr_lohner
% kv::odelong_qr_lohnerを使って計算するプログラムを生成する関数

function make_kv_qr_lohner (name, f, u, parameters, compiler)

%%
% 引数

% name       : 出力するディレクトリの名前  
% f          : 方程式
% u          : 方程式の変数
% parameters : 方程式のパラメータ
% compiler   : 使うコンパイラ(省略可)

%%
% 引数 compiler が省略されたときは |tools.detect_compiler| でコンパイラを探す
if nargin <= 4
    disp('the argument ''compiler'' of make_kv_qr_lohner is empty');
    disp('finding available compiler...');
    compiler = tools.detect_compiler();
end

%% 生成のための準備
% * tools/MATLAB2C++のコンパイル
% * kvのダウンロード
tools.prepare(compiler);

%% プログラムの生成
mkdir(name);

source = fullfile(name, 'main.cpp');
executable = fullfile(name, 'exec');

matlab2cpp = fullfile('tools', 'MATLAB2C++');

dim = length(f);

disp(['generating source file (file name: ' source ')']);

fp = fopen(source, 'wt');

%%
% <html><h3>プリプロセッサ</h3></html>

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

%%
% <html><h3>方程式を表す関数オブジェクトクラスの生成</h3></html>

fprintf(fp, 'struct func{\n');

if length(parameters) > 0
    % definition of members
    fprintf(fp, '\t::kv::interval<double> ');
    
    for i = 1:length(parameters)
        if i ~= 1
            fprintf(fp, ', ');
        end
        fprintf(fp, char(parameters(i)));
    end
    
    fprintf(fp, ';\n\n');
    
    % constructor
    fprintf(fp, '\tfunc(\n');
    
    for i = 1:length(parameters)
        fprintf(fp, ['\t\tconst ::kv::interval<double> &' char(parameters(i))]);
        if i ~= length(parameters)
            fprintf(fp, ',');
        end
        fprintf(fp, '\n');
    end
    
    fprintf(fp, '\t)\n');
    fprintf(fp, '\t\t: ');
    
    for i = 1:length(parameters)
        if i ~= 1
            fprintf(fp, '\t\t, ');
        end
        fprintf(fp, [char(parameters(i)) '(' char(parameters(i)) ')\n']);
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
fprintf(fp, '\t\t::out_double(end.lower(), ofs);\n');
fprintf(fp, '\t\tofs << '','';\n');
fprintf(fp, '\t\t::out_double(end.upper(), ofs);\n');

for i = 1:length(u)
    fprintf(fp, '\t\tofs << '','';\n');
    fprintf(fp, ['\t\t::out_double(x_e(' int2str(i-1) ').lower(), ofs);\n']);
    fprintf(fp, '\t\tofs << '','';\n');
    fprintf(fp, ['\t\t::out_double(x_e(' int2str(i-1) ').upper(), ofs);\n']);
end

fprintf(fp, '\t\tofs << ::std::endl;\n');

fprintf(fp, '\t}\n};\n\n');

%%
% <html><h3>main関数の生成</h3></html>

% argv: executable output order N
%       inf(t_last) sup(t_last)
%       inf(u0(1)) sup(u0(1)) ...
%       inf(param_1) sup(param_1) ...

%%
% 区間は下限と上限をそれぞれ
%
% $$(-1)^{sign} * 2^{exponent} * {significand}$$
%
% のように3つの整数 $sign$(符号) $, exponent$(指数部) $, significand$(仮数部) に分解して入出力する

fprintf(fp, 'int main(int argc, char **argv)\n');
fprintf(fp, '{\n');

fprintf(fp, ['\tif(argc < ' int2str(2 + 2 * 3 * (1 + length(u) + length(parameters))) '){\n']);
fprintf(fp, '\t\t::std::cout << "invalid argument" << ::std::endl;\n');
fprintf(fp, '\t\treturn 1;\n');
fprintf(fp, '\t}\n\n');

fprintf(fp, '\t::std::ofstream ofs(argv[1]);\n');
fprintf(fp, '\tif(!ofs){\n');
fprintf(fp, '\t\t::std::cout << "cannot open file ''" << argv[1] << ''\\'''' << ::std::endl;\n');
fprintf(fp, '\t\treturn 1;\n');
fprintf(fp, '\t}\n\n');
fprintf(fp, '\tofs.setf(ofs.scientific);\n');
fprintf(fp, '\tofs.precision(17);\n\n');

fprintf(fp, '\t::kv::interval<double> t_last(\n');
fprintf(fp, '\t\t::to_double(::std::strtol(argv[3], nullptr, 10), ::std::strtol(argv[4], nullptr, 10), ::std::strtoull(argv[5], nullptr, 10)),\n');
fprintf(fp, '\t\t::to_double(::std::strtol(argv[6], nullptr, 10), ::std::strtol(argv[7], nullptr, 10), ::std::strtoull(argv[8], nullptr, 10)));\n\n');

fprintf(fp, ['\t::boost::numeric::ublas::vector<::kv::interval<double>> u(' int2str(length(u)) ');\n\n']);

for i = 1:length(u)
    fprintf(fp, [ ...
        '\tu(' int2str(i - 1) ') = ::kv::interval<double>(\n' ...
        '\t\t::to_double(::std::strtol(argv[' int2str(i * 6 + 3) '], nullptr, 10), ::std::strtol(argv[' int2str(i * 6 + 4) '], nullptr, 10), ::std::strtoull(argv[' int2str(i * 6 + 5) '], nullptr, 10)),\n' ...
        '\t\t::to_double(::std::strtol(argv[' int2str(i * 6 + 6) '], nullptr, 10), ::std::strtol(argv[' int2str(i * 6 + 7) '], nullptr, 10), ::std::strtoull(argv[' int2str(i * 6 + 8) '], nullptr, 10)));\n\n']);
end

bias = 6 * length(u) + 2;

for i = 1:length(parameters)
    fprintf(fp, [ ...
        '\t::kv::interval<double> ' char(parameters(i)) '(\n' ...
        '\t\t::to_double(::std::strtol(argv[' int2str(i * 6 + bias + 1) '], nullptr, 10), ::std::strtol(argv[' int2str(i * 6 + bias + 2) '], nullptr, 10), ::std::strtoull(argv[' int2str(i * 6 + bias + 3) '], nullptr, 10)),\n' ...
        '\t\t::to_double(::std::strtol(argv[' int2str(i * 6 + bias + 4) '], nullptr, 10), ::std::strtol(argv[' int2str(i * 6 + bias + 5) '], nullptr, 10), ::std::strtoull(argv[' int2str(i * 6 + bias + 6) '], nullptr, 10)));\n\n']);
end

clear bias;

fprintf(fp, '\t::out_double(0.0, ofs);\n');
fprintf(fp, '\tofs << '','';\n');
fprintf(fp, '\t::out_double(0.0, ofs);\n');


for i = 1:length(u)
    fprintf(fp, '\tofs << '','';\n');
    fprintf(fp, ['\t::out_double(u(' int2str(i - 1) ').lower(), ofs);\n']);
    fprintf(fp, '\tofs << '','';\n');
    fprintf(fp, ['\t::out_double(u(' int2str(i - 1) ').upper(), ofs);\n']);
end

fprintf(fp, '\tofs << ::std::endl;\n\n');

fprintf(fp, '\tint r = ::kv::odelong_qr_lohner(\n');
fprintf(fp, '\t\tfunc(');

for i = 1:length(parameters)
    if i ~= 1
        fprintf(fp, ', ');
    end
    fprintf(fp, char(parameters(i)));
end

fprintf(fp, '),\n');
fprintf(fp, '\t\tu,\n');
fprintf(fp, '\t\t::kv::interval<double>(0.0),\n');
fprintf(fp, '\t\tt_last,\n');
fprintf(fp, '\t\t::kv::ode_param<double>().set_order(::std::strtol(argv[2], nullptr, 10)),\n');
fprintf(fp, '\t\tcallback(::std::move(ofs)));\n\n');
fprintf(fp, '\treturn (r != 0) ? 0 : 2;\n');
fprintf(fp, '}\n');

fclose(fp);

disp('source file was generated.');
disp('compiling...');

[status, out] = compiler({source}, executable);

if status ~= 0
    disp(out);
    error('compilation failed.');
else
    disp('compilation succeeded.');
end

delete('*.obj');

end