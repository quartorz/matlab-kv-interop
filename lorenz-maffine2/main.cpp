// eliminate deprecation warnings
#if defined(_MSC_VER)
# define _CRT_SECURE_NO_WARNINGS
# define _SCL_SECURE_NO_WARNINGS
#endif

#include <cstdlib>
#include <iostream>
#include <fstream>
#include <utility>

#include <boost/numeric/ublas/vector.hpp>

#include <kv/affine.hpp>
#include <kv/rdouble.hpp>
#include <kv/ode-maffine2.hpp>
#include <kv/ode-param.hpp>
#include <kv/ode-callback.hpp>

#include <conv.hpp>

struct func{
	::kv::interval<double> sigma, rho, beta;

	func(
		const ::kv::interval<double> &sigma,
		const ::kv::interval<double> &rho,
		const ::kv::interval<double> &beta
	)
		: sigma(sigma)
		, rho(rho)
		, beta(beta)
	{
	}

	template<typename T>
	::boost::numeric::ublas::vector<T> operator()(
		const ::boost::numeric::ublas::vector<T> &u,
		const T &t
	) const
	{
		const T &x = u(0);
		const T &y = u(1);
		const T &z = u(2);

		::boost::numeric::ublas::vector<T> return_value(3);

		return_value(0) = sigma * (y - x);
		return_value(1) = x * (rho - z) - y;
		return_value(2) = x * y - beta * z;

		return return_value;
	}
};

int main(int argc, char **argv)
{
	if(argc < 48){
		::std::cout << "invalid argument" << ::std::endl;
		return 1;
	}

	::std::ofstream ofs(argv[1]);
	if(!ofs){
		::std::cout << "cannot open file '" << argv[1] << '\'' << ::std::endl;
		return 1;
	}

	ofs.setf(ofs.scientific);
	ofs.precision(17);

	::kv::interval<double> t_last(
		::todouble(::std::strtol(argv[6], nullptr, 10), ::std::strtol(argv[7], nullptr, 10), ::std::strtoull(argv[8], nullptr, 10)),
		::todouble(::std::strtol(argv[9], nullptr, 10), ::std::strtol(argv[10], nullptr, 10), ::std::strtoull(argv[11], nullptr, 10)));

	::boost::numeric::ublas::vector<::kv::affine<double>> u(3);

	u(0) = ::kv::interval<double>(
		::todouble(::std::strtol(argv[12], nullptr, 10), ::std::strtol(argv[13], nullptr, 10), ::std::strtoull(argv[14], nullptr, 10)),
		::todouble(::std::strtol(argv[15], nullptr, 10), ::std::strtol(argv[16], nullptr, 10), ::std::strtoull(argv[17], nullptr, 10)));

	u(1) = ::kv::interval<double>(
		::todouble(::std::strtol(argv[18], nullptr, 10), ::std::strtol(argv[19], nullptr, 10), ::std::strtoull(argv[20], nullptr, 10)),
		::todouble(::std::strtol(argv[21], nullptr, 10), ::std::strtol(argv[22], nullptr, 10), ::std::strtoull(argv[23], nullptr, 10)));

	u(2) = ::kv::interval<double>(
		::todouble(::std::strtol(argv[24], nullptr, 10), ::std::strtol(argv[25], nullptr, 10), ::std::strtoull(argv[26], nullptr, 10)),
		::todouble(::std::strtol(argv[27], nullptr, 10), ::std::strtol(argv[28], nullptr, 10), ::std::strtoull(argv[29], nullptr, 10)));

	::kv::interval<double> sigma(
		::todouble(::std::strtol(argv[30], nullptr, 10), ::std::strtol(argv[31], nullptr, 10), ::std::strtoull(argv[32], nullptr, 10)),
		::todouble(::std::strtol(argv[33], nullptr, 10), ::std::strtol(argv[34], nullptr, 10), ::std::strtoull(argv[35], nullptr, 10)));

	::kv::interval<double> rho(
		::todouble(::std::strtol(argv[36], nullptr, 10), ::std::strtol(argv[37], nullptr, 10), ::std::strtoull(argv[38], nullptr, 10)),
		::todouble(::std::strtol(argv[39], nullptr, 10), ::std::strtol(argv[40], nullptr, 10), ::std::strtoull(argv[41], nullptr, 10)));

	::kv::interval<double> beta(
		::todouble(::std::strtol(argv[42], nullptr, 10), ::std::strtol(argv[43], nullptr, 10), ::std::strtoull(argv[44], nullptr, 10)),
		::todouble(::std::strtol(argv[45], nullptr, 10), ::std::strtol(argv[46], nullptr, 10), ::std::strtoull(argv[47], nullptr, 10)));

	::outdouble(0.0, ofs);
	ofs << ',';
	::outdouble(0.0, ofs);
	ofs << ',';
	::outdouble(to_interval(u(0)).lower(), ofs);
	ofs << ',';
	::outdouble(to_interval(u(0)).upper(), ofs);
	ofs << ',';
	::outdouble(to_interval(u(1)).lower(), ofs);
	ofs << ',';
	::outdouble(to_interval(u(1)).upper(), ofs);
	ofs << ',';
	::outdouble(to_interval(u(2)).lower(), ofs);
	ofs << ',';
	::outdouble(to_interval(u(2)).upper(), ofs);
	ofs << ::std::endl;

	int order = ::std::strtol(argv[2], nullptr, 10);
	int itermax = ::std::strtol(argv[3], nullptr, 10);
	int ep_reduce = ::std::strtol(argv[4], nullptr, 10);
	int ep_reduce_limit = ::std::strtol(argv[5], nullptr, 10);

	func f(sigma, rho, beta);
	::kv::interval<double> t1(0.0);

	auto param = ::kv::ode_param<double>()
	                 .set_order(order)
	                 .set_autostep(false)
	                 .set_ep_reduce(ep_reduce)
	                 .set_ep_reduce_limit(ep_reduce_limit);
	int r;

	for(int i = 0; i < itermax; i++){
		::kv::interval<double> t2 = t_last * (i + 1) / itermax;

		r = ::kv::ode_maffine2(
			f,
			u,
			t1,
			t2,
			param);

		::outdouble(t2.lower(), ofs);
		ofs << ',';
		::outdouble(t2.upper(), ofs);
		ofs << ',';
		::outdouble(to_interval(u(0)).lower(), ofs);
		ofs << ',';
		::outdouble(to_interval(u(0)).upper(), ofs);
		ofs << ',';
		::outdouble(to_interval(u(1)).lower(), ofs);
		ofs << ',';
		::outdouble(to_interval(u(1)).upper(), ofs);
		ofs << ',';
		::outdouble(to_interval(u(2)).lower(), ofs);
		ofs << ',';
		::outdouble(to_interval(u(2)).upper(), ofs);
		ofs << ::std::endl;

		if(r != 2) break;

		t1 = t2;
	}

	return (r != 0) ? 0 : 2;
}
