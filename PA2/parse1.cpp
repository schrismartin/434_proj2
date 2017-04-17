#include <cstdio>
#include <iostream>
#include <fstream>
#include <string>

using namespace std;

int main(int argc, char** argv) {
	int index;
	string input;
	string output;
	ifstream fin;
	ofstream fout;

	if(argc != 3) {
		printf("Usage: ./parse1 input-file output-file\n");
		return -1;
	}

	fin.open(argv[1]);
	if(fin.fail()) {
		printf("Failed to open input file\n");
		return -2;
	}


	fout.open(argv[2]);
	if(fout.fail()) {
		printf("Failed to open output file\n");
		return -2;
	}

	while(getline(fin, input)) {
		output = input;

		if(output.find(":['") != output.npos) {
			index = output.find(":['");
			output.erase(index, 3);
			output.insert(index, " ");
		}

		if(output.find("']") != output.npos) {
			index = output.find("']");
			output.erase(index, 2);
			output.insert(index, " ");
		}

		while(output.find("', '") != output.npos) {
			index = output.find("', '");
			output.erase(index, 4);
			output.insert(index, " ");
		}
		
		output += "\n";

		fout << output;
	}

	fin.close();
	fout.close();

	return 0;
}
