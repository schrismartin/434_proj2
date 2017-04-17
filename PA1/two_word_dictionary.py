#!/usr/bin/env python

one_word = []
two_words = []

f = open("cracklib-ultrasmall", "r")
for line in f:
    one_word.append(line[:-1])
f.close()

for i in one_word:
    for j in one_word:
        two_words.append(i + j)

g = open("two_word", "w")
for word in two_words:
    g.write(word + "\n")
g.close()

