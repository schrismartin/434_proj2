#!/usr/bin/env python

import hashlib
import base64

match = "quG7Y2qEtJkMR9+BLdTa8XEcIYr42vAnhK1T97qafGY=" #hashed authentication string from Wireshark

username = "DereksDumbOpenSourceProgrammers"
challengeString = "1282016162" #challenge string from Wireshark

f = open("cracklib-small","r")

for line in f:
    h = hashlib.sha256()
    h.update(username)
    h.update(":")
    h.update(challengeString)
    h.update(":")
    h.update(line[:-1])

    crypt = h.digest()

    temp = base64.b64encode(crypt)

    if temp == match:
        print "Password is: {0}" .format(line)

f.close()
