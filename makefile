all: docker-build docker-push tf-deploy
deploy: all
$(eval IMG_NAME=$(shell (terraform output | grep repository_name | sed 's/"//g' | awk '{print $$3}')))
$(eval CLUSTER=$(shell (terraform output | grep cluster_name | sed 's/"//g' | awk '{print $$3}')))
$(eval SERVICE=$(shell (terraform output | grep service_name | sed 's/"//g' | awk '{print $$3}')))
$(eval AWS_REGION=$(shell (terraform output | grep region | sed 's/"//g' | awk '{print $$3}')))
$(eval AWS_ACCOUNT_ID=$(shell aws sts get-caller-identity --query Account --output text))
$(eval REV=$(shell git rev-parse HEAD | cut -c1-7))
$(eval REG=$(AWS_ACCOUNT_ID).dkr.ecr.$(AWS_REGION).amazonaws.com)
$(eval REPO=$(REG)/$(IMG_NAME))

# Login to ECR
ecr-login:
	aws ecr get-login-password --region $(AWS_REGION) | docker login --password-stdin --username AWS $(REG)

# Build and tag docker image
docker-build:
	docker build --no-cache -t $(IMG_NAME) .

# Push docker image
docker-push: ecr-login
	docker tag $(IMG_NAME):latest $(REPO):latest
	docker tag $(IMG_NAME):latest $(REPO):$(REV)
	docker push $(REPO):latest
	docker push $(REPO):$(REV)

initialize: 
	terraform init
	terraform apply -auto-approve
	@echo "Update main.tf 'image' variable with '${REPO}:latest' then run 'make deploy'"

tf-deploy:
	terraform apply -auto-approve

tf-destroy:
	terraform destroy