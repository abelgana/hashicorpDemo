SWAGGER := java -jar tools/swagger-codegen-cli-2.4.7.jar

.PHONY: swagger swagger-validate swagger-gen get-deps infra

swagger: swagger-validate swagger-gen
tag= $(shell git rev-parse HEAD:app)

swagger-validate:
	$(SWAGGER) validate -i app/swagger/swagger.yml

swagger-gen:
	$(SWAGGER) generate -i app/swagger/swagger.yml -l go -o app/generated/go
	$(SWAGGER) generate -i app/swagger/swagger.yml -l go-server -o app/generated/go-server

build-docker:
	cd app; bazel build generated/go-server:push_go_server_image --define tag=$(tag) --platforms=@io_bazel_rules_go//go/toolchain:linux_amd64 && bazel-bin/generated/go-server/push_go_server_image

build-binary:
	cd app; bazel build generated/go-server:go-server

run:
	bazel-bin/generated/go-server/darwin_amd64_stripped/go-server

infra:
	cd infra; terraform init
	cd infra; terraform plan -var ARM_CLIENT_ID=${ARM_CLIENT_ID} -var ARM_CLIENT_SECRET=${ARM_CLIENT_SECRET} -var ARM_SUBSCRIPTION_ID=${ARM_SUBSCRIPTION_ID} -var ARM_TENANT_ID=${ARM_TENANT_ID} -out plan
	cd infra; terraform apply plan
	cd infra; terraform output kube_config > ~/.kube/config

destroy:
	cd infra; terraform destroy -var ARM_CLIENT_ID=${ARM_CLIENT_ID} -var ARM_CLIENT_SECRET=${ARM_CLIENT_SECRET} -var ARM_SUBSCRIPTION_ID=${ARM_SUBSCRIPTION_ID} -var ARM_TENANT_ID=${ARM_TENANT_ID}
