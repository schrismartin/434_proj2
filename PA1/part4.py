#!/usr/bin/env python

import hashlib
import base64
import sys

def hash( word ):
    match = "nLW1z+K3+rcEyKdIR7hOF0/1xyeObheY6NHjYLpIJ28c=" #Authentication string to match (Wireshark)
    username = "DereksDumbOpenSourceProgrammers"
    challengeString = "726685537" #Challenge string (Wireshark)
    
    h = hashlib.sha256()
    h.update(username)
    h.update(":")
    h.update(challengeString)
    h.update(":")
    h.update(word)

    crypt = h.digest()

    crypt_b64 = base64.b64encode(crypt)
   
    if crypt_b64 == match:
        print "Password is: {0}" .format(word)
        sys.exit(0)
    
def crunch( start, stop ):
    one_words = []
    two_words = []

    f = open("cracklib-ultrasmall", "r")
    for line in f:
        one_words.append(line[:-1])
    f.close()

    g = open("two_word", "r")
    for line in g:
        two_words.append(line[:-1])
    g.close()

    for double in range(start, stop):
        for single in one_words:
            hash(two_words[double] + single)



#Main Function
crunch( int(sys.argv[1]), int(sys.argv[2]) )
