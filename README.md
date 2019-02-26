# Proto Generator
protoc-gen compiles .proto into language specific clients, supports gRPC.

## ENV
* GRPC_VERSION - the version of grpc to use.
* PROTOBUF_VERSION - the version of protobuf to use.

## MISC
- Protobuf installed with grpc is replaced with the version installed according to our env PROTOBUF_VERSION.
- Uses UPX, It can do extremely fast in-place decompression, without any extra tools since it injects the decompressor into the binary itself. Reduces binary size by 15-20%


## USAGE 
After the image has been built (assuming `protoc-gen` image name):

For Go
```
docker run --rm -v $(pwd):$(pwd) -w $(pwd) protogen-img --go_out=. -I. ./proto/$(dir)/*.proto)
```

For PHP
```
docker run --rm -v $(pwd):$(pwd) -w $(pwd) protogen-img --php_out=client -I. ./proto/$(dir)/*.proto)
```
