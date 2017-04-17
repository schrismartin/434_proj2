#!/usr/bin/env python

from part4_h import *


f = open("cracklib-ultrasmall","r")

for line in f:
    password = scramble(line, classify(line))

    result = hash(password)

    if result == match:
        print "Password is: {0}" .format(password)
        sys.exit(0)

f.close()

sys.exit("No Match Found")
