# Use the official Ubuntu base image
FROM ubuntu:latest

# Set the working directory inside the container
WORKDIR /app

# Run update and install basic packages
RUN apt-get update && apt-get install -y \
    software-properties-common \
    && rm -rf /var/lib/apt/lists/*


RUN apt-get update
RUN apt-get -y upgrade
RUN   apt-get -y install sudo 
RUN sudo apt-get update
RUN sudo apt-get install build-essential curl zlib1g-dev libbz2-dev libcurl4-openssl-dev librdkafka-dev -y

WORKDIR /usr/src/app


RUN sudo apt-get install libtool-bin -y
RUN sudo apt-get install autotools-dev -y
RUN sudo apt-get install automake -y

WORKDIR /usr/src/app/src
RUN curl -LO https://github.com/LibtraceTeam/wandio/archive/refs/tags/4.2.4-1.tar.gz
RUN tar zxf 4.2.4-1.tar.gz
WORKDIR /usr/src/app/src/wandio-4.2.4-1
RUN sed 's/([^)]*)//g' bootstrap.sh > bootstrap1.sh
RUN sed 's/||//g' bootstrap1.sh > bootstrap2.sh
RUN sed 's/glibtoolize/libtoolize/g' bootstrap2.sh > bootstrap3.sh

RUN chmod +x bootstrap3.sh
RUN ./bootstrap3.sh
RUN ./configure
RUN make
RUN sudo make install
RUN sudo ldconfig

WORKDIR /usr/src/app/src
RUN curl -LO https://github.com/CAIDA/libbgpstream/releases/download/v2.2.0/libbgpstream-2.2.0.tar.gz
RUN tar zxf libbgpstream-2.2.0.tar.gz
WORKDIR /usr/src/app/src/libbgpstream-2.2.0/
RUN sed -i 's/pthread_yield/sched_yield/g' configure
RUN ./configure
RUN make
RUN make check
RUN sudo make install
RUN sudo ldconfig
RUN sudo apt-get install python3-pip -y
RUN pip3 install --user pybgpstream


WORKDIR /usr/src/app/local
VOLUME /usr/src/app/local

# Default command to execute when container starts
CMD ["bash"]
