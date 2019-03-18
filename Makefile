build:
	@echo "Building protoc-gen docker image"
	docker build -t protoc-gen:v2.0 -f ./Dockerfile .
