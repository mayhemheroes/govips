FROM ubuntu:20.04 as builder

RUN ln -snf /usr/share/zoneinfo/$CONTAINER_TIMEZONE /etc/localtime && echo $CONTAINER_TIMEZONE > /etc/timezone

RUN DEBIAN_FRONTEND=noninteractive \
	apt-get update && apt-get install -y build-essential tzdata pkg-config \
	libglib2.0-dev libexpat1-dev wget

RUN wget https://github.com/libvips/libvips/releases/download/v8.13.2/vips-8.13.2.tar.gz
RUN tar xf vips-8.13.2.tar.gz
WORKDIR /vips-8.13.2
RUN ./configure
RUN make
RUN make install
WORKDIR /

RUN wget https://go.dev/dl/go1.19.1.linux-amd64.tar.gz
RUN rm -rf /usr/local/go && tar -C /usr/local -xzf go1.19.1.linux-amd64.tar.gz
ENV PATH=$PATH:/usr/local/go/bin

ADD . /govips
WORKDIR /govips
ADD harnesses/fuzz.go ./fuzz_newimage.go
RUN go get -u github.com/davidbyttow/govips/v2/vips
RUN go build fuzz_newimage.go
RUN mkdir ./testsuite
RUN wget https://github.com/strongcourage/fuzzing-corpus/blob/master/jpg/mozilla/1273601738_titanic2.jpg
RUN wget https://github.com/strongcourage/fuzzing-corpus/blob/master/jpg/mozilla/000_jpg.jpg
RUN wget https://github.com/strongcourage/fuzzing-corpus/blob/master/jpg/mozilla/1cbb1bb37d62c44f67374cd451643dc4.jpg
RUN wget https://github.com/strongcourage/fuzzing-corpus/blob/master/jpg/mozilla/1x1-low.jpg
RUN wget https://github.com/strongcourage/fuzzing-corpus/blob/master/jpg/mozilla/Hercules3.jpg
RUN wget https://github.com/strongcourage/fuzzing-corpus/blob/master/jpg/mozilla/MM_sw.jpg
RUN wget https://github.com/strongcourage/fuzzing-corpus/blob/master/jpg/mozilla/RabbitMech.jpg
RUN wget https://github.com/strongcourage/fuzzing-corpus/blob/master/jpg/mozilla/baboon.jpg
RUN wget https://github.com/strongcourage/fuzzing-corpus/blob/master/jpg/mozilla/custom.jpg 
RUN mv *.jpg ./testsuite/

#FROM golang:1.19.1-buster
FROM ubuntu:20.04
RUN ln -snf /usr/share/zoneinfo/$CONTAINER_TIMEZONE /etc/localtime && echo $CONTAINER_TIMEZONE > /etc/timezone
RUN DEBIAN_FRONTEND=noninteractive \
	apt-get update && apt-get install -y libglib2.0-dev libexpat1-dev
COPY --from=builder /govips/fuzz_newimage /
COPY --from=builder /govips/testsuite/*.jpg /testsuite/
COPY --from=builder /usr/local/lib/libvips* /usr/local/lib/
ENV LD_LIBRARY_PATH=/usr/local/lib

ENTRYPOINT ["/fuzz_newimage", "@@"]
