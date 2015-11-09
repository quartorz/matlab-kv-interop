#pragma once

#include <cstdint>
#include <cmath>
#include <tuple>
#include <ostream>
#include <istream>
#include <vector>
#include <string>
#include <iterator>
#include <cassert>
#include <cstdint>

#include <boost/algorithm/string.hpp>
#include <boost/numeric/ublas/vector.hpp>

double pow2(int n)
{
	double x = 1.0;

	if(n > 0){
		while(n-- != 0)
			x *= 2.0;
	}else if(n < 0){
		while(n++ != 0)
			x /= 2.0;
	}

	return x;
}

double to_double(int sign, int exponent, ::std::uint64_t significand)
{
	return (sign == 1 ? -1 : 1) * ::pow2(exponent) * static_cast<double>(significand);
}

::std::tuple<int, int, ::std::uint64_t> decomp(double x)
{
	int sign = (::std::signbit(x) ? 1 : 0);

	if(::std::isinf(x))
		return ::std::make_tuple(sign, 2000, 0);

	x = ::std::abs(x);

	if(x < 1.0){
		int i = 0;

		while(::std::int64_t(x) != x){
			x *= 2.0;
			i--;
		}

		return ::std::make_tuple(sign, i, ::std::uint64_t(x));
	}else{
		int i = 0;

		while(x > 1.0){
			x /= 2.0;
			i++;
		}

		return ::std::make_tuple(sign, i - 53, ::std::uint64_t(x * ::pow2(53)));
	}
}

void out_double(double x, ::std::ostream &os)
{
	auto t = decomp(x);
	os << ::std::get<0>(t) << ',' << ::std::get<1>(t) << ',' << ::std::get<2>(t);
}

void out_vector(const ::boost::numeric::ublas::vector<double> &v, ::std::ostream &os)
{
	for(unsigned i = 0; i < v.size(); ++i){
		::out_double(v(i), os);
		if(i != v.size() - 1){
			os << ',';
		}
	}
}

::std::vector<double> parse_line(const ::std::string &line)
{
	::std::vector<::std::string> token;

	::boost::algorithm::split(
		token, line, ::boost::is_any_of(","),
		::boost::token_compress_on);

	::std::vector<::std::int64_t> v;

	::std::transform(
		token.begin(), token.end(),
		::std::back_inserter(v),
		[](const ::std::string &s){return ::std::stoll(s);}
	);

	if(v.size() % 3 != 0)
		return {};

	::std::vector<double> result;

	for(unsigned i = 0; i < v.size() / 3; ++i){
		result.push_back(::to_double(v[3 * i], v[3 * i + 1], v[3 * i + 2]));
	}

	return result;
}