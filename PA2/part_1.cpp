#include <vector>
#include <string>
#include <fstream>
#include <iostream>
#include <sstream>

using namespace std;

int index(string &);

int main(int argc, char** argv) {
	ifstream fin;
	ofstream fout;

	vector <int> o;
	vector <int> u;

	o.resize(260, 0);
	u.resize(260, 0);



	return 0;
}

int index(string &s) {
	stringstream buff;
	string line = "";
	char c;
	int i;
	int rv = 0;

	line = s;

	line.insert(1, " ");

	buff.str(line);

	buff >> c >> i;

	rv += ((c - 'a') * 10);
	rv += i;

	return rv;
}
