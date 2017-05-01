#!/usr/bin/env python

import socket
import errno

class node:
    def __init__(self, string):
        line = string.lstrip("\n")
        one = line.find("8")
        two = line.find("@")
        three = two + 1
        four = line.find(":")
        five = four + 1
        six = line.find("\n")

        string1 = line[one:two]
        string2 = line[three:four]
        string3 = line[five:six]

        self.name = string1
        self.addr = string2
        self.port = int(string3)

        try:
            s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            s.connect((self.addr, self.port))
        except socket.error as e:
            if e.errno == errno.ECONNREFUSED:
                self.status = 0
            else:
                raise
        else:
            self.status = 1
            s.close()

"""    def peer(self):
        if self.status == 0:
            print "Cannot call .peer() on a private node\n"
            return
        else:
            s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            s.connect((self.addr, self.port))

            s.send('PEERS\n')

            peer = node(s.recv(1024))

            s.close()

            return peer
"""

nodes = []
ports = []
i = 0
totalNodes = 240

BASE_HOST = '160.36.57.98'
BASE_PORT = 15112

bae = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
bae.connect((BASE_HOST, BASE_PORT))

bae.send('PEERS\n')

data = node(bae.recv(1024))

while data.status == 0:
    bae.send('PEERS\n')
    data = node(bae.recv(1024))

nodes.append(data)

bae.close()

while len(nodes) < totalNodes:
    n = nodes[i]
    print "node {} has port {}" .format(i, n.port)

    if n.status == 0:
        i = i + 1
        continue
    else:
        temp = []
        
        s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        s.connect((n.addr, n.port))

        while len(temp) < 20:
            s.send('PEERS\n')

            peer = node(s.recv(1024))

            if peer.port not in temp:
                temp.append(peer.port)

                if peer.port not in ports:
                    ports.append(peer.port)
                    nodes.append(peer)
        
        s.close()

        i = i + 1
                    
for n in nodes:
    print "{} {} {}" .format(n.name, n.port, n.status)
