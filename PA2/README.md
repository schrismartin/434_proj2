Part 1:
Part_1.cpp generated part_1_results.txt
The rounds were parsed using parse1.cpp

Part 2:
peers.txt holds the pairings between port and id and was parsed using peers.cpp
Part_2.cpp is the refit attempt to take part 1 and make it work for the self generated rounds

Part 3:
Same exact process as part 2, however, to identify private node senders/receivers the plan was
1. Get a list of each private node's peers.
2. Create a binary vector from those peers.
3. Use XOR to perform an intersection and determine sender/receiver
