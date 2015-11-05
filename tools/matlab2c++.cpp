#include "matlab_ast.hpp"
#include "matlab_parser.hpp"

#include <iostream>

class unexpected_char : public std::exception {};

template < class It >
class scanner {
public:
	typedef int char_type;

public:
	scanner(It b, It e) : b_(b), e_(e), c_(b), unget_(EOF) { }

	matlab_parser::Token get(std::string& v)
	{
		v.clear();
		int c;
		do {
			c = getc();
		} while(isspace(c));

		// operators
		switch(c) {
		case '+': return matlab_parser::token_Add;
		case '-': return matlab_parser::token_Sub;
		case '*': return matlab_parser::token_Mul;
		case '/': return matlab_parser::token_Div;
		case '|': return matlab_parser::token_BitOr;
		case '&': return matlab_parser::token_BitAnd;
		case '^': return matlab_parser::token_Pow;
		case ',': return matlab_parser::token_Comma;
		case '(': return matlab_parser::token_LParen;
		case ')': return matlab_parser::token_RParen;
		case '\'': return matlab_parser::token_Trans;
		case EOF: return matlab_parser::token_eof;
		}

		// ignore equality operators and relational operators

		/*if(c == '='){
			c = getc();

			if(c == '=')
				return matlab_ast::token_Eq;

			ungetc(c);

			throw unexpected_char();
		}*/

		// array operators
		if(c == '.'){
			switch(getc()){
			case '*':
				return matlab_parser::token_ArrayMul;
			case '/':
				return matlab_parser::token_ArrayDiv;
			case '^':
				return matlab_parser::token_ArrayPow;
			case '\'':
				return matlab_parser::token_NCTrans;
			case EOF:
				return matlab_parser::token_eof;
			}
		}

		// identifiers
		if(isalpha(c)){
			while(c != EOF && (isalnum(c) || c == '_')){
				v += c;
				c = getc();
			}
			ungetc(c);
			return matlab_parser::token_Identifier;
		}

		// constants
		// 正規表現の[0-9]*(\.[0-9]*)?([eE][+-]?[0-9]*)?にマッチするかを見る。
		// ".e+1"のように.の前後が両方とも省略されていてもエラーにならない。
		if(isdigit(c) || c == '.') {
			while(isdigit(c) && c != EOF){
				v += c;
				c = getc();
			}

			if(c == '.'){
				v += c;
				c = getc();

				while(isdigit(c) && c != EOF){
					v += c;
					c = getc();
				}
			}

			if(c == 'e' || c == 'E'){
				v += c;

				c = getc();

				auto iter = c_;

				if(c == '+' || c == '-'){
					v += c;
					c = getc();
				}

				while(isdigit(c) && c != EOF){
					v += c;
					c = getc();
				}

				if(iter == c_)
					throw unexpected_char();
			}

			ungetc(c);

			return matlab_parser::token_Constant;
		}


		std::cerr << char(c) << std::endl;
		throw unexpected_char();
	}

private:
	char_type getc()
	{
		int c;
		if(unget_ != EOF) {
			c = unget_;
			unget_ = EOF;
		} else if(c_ == e_) {
			c = EOF;
		} else {
			c = *c_++;
		}
		return c;
	}

	void ungetc(char_type c)
	{
		if(c != EOF) {
			unget_ = c;
		}
	}

private:
	It              b_;
	It              e_;
	It              c_;
	char_type       unget_;

};

struct SemanticAction{
	void syntax_error(){}
	void stack_overflow(){}

	void downcast(std::string &x, matlab_ast::base *y)
	{
		x = static_cast<matlab_ast::terminal_expr*>(y)->get_content();
	}

	void downcast(matlab_ast::base *&x, matlab_ast::base *y)
	{
		x = y;
	}

	void upcast(matlab_ast::base *&x, matlab_ast::base *y)
	{
		x = y;
	}

	matlab_ast::base *DoNothing(matlab_ast::base *e)
	{
		return e;
	}

	matlab_ast::base *MakeBitOr(matlab_ast::base *x, matlab_ast::base *y)
	{
		return new matlab_ast::or_expr(x, y);
	}

	matlab_ast::base *MakeBitAnd(matlab_ast::base *x, matlab_ast::base *y)
	{
		return new matlab_ast::and_expr(x, y);
	}

	matlab_ast::base *MakeEqual(matlab_ast::base *x, matlab_ast::base *y)
	{
		return new matlab_ast::relational_expr(x, y, "==");
	}

	matlab_ast::base *MakeNotEqual(matlab_ast::base *x, matlab_ast::base *y)
	{
		return new matlab_ast::relational_expr(x, y, "!=");
	}

	matlab_ast::base *MakeLT(matlab_ast::base *x, matlab_ast::base *y)
	{
		return new matlab_ast::relational_expr(x, y, "<");
	}

	matlab_ast::base *MakeGT(matlab_ast::base *x, matlab_ast::base *y)
	{
		return new matlab_ast::relational_expr(x, y, ">");
	}

	matlab_ast::base *MakeLE(matlab_ast::base *x, matlab_ast::base *y)
	{
		return new matlab_ast::relational_expr(x, y, "<=");
	}

	matlab_ast::base *MakeGE(matlab_ast::base *x, matlab_ast::base *y)
	{
		return new matlab_ast::relational_expr(x, y, ">=");
	}

	matlab_ast::base *MakeAdd(matlab_ast::base *x, matlab_ast::base *y)
	{
		return new matlab_ast::arithmetic_expr(x, y, "+");
	}

	matlab_ast::base *MakeSub(matlab_ast::base *x, matlab_ast::base *y)
	{
		return new matlab_ast::arithmetic_expr(x, y, "-");
	}

	matlab_ast::base *MakeMul(matlab_ast::base *x, matlab_ast::base *y)
	{
		return new matlab_ast::arithmetic_expr(x, y, "*");
	}

	matlab_ast::base *MakeDiv(matlab_ast::base *x, matlab_ast::base *y)
	{
		return new matlab_ast::arithmetic_expr(x, y, "/");
	}

	matlab_ast::base *MakePow(matlab_ast::base *x, matlab_ast::base *y)
	{
		return new matlab_ast::binary_expr(x, y, "pow");
	}

	matlab_ast::base *MakeArrayMul(matlab_ast::base *x, matlab_ast::base *y)
	{
		return new matlab_ast::binary_expr(x, y, "element_prod");
	}

	matlab_ast::base *MakeArrayDiv(matlab_ast::base *x, matlab_ast::base *y)
	{
		return new matlab_ast::binary_expr(x, y, "element_div");
	}

	matlab_ast::base *MakeArrayPow(matlab_ast::base *x, matlab_ast::base *y)
	{
		throw std::runtime_error(".^ is currently not supported");
		// return new matlab_ast::binary_expr(x, y, "element_div");
	}

	matlab_ast::base *MakePlus(matlab_ast::base *x)
	{
		return new matlab_ast::unary_expr(x, "+");
	}

	matlab_ast::base *MakeMinus(matlab_ast::base *x)
	{
		return new matlab_ast::unary_expr(x, "-");
	}

	matlab_ast::base *MakeTrans(matlab_ast::base *x)
	{
		return new matlab_ast::trans_expr(x);
	}

	matlab_ast::base *MakeNCTrans(matlab_ast::base *x)
	{
		return new matlab_ast::nctrans_expr(x);
	}

	matlab_ast::base *MakeCall(std::string &x, matlab_ast::base *y)
	{
		return new matlab_ast::call_expr(new matlab_ast::terminal_expr(x), y);
	}

	matlab_ast::base *MakeArgList(matlab_ast::base *x, matlab_ast::base *y)
	{
		return new matlab_ast::arg_list_expr(x, y);
	}

	matlab_ast::base *MakeIdentifier(std::string x)
	{
		return new matlab_ast::terminal_expr(x);
	}

	matlab_ast::base *MakeConstant(std::string x)
	{
		return new matlab_ast::terminal_expr(x);
	}

	matlab_ast::base *MakeParenExpr(matlab_ast::base *x)
	{
		return new matlab_ast::paren_expr(x);
	}
};

int main(int argc, char **argv)
{
	if(argc == 1){
		std::cerr << "usage: " << argv[0] << " MATLAB-expression" << std::endl;
		return 1;
	}

	SemanticAction sa;
	matlab_parser::Parser<matlab_ast::base*, SemanticAction> parser(sa);

	std::string expr = argv[1];
	scanner<std::string::iterator> s(expr.begin(), expr.end());

	matlab_parser::Token token;
	std::string v;

	for(;;){
		token = s.get(v);

		matlab_ast::base *p = nullptr;

		if(token == matlab_parser::token_Constant || token == matlab_parser::token_Identifier)
			p = new matlab_ast::terminal_expr(v);

		if(parser.post(token, p)){
			break;
		}
	}

	matlab_ast::base *ast;

	if(parser.accept(ast)){
		ast->to_cpp(std::cout);

		return 0;
	}

	return 1;
}
