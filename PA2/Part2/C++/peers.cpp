#include <sstream>
#include <fstream>
#include <iostream>
#include <string>

using namespace std;

int main() {
	ifstream fin;
	ofstream fout;
	string line, id;
	int port;
	stringstream ss;

	fin.open("peers.txt");
	fout.open("output_peers.txt");

	while(getline(fin, line)) {
		ss.str(line);

		ss >> port >> id;

		fout << port << " " << id << endl;
	}

	fin.close();
	fout.close();


	return 0;
}
