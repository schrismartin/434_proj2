#include <vector>
#include <string>
#include <map>
#include <fstream>
#include <iostream>
#include <sstream>

using namespace std;

class Node {
	public:
		//Number of rounds participated in
		double t;
		//Number of rounds NOT participated in
		double not_t;

		//Friends
		vector < pair<int, double> > max;
		
		vector <double> O;
		vector <double> U;
		vector <double> V;

		Node();
};

//Number of messages in a round
const int b = 32;

//Converts "a0" etc into an actual index
int index(string &);

int main(int argc, char** argv) {
	ifstream fin;
	ofstream fout;
	Node *n;
	vector <int> send;
	vector <int> receive;
	vector <Node *> nodes;
	pair <int, double> temp;
	char c;
	int I;
	string s;

	if(argc != 3) {
		cout << "cmd line args: [input file] [output file]" << endl;
		return -1;
	}

	fin.open(argv[1]);
	fout.open(argv[2]);

	if(fin.fail() || fout.fail()) {
		cout << "Failed to open a file" << endl;
		return -2;
	}

	nodes.clear();

	//Create vector of nodes
	for(int i = 0; i < 260; i++) {
		n = new Node();
		nodes.push_back(n);
	}

	while(fin >> c) {
		//Prepare the message senders/receivers vectors
		send.resize(260, 0);
		receive.resize(260, 0);
	
		//If the node sent a message, mark it as 1 in send
		for(int i = 0; i < 32; i++) {
			fin >> s;
			send[index(s)] = 1;
		}

		//If the node sent a message, t += 1. Otherwise not_t += 1.
		for(int i = 0; i < send.size(); i++) {
			if(send[i] == 1) nodes[i]->t++;
			else nodes[i]->not_t++;
		}

		fin >> c;

		//If a node received a message, mark it as 1 in receive
		for(int i = 0; i < 32; i++) {
			fin >> s;
			receive[index(s)] = 1;
		}

		//If a node sent a message, incrememt all of the possible recipients
		//in its O vector. If it did not send a message then increment all 
		//of the recipients in its U vector which represents background noise
		for(int i = 0; i < send.size(); i++) {
			if(send[i] == 1) {
				for(int j = 0; j < receive.size(); j++) {
					nodes[i]->O[j] += receive[j];
				}
			}
			else {
				for(int j = 0; j < receive.size(); j++) {
					nodes[i]->U[j] += receive[j];
				}
			}
		}
	}
/*
	//FIXME
	for(int i = 0; i < nodes.size(); i++) {
		cout << "t = " << nodes[i]->t << " and t' = " << nodes[i]->not_t << endl;
		cout << "O = ";
		for(int j = 0; j < nodes[i]->O.size(); j++) {
			cout << nodes[i]->O[j] << " ";
		}
		cout << endl << endl;
		cout << "U = ";
		for(int j = 0; j < nodes[i]->U.size(); j++) {
			cout << nodes[i]->U[j] << " ";
		}
		cout << endl << endl;
	}
*/
	//Calculates the V vector for every node
	for(int i = 0; i < nodes.size(); i++) {
		for(int j = 0; j < 260; j++) {
			nodes[i]->V[j] = b * ((1.0/nodes[i]->t) * nodes[i]->O[j]) 
				- b * ((1.0/nodes[i]->not_t) * nodes[i]->U[j]);
		}
	}

	//Find the two maximum intries in V. These are "probably" the friends of
	//the given node.
	for(int i = 0; i < nodes.size(); i++) {
		nodes[i]->max[0] = make_pair(0, nodes[i]->V[0]);
		nodes[i]->max[1] = make_pair(1, nodes[i]->V[1]);
		
		if(nodes[i]->max[0].second > nodes[i]->max[1].second) {
			temp = nodes[i]->max[0];
			nodes[i]->max[0] = nodes[i]->max[1];
			nodes[i]->max[1] = temp;
		}

		for(int j = 2; j < 260; j++) {
			if(nodes[i]->V[j] > nodes[i]->max[0].second) {
				nodes[i]->max[0] = make_pair(j, nodes[i]->V[j]);
			}

			if(nodes[i]->max[0].second > nodes[i]->max[1].second) {
				temp = nodes[i]->max[0];
				nodes[i]->max[0] = nodes[i]->max[1];
				nodes[i]->max[1] = temp;
			}
		}
	}

	//Change the indexes back to letternumber references and print to
	//results file
	for(int i = 0; i < 260; i += 10) {
		c = 'a' + (i / 10);
		
		fout << c << '0' << ",";

		I = nodes[i]->max[1].first % 10;
		c = 'a' + ((nodes[i]->max[1].first - I) / 10);

		fout << c << I << ",";

		I = nodes[i]->max[0].first % 10;
		c = 'a' + ((nodes[i]->max[0].first - I) / 10);
		
		fout << c << I << endl;
	}

	fin.close();
	fout.close();

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

Node::Node() {
	O.resize(260, 0);
	U.resize(260, 0);
	V.resize(260, 0);
	max.resize(2);

	t = 0;
	not_t = 0;
}
