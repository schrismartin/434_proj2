#!/usr/bin/env python

import hashlib
import base64

def hash( word ):
    match = "" #Hashed authentication string from Wireshark

    username = "DereksDumbOpenSourceProgrammers"
    challengeString = "" #Challenge string from Wireshark

    h = hashlib.sha256()
    h.update(username)
    h.update(":")
    h.update(challengeString)
    h.update(":")
    h.update(word)

    crypt = h.digest()

    b64_crypt = base64.b64encode(crypt)

    return b64_crypt

def classify( word ):
    for
