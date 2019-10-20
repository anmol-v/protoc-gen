# Proto Generator

protoc-gen compiles .proto into language specific clients, supports gRPC.

Languages supported for client generation:

* Golang
* PHP
* Java

## Building the image

````sh
docker build -t protoc-gen:latest -f ./Dockerfile .
````

## ENV

* GRPC_VERSION - the version of grpc to use.
* GO_VERSION - version of go used to build protoc-gen-go
* PROTOC_GEN_GO_VERSION - the version of protoc-gen-go to use.
* GRPC_JAVA_VERSION - the version of grpc-java to use

## USAGE

After the image has been built (assuming `protoc-gen` image name):

For Go

````sh
docker run --rm -v $(pwd):$(pwd) -w $(pwd) protoc-gen:latest --go_out=. -I. ./proto/*.proto)
````

For PHP

````sh
docker run --rm -v $(pwd):$(pwd) -w $(pwd) protoc-gen:latest --php_out=./client/php/src --grpc_out=./client/php/src --plugin=protoc-gen-grpc=/usr/bin/grpc_php_plugin -I. ./proto/*.proto)
````
