terraformBuilder = 'abelgana/terraformbuilder:2.0.3'

pipeline {
  agent any

  options {
    ansiColor('xterm')
  }

  environment {
    ARM_CLIENT_SECRET = credentials('ARM_CLIENT_SECRET')
    ARM_CLIENT_ID = credentials('ARM_CLIENT_ID')
    ARM_TENANT_ID = credentials('ARM_TENANT_ID')
    ARM_SUBSCRIPTION_ID = credentials('ARM_SUBSCRIPTION_ID')
    AWS_ACCESS_KEY_ID = credentials('AWS_ACCESS_KEY_ID')
    AWS_SECRET_ACCESS_KEY = credentials ('AWS_SECRET_ACCESS_KEY')
    DOCKER_HUB_CREDS = credentials('DOCKER_HUB_CREDS')
  }

  stages {
    stage('Application Packaging') {
      agent {
        docker {
          image 'gcr.io/cloud-builders/bazel'
          args '--entrypoint=\'\''
        }
      }
      when {
        environment name: 'PACKAGE', value: 'true'
      }
      input {
        message "Package applicaiton?"
        id "PACKAGE"
        parameters {
          booleanParam(
            name: 'PACKAGE',
            defaultValue: false,
            description: 'If set the application will be packaged.'
          )
        }
      }
      steps {
        dir("app") {
          echo 'Packaging....'
          sh 'tag=$(git rev-parse HEAD:app) && \
              bazel build generated/go-server:push_go_server_image \
                --define tag=${tag} \
                --platforms=@io_bazel_rules_go//go/toolchain:linux_amd64 \
                --host_force_python=PY2 && \
              docker login \
                -u ${DOCKER_HUB_CREDS_USR} \
                -p ${DOCKER_HUB_CREDS_PSW} && \
              bazel-bin/generated/go-server/push_go_server_image'
        }
      }
    }
    stage('Infrastructure') {
      agent {
        docker {
          image terraformBuilder
          args '-e TF_IN_AUTOMATION=1 --entrypoint=\'\''
        }
      }
      stages {
        stage('Infrastructure Planning') {
          steps {
            dir ('infra') {
              echo 'Planning....'
              sh 'terraform init -backend-config workspace_key_prefix=${JOB_NAME}'
              sh 'terraform plan -out=plan \
                    -var ARM_CLIENT_ID=${ARM_CLIENT_ID} \
                    -var ARM_CLIENT_SECRET=${ARM_CLIENT_SECRET} \
                    -var ARM_SUBSCRIPTION_ID=${ARM_SUBSCRIPTION_ID} \
                    -var ARM_TENANT_ID=${ARM_TENANT_ID}'
            }
          }
        }
        stage('Infrastructure Provisioning') {
          when {
            environment name: 'PROVISION', value: 'true'
          }
          input {
            message "Provision to production?"
            id "PROVISION"
            parameters {
              booleanParam(
                name: 'PROVISION',
                defaultValue: false,
                description: 'If set the provided plan will be executed.'
              )
            }
          }
          steps {
            dir ('infra') {
              echo 'Provisioning....'
              sh 'terraform apply plan'
              timeout(time: 20, unit: 'MINUTES') {
                try {
                  sh 'kubectl --kubeconfig=kube_config get secret hashicorp-demo-postgres-secret'
                } catch(error) {
                  sh 'sleep 60'
                }
              }

            }
          }
        }
        stage('Get kube_config') {
          steps {
            dir ('infra') {
              sh 'terraform output kube_config > ../kube_config'
            }
          }
        }
        stage('Deploy app') {
          steps {
            echo 'Deploying....'
            sh 'export TAG=$(git rev-parse HEAD:app) && \
                az login \
                  --service-principal \
                  --username ${ARM_CLIENT_ID} \
                  --password ${ARM_CLIENT_SECRET} \
                  --tenant ${ARM_TENANT_ID} &&\
                export CLUSTER_SPECIFIC_DNS_ZONE=$(az aks show --resource-group Dev-aks-hashicorp-demo --query addonProfiles.httpApplicationRouting.config.HTTPApplicationRoutingZoneName -n Dev-aks-hashicorp-demo -o tsv) && \
                echo Application public URL: hashicorp-demo.${CLUSTER_SPECIFIC_DNS_ZONE} && \
                envsubst < app/deployment/deployment.yaml | kubectl --kubeconfig=kube_config apply -f -'
          }
        }
        stage('Infrastructure Destruction') {
          agent {
            docker {
              image terraformBuilder
              args '-e TF_IN_AUTOMATION=1 --entrypoint=\'\''
            }
          }
          when {
            environment name: 'DESTROY', value: 'true'
          }
          input {
            message "Destroy to production?"
            id "DESTROY"
            parameters {
              booleanParam(
                name: 'DESTROY',
                defaultValue: false,
                description: 'If set the infrstracture will be destroyed.'
              )
            }
          }
          steps {
            dir ('infra') {
              echo 'destroying....'
              sh 'terraform init -backend-config workspace_key_prefix=${JOB_NAME}'
              sh 'terraform destroy -auto-approve \
                    -var ARM_CLIENT_ID=${ARM_CLIENT_ID} \
                    -var ARM_CLIENT_SECRET=${ARM_CLIENT_SECRET} \
                    -var ARM_SUBSCRIPTION_ID=${ARM_SUBSCRIPTION_ID} \
                    -var ARM_TENANT_ID=${ARM_TENANT_ID}'
            }
          }
        }
  }
}
