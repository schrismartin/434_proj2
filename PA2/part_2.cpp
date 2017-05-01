#include <vector>
#include <set>
#include <map>
#include <string>
#include <fstream>
#include <iostream>
#include <sstream>

using namespace std;

struct Node {
	//holds number of rounds this node sent a message
	double t;
	//holds number of rounds this node did not send a message
	double not_t;

	//holds the two friends of this node and their associated value from V
	vector < pair<int, double> > max;

	//holds data from rounds where this node sent a messsage
	vector <double> O;
	//holds data from rounds where this node did not send a message
	vector <double> U;
	//holds calculated data from O and U
	vector <double> V;

	Node();
};

//port# - 15000 to get an index value
int index(int);

int main(int argc, char** argv) {
	ifstream fin;
	ofstream fout;
	Node *n;
	map <int, string> addr;
	set <string> OFFER;
	set <string> ACK;
	set <string> target;
	vector <int> send;
	vector <int> receive;
	vector <Node *> nodes;
	pair <int, double> temp;
	int temp_time, temp_port, b;
	string temp_str, temp_cmd, temp_msg, temp_id, temp_target;
	//start is manually initialized to the first time stamp in a round
	int start = 1493564660, stop = start + 270;

	if(argc != 3) {
		cout << "USAGE: executable input-file output-file" << endl;
		return -1;
	}

	//populate map with peers port/id association
	fin.open("peers.txt");

	addr.clear();

	while(fin >> temp_port >> temp_id) {
		addr.insert(make_pair(temp_port, temp_id));
	}

	fin.close();

	fin.open(argv[1]);
	fout.open(argv[2]);

	if(fin.fail() || fout.fail()) {
		cout << "Failed to open a file" << endl;
		return -2;
	}

	//insert our group's targets into a set
	target.insert("80ac0162e90eae1c36c0446f7a7f89e296a1de417a5d8d9e465e25ca161ccdff");
	target.insert("80e0c83007f53b5a8c74a605e058d470cd094e020fbbc230f608768da0d5cc3c");
	target.insert("809861145910ad5f541156e45579f5256d1abbfb51ec2f839a01742d0083ea1c");
	target.insert("806966aa3ff417c916fffc87046c7f886e3933577948de20f0dfa4a3ce513ff7");
	target.insert("8031c12184fdb93d734f0ee24cb4235250b83e7479b777ebe088703863330081");

	nodes.clear();

	//populate nodes vector
	for(int i = 0; i < 120; i++) {
		n = new Node();
		nodes.push_back(n);
	}

	//initialize values for reading the collection
	send.resize(240, 0);
	receive.resize(240, 0);

	OFFER.clear();
	ACK.clear();

	while(!fin.eof()) {
		//read the initial string
		fin >> temp_str;

		//NEW indicates we are hearing from a node (used to separate when nodes say lots of things in one go)
		if(temp_str == "NEW") {
			//read time stamp and the port we are hearing from
			fin >> temp_time >> temp_port;

			//this indicates we need to process the last round's data
			if(temp_time > stop) {
				//Gives us the max number of messages sent in a round
				if(OFFER.size() > b) b = OFFER.size();

				for(int i = 0; i < send.size(); i++) {
					//if a node sent a message then update its appropriate fields (t and O)
					if(send[i] == 1) {
						nodes[i]->t++;
						for(int j = 0; j < receive.size(); j++) {
							nodes[i]->O[j] += receive[j];
						}
					//otherwise update the other fields (not_t and U)
					} else {
						nodes[i]->not_t++;
						for(int j = 0; j < receive.size(); j++) {
							nodes[i]->U[j] += receive[j];
						}
					}
				}

				//reset values for next round
				send.resize(240, 0);
				receive.resize(240, 0);

				OFFER.clear();
				ACK.clear();

				//these times give a round 270 seconds to finish which should be sufficient since rounds occur every 300 seconds
				start = temp_time;
				stop = start + 270;
			}
		} else if(temp_str == "OFFER") {
			fin >> temp_msg;

			if(OFFER.find(temp_msg) != OFFER.end()) {
				send[index(temp_port)] = 1;
				OFFER.insert(temp_msg);
			}
		} else if(temp_str == "ACK") {
			fin >> temp_msg;

			if(ACK.find(temp_msg) != ACK.end()) {
				receive[index(temp_port)] = 1;
				ACK.insert(temp_msg);
			}
		}
	}

	//calculate the V vector for each node
	for(int i = 0; i < nodes.size(); i++) {
		for(int j = 0; j < nodes[i]->V.size(); j++) {
			nodes[i]->V[j] = b * ((1.0/nodes[i]->t) * nodes[i]->O[j]) 
				- b * ((1.0/nodes[i]->not_t) * nodes[i]->U[j]);
		}
	}

	//find the two maximum values in V, these are the friends
	for(int i = 0; i < nodes.size(); i++) {
		nodes[i]->max[0] = make_pair(0, nodes[i]->V[0]);
		nodes[i]->max[1] = make_pair(1, nodes[i]->V[1]);

		if(nodes[i]->max[0].second > nodes[i]->max[1].second) {
			temp = nodes[i]->max[0];
			nodes[i]->max[0] = nodes[i]->max[1];
			nodes[i]->max[1] = temp;
		}

		for(int j = 2; j < nodes[i]->V.size(); j++) {
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

	//print friends of targets to file
	for(int i = 0; i < nodes.size(); i++) {
		if(target.find(addr[i + 15000]) != target.end()) {
			fout << addr[i + 15000] << "," << addr[nodes[i]->max[0].first] << "," << addr[nodes[i]->max[1].first] << endl;
		}
	}


	return 0;
}

int index(int i) {
	return i - 15000;
}

Node::Node() {
	O.resize(240, 0);
	U.resize(240, 0);
	V.resize(240, 0);
	max.resize(2);

	t = 0;
	not_t = 0;
}
