# Proto Generator
protoc-gen compiles .proto into language specific clients, supports gRPC.

## Building the image

Execute the below command to build and tag the image

````sh
$ make build
````

## ENV
* GRPC_VERSION - the version of grpc to use.
* PROTOBUF_VERSION - the version of protobuf to use.
* PROTOC_GEN_GO_VERSION - the version of protoc-gen-go to use.

## MISC
- Protobuf installed with grpc is replaced with the version installed according to our env PROTOBUF_VERSION.
- Uses UPX, It can do extremely fast in-place decompression, without any extra tools since it injects the decompressor into the binary itself. Reduces binary size by 15-20%

## USAGE
After the image has been built (assuming `protoc-gen` image name):

For Go
```
docker run --rm -v $(pwd):$(pwd) -w $(pwd) protoc-gen:v1.0 --go_out=. -I. ./proto/*.proto)
```

For PHP
```
docker run --rm -v $(pwd):$(pwd) -w $(pwd) protoc-gen:v1.0 --php_out=./client/php/src --grpc_out=./client/php/src --plugin=protoc-gen-grpc=/usr/bin/grpc_php_plugin -I. ./proto/*.proto)
```
