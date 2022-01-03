# To Build: docker build --no-cache -t pbui/cse-20289-sp22-assignments . < Dockerfile

FROM        ubuntu:20.04
MAINTAINER  Peter Bui <pbui@nd.edu>
ARG	    DEBIAN_FRONTEND=noninteractive

RUN         apt-get update -y -q

# Run-time dependencies
RUN         apt-get install -y -q python3-tornado python3-requests python3-yaml python3-markdown

# Shell utilities
RUN	    apt-get install -y -q curl bc netcat iproute2 zip unzip gawk

# Language Support: C, C++, Make, valgrind, cppcheck, strace
RUN         apt-get install -y -q gcc g++ make valgrind cppcheck strace
