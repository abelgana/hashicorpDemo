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
	cd app; bazel build generated/go-server:push_go_server_image --define tag=$(tag) --platforms=@io_bazel_rules_go//go/toolchain:linux_amd64 && bazel-bin/cmd/titanic-server/push_titanic

build-binary:
	cd app; bazel build generated/go-server:go-server

run:
	bazel-bin/generated/go-server/darwin_amd64_stripped/go-server

infra:
	cd infra; terraform init infra
	cd infra; terraform plan -out plan
	cd infra; terraform apply infra
	cd infra; terraform output kube_config > ~/.kube/config

helm_init:
	kubectl -n kube-system create sa tiller
	kubectl create clusterrolebinding tiller --clusterrole cluster-admin --serviceaccount=kube-system:tiller
	helm init --service-account tiller --upgrade

deploy_ingress:
	helm install --name ingress stable/nginx-ingress --namespace kube-system --set controller.replicaCount=2
