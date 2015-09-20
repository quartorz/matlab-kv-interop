#pragma once

#include <ostream>
#include <memory>
#include <string>
#include <utility>

namespace matlab_ast{
	struct base{
		virtual ~base(){}
		virtual void to_cpp(::std::ostream &os) = 0;
	};

	class expr : public base{
	};

	class or_expr : public expr{
		::std::unique_ptr<base> lhs, rhs;

	public:
		or_expr(base *l, base *r)
			: lhs(l), rhs(r)
		{
		}

		void to_cpp(::std::ostream &os) override
		{
			lhs->to_cpp(os);
			os << '|';
			rhs->to_cpp(os);
		}
	};

	class and_expr : public expr{
		::std::unique_ptr<base> lhs, rhs;

	public:
		and_expr(base *l, base *r)
			: lhs(l), rhs(r)
		{
		}

		void to_cpp(::std::ostream &os) override
		{
			lhs->to_cpp(os);
			os << '&';
			rhs->to_cpp(os);
		}
	};

	class relational_expr : public expr{
		::std::unique_ptr<base> lhs, rhs;
		::std::string op;

	public:
		relational_expr(base *l, base *r, ::std::string o)
			: lhs(l), rhs(r), op(::std::move(o))
		{
		}

		void to_cpp(::std::ostream &os) override
		{
			lhs->to_cpp(os);
			os << op;
			rhs->to_cpp(os);
		}
	};

	class arithmetic_expr : public expr{
		::std::unique_ptr<base> lhs, rhs;
		::std::string op;

	public:
		arithmetic_expr(base *l, base *r, ::std::string o)
			: lhs(l), rhs(r), op(::std::move(o))
		{
		}

		void to_cpp(::std::ostream &os) override
		{
			lhs->to_cpp(os);
			os << op;
			rhs->to_cpp(os);
		}
	};

	class binary_expr : public expr{
		::std::unique_ptr<base> lhs, rhs;
		::std::string op;

	public:
		binary_expr(base *l, base *r, ::std::string o)
			: lhs(l), rhs(r), op(::std::move(o))
		{
		}

		void to_cpp(::std::ostream &os) override
		{
			os << op << '(';
			lhs->to_cpp(os);
			os << ',';
			rhs->to_cpp(os);
			os << ')';
		}
	};

	class unary_expr : public expr{
		::std::unique_ptr<base> ex;
		::std::string op;

	public:
		unary_expr(base *e, ::std::string o)
			: ex(e), op(::std::move(o))
		{
		}

		void to_cpp(::std::ostream &os) override
		{
			os << op;
			ex->to_cpp(os);
		}
	};

	class call_expr : public expr{
		::std::unique_ptr<base> id, arg;

	public:
		call_expr(base *i, base *a)
			: id(i), arg(a)
		{
		}

		void to_cpp(::std::ostream &os) override
		{
			id->to_cpp(os);
			os << '(';
			arg->to_cpp(os);
			os << ')';
		}
	};

	class arg_list_expr : public expr{
		::std::unique_ptr<base> lhs, rhs;

	public:
		arg_list_expr(base *l, base *r)
			: lhs(l), rhs(r)
		{
		}

		void to_cpp(::std::ostream &os) override
		{
			lhs->to_cpp(os);
			os << ',';
			rhs->to_cpp(os);
		}
	};

	class trans_expr : public expr{
		::std::unique_ptr<base> ex;

	public:
		trans_expr(base *e)
			: ex(e)
		{
		}

		void to_cpp(::std::ostream &os) override
		{
			os << "conj(trans(";
			ex->to_cpp(os);
			os << "))";
		}
	};

	class nctrans_expr : public expr{
		::std::unique_ptr<base> ex;

	public:
		nctrans_expr(base *e)
			: ex(e)
		{
		}

		void to_cpp(::std::ostream &os) override
		{
			os << "trans(";
			ex->to_cpp(os);
			os << ')';
		}
	};

	class paren_expr : public expr{
		::std::unique_ptr<base> ex;

	public:
		paren_expr(base *e)
			: ex(e)
		{
		}

		void to_cpp(::std::ostream &os) override
		{
			os << '(';
			ex->to_cpp(os);
			os << ')';
		}
	};

	class terminal_expr : public expr{
		::std::string id;

	public:
		terminal_expr(::std::string i)
			: id(::std::move(i))
		{
		}

		void to_cpp(::std::ostream &os) override
		{
			os << id;
		}

		const std::string &get_content() const
		{
			return id;
		}
	};
}
