# NATS & NATS Streaming - C Client
A C client for the [NATS messaging system](https://nats.io).

Refer to unforked  README.md for all the important information

This project simply builds on windows with support for streaming.  Some fella 
thought it was a swell idea to abandon windows support for protobuf-c on windows so 
instead of figuring that out we just copy the 2 source files into this project 
(admittedly in more places that we SHOULD) and then build.  Problem solved.  
Included is a batch file (build-nats.bat) and an upated CMakeLists.txt that 
conditionally includes the protobuf-c on unix only.


