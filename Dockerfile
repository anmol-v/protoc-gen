FROM alpine:3.8 as protoc_builder
RUN apk add --no-cache build-base curl automake autoconf libtool git zlib-dev

ENV GRPC_VERSION=1.16.0 \
        PROTOBUF_VERSION=3.6.1 \
        OUTDIR=/out \
        PROTOC_GEN_GO_VERSION=1.3.1 \
        GRPC_JAVA_VERSION=1.21.0
RUN mkdir -p /protobuf && \
        curl -L https://github.com/google/protobuf/archive/v${PROTOBUF_VERSION}.tar.gz | tar xvz --strip-components=1 -C /protobuf
RUN git clone --depth 1 --recursive -b v${GRPC_VERSION} https://github.com/grpc/grpc.git /grpc && \
        rm -rf grpc/third_party/protobuf && \
        ln -s /protobuf /grpc/third_party/protobuf
RUN cd /protobuf && \
        autoreconf -f -i -Wall,no-obsolete && \
        ./configure --prefix=/usr --enable-static=no && \
        make -j2 && make install
RUN cd grpc && \
        make -j2 plugins
RUN cd /protobuf && \
        make install DESTDIR=${OUTDIR}
RUN cd /grpc && \
        make install-plugins prefix=${OUTDIR}/usr
RUN find ${OUTDIR} -name "*.a" -delete -or -name "*.la" -delete

RUN apk add --no-cache go
ENV GOPATH=/go \
        PATH=/go/bin/:$PATH

RUN mkdir -p ${GOPATH}/src/github.com/golang/protobuf && \
    curl -sSL https://github.com/golang/protobuf/archive/v${PROTOC_GEN_GO_VERSION}.tar.gz | tar -xz --strip 1 -C ${GOPATH}/src/github.com/golang/protobuf &&\
    cd ${GOPATH}/src/github.com/golang/protobuf && \
    go build -ldflags '-w -s' -o /golang-protobuf-out/protoc-gen-go ./protoc-gen-go && \
    install -Ds /golang-protobuf-out/protoc-gen-go ${OUTDIR}/usr/bin/

RUN mkdir -p /grpc-java && \
    curl -sSL https://github.com/grpc/grpc-java/archive/v${GRPC_JAVA_VERSION}.tar.gz | tar xz --strip 1 -C /grpc-java && \
    cd /grpc-java && \
    g++ \
        -I. -I/protobuf/src \
        /grpc-java/compiler/src/java_plugin/cpp/*.cpp \
        -L/protobuf/src/.libs \
        -lprotoc -lprotobuf -lpthread --std=c++0x -s \
        -o protoc-gen-grpc-java && \
    install -Ds protoc-gen-grpc-java ${OUTDIR}/usr/bin/protoc-gen-grpc-java

FROM znly/upx as packer
COPY --from=protoc_builder /out/ /out/
RUN upx --lzma \
        /out/usr/bin/protoc \
        /out/usr/bin/grpc_*

FROM alpine:3.7
RUN apk add --no-cache libstdc++
COPY --from=packer /out/ /
RUN apk add --no-cache curl && \
        mkdir -p /protobuf/google/protobuf && \
        for f in any duration descriptor empty struct timestamp wrappers; do \
        curl -L -o /protobuf/google/protobuf/${f}.proto https://raw.githubusercontent.com/google/protobuf/master/src/google/protobuf/${f}.proto; \
        done && \
        mkdir -p /protobuf/google/api && \
        for f in annotations http; do \
        curl -L -o /protobuf/google/api/${f}.proto https://raw.githubusercontent.com/grpc-ecosystem/grpc-gateway/master/third_party/googleapis/google/api/${f}.proto; \
        done && \
        apk del curl && \
        chmod a+x /usr/bin/protoc

ENTRYPOINT ["protoc"]