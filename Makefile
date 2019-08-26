ECR_REPOSITORY = 931301707529.dkr.ecr.ap-southeast-1.amazonaws.com/protoc-gen
VERSION_TAG = v1.1
AWS_DEFAULT_REGION = ap-southeast-1

build:
	@echo "Building protoc-gen docker image"
	docker build -t protoc-gen:${VERSION_TAG} -f ./Dockerfile .

push:
	aws ecr get-login --region $AWS_DEFAULT_REGION --no-include-email --profile $AWS_PROFILE | sh
	docker build -t ${ECR_REPOSITORY}:${VERSION_TAG} -t ${ECR_REPOSITORY}:latest ./Dockerfile .
	docker push ${ECR_REPOSITORY}:${VERSION_TAG}
	docker push ${ECR_REPOSITORY}:latest
