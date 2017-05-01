## Assignment 2
> "Dereks Dumb Open Source Programmers"

Jacob Meystrik and Chris Martin

Project on [GitHub](https://github.com/schrismartin/434_proj2/tree/submit/PA2)

### Part 1:
Part\_1.cpp generated part\_1\_results.txt
The rounds were parsed using parse1.cpp

### Part 2:
This is separated into `Python`, `C++`, and `Swift` sections. 

* `Data/peerfile.txt` has port number, id, and a short list of a few of the node's peers. This was a result of the Swift project, but `peers.cpp` does the same.
* `C++/part_2.cpp` is the refit attempt to take part 1 and make it work for the rounds generated with the Swift project.
* Items in the `Swift` project were used to construct peer graphs and listen to rounds. But because the swift code could only be run on Apple platforms (a major shortsight), Chris's laptop falling asleep while listening resulted in artifically small sets of data. 
*  Items in the `Data` directory generated and used in attempt to seed data for Part2.

### Part 3:
Same exact process as part 2, however, to identify private node senders/receivers the plan was:

1. Get a list of each private node's peers.
2. Create a binary vector from those peers.
3. Use XOR to perform an intersection and determine sender/receiver

### Closing Remarks
We got rolling on this too late. Chris had data gathering started on Friday night, but through several hiccups and (very wrong) assumptions was unable to collect the right amount of data to finish out Part 2. 