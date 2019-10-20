FROM ubuntu:18.04 as builder

RUN apt-get -y update && \
        apt-get install -y build-essential automake autoconf libtool git pkg-config wget

ENV GRPC_VERSION=1.24.2 \
        OUTDIR=/out \
        PROTOC_GEN_GO_VERSION=1.3.2 \
        GRPC_JAVA_VERSION=1.24.0 \
        GO_VERSION=1.13.1 \
        GOROOT=/usr/local/go \
        GOPATH=/go \
        PATH=/usr/local/go/bin/:$PATH

# Install Go
RUN mkdir /go && \
        cd /go && \
        wget https://dl.google.com/go/go${GO_VERSION}.linux-amd64.tar.gz && \
        tar -xvzf *.tar.gz && \
        mv go /usr/local/

# Build gRPC core
RUN git clone --depth 1 --recursive -b v${GRPC_VERSION} https://github.com/grpc/grpc.git /grpc && \
        cd grpc && \
        git submodule update --init && \
        make && \
        make install-plugins prefix=${OUTDIR}/usr && \
        cd third_party/protobuf && \
        make install prefix=${OUTDIR}/usr

# build gRPC Go compiler
RUN mkdir -p ${GOPATH}/src/github.com/golang/protobuf /protoc-gen-go && \
    cd /protoc-gen-go && \
    wget https://github.com/golang/protobuf/archive/v${PROTOC_GEN_GO_VERSION}.tar.gz && \
    tar --strip 1 -C ${GOPATH}/src/github.com/golang/protobuf -xvzf *.tar.gz && \
    cd ${GOPATH}/src/github.com/golang/protobuf && \
    go build -ldflags '-w -s' -o /golang-protobuf-out/protoc-gen-go ./protoc-gen-go && \
    install -Ds /golang-protobuf-out/protoc-gen-go ${OUTDIR}/usr/bin/

# Build gRPC Java compiler
RUN mkdir -p /grpc-java && \
    cd /grpc-java && \
    wget https://github.com/grpc/grpc-java/archive/v${GRPC_JAVA_VERSION}.tar.gz && \
    tar --strip 1 -C /grpc-java -xvzf *.tar.gz && \
    g++ \
        -I. -I/grpc/third_party/protobuf/src \
        /grpc-java/compiler/src/java_plugin/cpp/*.cpp \
        -L/grpc/third_party/protobuf/src/.libs \
        -lprotoc -lprotobuf -lpthread --std=c++0x -s \
        -o protoc-gen-grpc-java && \
    install -Ds protoc-gen-grpc-java ${OUTDIR}/usr/bin/protoc-gen-grpc-java


########################
# Build final image
########################
FROM ubuntu:18.04

RUN apt-get -y update && apt-get install -y curl

COPY --from=builder /out/ /

# Add common base protos from google.protobuf and google.api namespaces
RUN mkdir -p /protobuf/google/protobuf && \
        for f in any duration descriptor empty struct timestamp wrappers; do \
        curl -L -o /protobuf/google/protobuf/${f}.proto https://raw.githubusercontent.com/google/protobuf/master/src/google/protobuf/${f}.proto; \
        done && \
        mkdir -p /protobuf/google/api && \
        for f in annotations http; do \
        curl -L -o /protobuf/google/api/${f}.proto https://raw.githubusercontent.com/grpc-ecosystem/grpc-gateway/master/third_party/googleapis/google/api/${f}.proto; \
        done && \
        chmod a+x /usr/bin/protoc

ENTRYPOINT ["/usr/bin/protoc"]
