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
    stage('Application Build and Test') {
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
        parameters { booleanParam(name: 'PACKAGE', defaultValue: false, description: '') }
      }
      steps {
        dir("app") {
          echo 'Building....'
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
          image 'abelgana/terraformbuilder:1.0.1'
          args '-e TF_IN_AUTOMATION=1 --entrypoint=\'\''
        }
      }
      stages {
        stage('Infrastructure Planning') {
          steps {
            dir ('infra') {
              echo 'Planning....'
              sh 'terraform init -backend-config workspace_key_prefix=$JOB_NAME'
              sh 'terraform plan \
                  -var ARM_CLIENT_ID=$ARM_CLIENT_ID \
                  -var ARM_CLIENT_SECRET=$ARM_CLIENT_SECRET \
                  -var ARM_SUBSCRIPTION_ID=$ARM_SUBSCRIPTION_ID \
                  -var ARM_TENANT_ID=$ARM_TENANT_ID \
                  -out=plan'
            }
          }
        }
        stage('Infrastructure Provisioning') {
          when {
            environment name: 'DEPLOY', value: 'true'
          }
          input {
            message "Deploy to production?"
            id "DEPLOY"
            parameters { booleanParam(name: 'DEPLOY', defaultValue: false, description: '') }
          }
          steps {
            dir ('infra') {
              echo 'provisioning....'
              sh 'terraform apply plan'
            }
          }
        }
      }
    }
    stage('Infrastructure Destruction') {
      when {
        environment name: 'DESTROY', value: 'true'
      }
      input {
        message "Destroy to production?"
        id "DESTROY"
        parameters { booleanParam(name: 'DESTROY', defaultValue: false, description: '') }
      }
      steps {
        dir ('infra') {
          echo 'destroying....'
          sh 'terraform init -backend-config workspace_key_prefix=$JOB_NAME'
          sh 'terraform destroy -auto-approve \
              -var ARM_CLIENT_ID=$ARM_CLIENT_ID \
              -var ARM_CLIENT_SECRET=$ARM_CLIENT_SECRET \
              -var ARM_SUBSCRIPTION_ID=$ARM_SUBSCRIPTION_ID \
              -var ARM_TENANT_ID=$ARM_TENANT_ID'
        }
      }
    }
  }
}
