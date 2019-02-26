# Zomato Proto Generator Docker
This docker compiles .proto into required languages compiled source code definations and then you can use special generated source code to easily write and read your structured data to and from a variety of data streams.

## ENV

* GRPC_VERSION - Specify the version of grpc to use.
* PROTOBUF_VERSION - Specify the version of protobuf to use.

## MISC
- Protobuf installed with grpc is replaced with the version installed according to our env PROTOBUF_VERSION.
- Uses UPX, It can do extremely fast in-place decompression, without any extra tools since it injects the decompressor into the binary itself. Reduces binary size by 15-20%


## USAGE 
After the image has been built, assuming with `protogen-img` tag. Ex

For Go
```
docker run --rm -v $(pwd):$(pwd) -w $(pwd) protogen-img --go_out=. -I. ./proto/$(dir)/*.proto)
```
For PHP
```
docker run --rm -v $(pwd):$(pwd) -w $(pwd) protogen-img --php_out=client -I. ./proto/$(dir)/*.proto)
```