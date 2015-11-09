#if defined(_MSC_VER)
# define _CRT_SECURE_NO_WARNINGS
# define _SCL_SECURE_NO_WARNINGS
#endif

#include <fstream>
#include <string>
#include <cmath>
#include <vector>
#include <algorithm>

#include <boost/algorithm/string.hpp>
#include <boost/numeric/ublas/vector.hpp>

#include <kv/affine.hpp>

#include <conv.hpp>

int main(int argc, char **argv)
{
	if(argc < 4){
		std::cout << "invalid argument" << std::endl;
		return 1;
	}

	std::ifstream input(argv[1]);
	std::ofstream output(argv[2]);

	if(!input || !output){
		return 1;
	}

	std::string line;

	if(!std::getline(input, line)){
		return 1;
	}

	auto l = parse_line(line);

	std::vector<std::vector<double>> matrix(l.size());

	for(unsigned i = 0; i < l.size(); ++i){
		matrix[i].reserve(100);
		matrix[i].push_back(l[i]);
	}

	while(std::getline(input, line)){
		l = parse_line(line);

		if(matrix.size() != l.size())
			return 1;

		for(unsigned i = 0; i < l.size(); ++i){
			matrix[i].push_back(l[i]);
		}
	}

	boost::numeric::ublas::vector<kv::affine<double>> a(matrix.size());

	for(unsigned i = 0; i < matrix.size(); ++i){
		a[i].a.resize(matrix[i].size());

		kv::affine<double>::maxnum() = std::max<int>(kv::affine<double>::maxnum(), matrix[i].size());

		for(unsigned j = 0; j < matrix[i].size(); ++j){
			a(i).a(j) = matrix[i][j];
		}
	}

	int maxnum = std::stoi(argv[3]);
	kv::epsilon_reduce(a, maxnum, maxnum);

	for(int i = 0; i < kv::affine<double>::maxnum(); ++i){
		unsigned count = 0;

		for(unsigned j = 0; j < a.size(); ++j){
			if(i < a(j).a.size()){
				count++;
				out_double(a(j).a(i), output);
			}else{
				out_double(0.0, output);
			}

			if(j == a.size() - 1){
				output << std::endl;
			}else{
				output << ',';
			}
		}

		if(count != a.size())
			break;
	}

	return 0;
}
