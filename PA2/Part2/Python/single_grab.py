#!/usr/bin/env python

import socket

port = 15112

HOST = '160.36.57.98'
TCP_PORT = port

bae = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
bae.connect_ex((HOST, TCP_PORT))

bae.send('PEERS\n')

data = bae.recv(1024)

bae.close()

print data
