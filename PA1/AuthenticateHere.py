#!/usr/bin/env python

import socket

#set variables for server connection
TCP_IP = '127.0.0.1'
TCP_PORT = 2017
BUFFER = 1024

#create socket for server and listen for Alice
s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.bind((TCP_IP, TCP_PORT))
s.listen(1)

#connect to Alice
conn, addr = s.accept()
print 'Connection address: ', addr

#set variables for client connection
HOST = 'taranis.eecs.utk.edu'
TCP_PORT = 15153

#connect to Bob
t = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
t.connect((HOST, TCP_PORT))

#get challenge string from Bob
challenge = t.recv(BUFFER)
print 'Received challenge string: ', challenge

#send challenge string to Alice
conn.send(challenge)

#get authentication string from Alice
authentication = conn.recv(BUFFER)
print 'Authentication message is: ', authentication

#close connection with Alice. We don't need her anymore. MUAHAHA
conn.close()

#send Bob the proper authentication string for his challenge
t.send(authentication)

#get secret from bob and print
secret = t.recv(BUFFER)
print 'THE SECRET IS: ', secret

#close connection to Bob. All has gone according to plan. *insert ultimate evil laugh*
t.close()
