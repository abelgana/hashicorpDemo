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
    AWS_ACCESS_KEY_ID= credentials('AWS_ACCESS_KEY_ID')
    AWS_SECRET_ACCESS_KEY= credentials ('AWS_SECRET_ACCESS_KEY')
  }

  stages {
    stage('Application Build and Test') {
      agent {
        docker {
          image 'gcr.io/cloud-builders/bazel'
          args '--entrypoint=\'\''
        }
      }
      steps {
        dir("app") {
          echo 'Building....'
          // sh 'bazel build hashicorpdemo'
          echo 'Testing....'
          // sh 'bazel test'
        }
      }
    }
    stage('Infrastructure Planning') {
      agent {
        docker {
          image 'abelgana/terraformbuilder:1.0.1'
          args '-e TF_IN_AUTOMATION=1 --entrypoint=\'\''
        }
      }
      steps {
          dir ('infra') {
            echo 'Provisioning....'
            sh 'terraform init -backend-config workspace_key_prefix=$JOB_NAME'
            sh 'terraform plan \
                -var ARM_CLIENT_ID=$ARM_CLIENT_ID \
                -var ARM_CLIENT_SECRET=$ARM_CLIENT_SECRET \
                -out=plan'
          }
      }
    }
    stage('Infrastructure Provisioning Approval') {
      steps {
        script {
          def userInput = input(id: 'apply', message: 'Apply the planned deployment?', parameters: [ [$class: 'BooleanParameterDefinition', defaultValue: false, description: 'If true terraform apply will be run', name: 'apply'] ])
        }
      }
    }
    stage('Infrastructure Provisioning') {
      agent {
        docker {
          image 'abelgana/terraformbuilder:1.0.1'
          args '-e TF_IN_AUTOMATION=1 --entrypoint=\'\''
        }
      }
      steps {
        dir ('infra') {
          echo 'provisioning....'
          sh 'terraform init -backend-config workspace_key_prefix=$JOB_NAME'
          sh 'terraform apply plan'
        }
      }
    }
    stage('Infrastructure Destruction Approval') {
      steps {
        script {
          def userInput = input(id: 'destroy', message: 'Destroy the provisionned deployment?', parameters: [ [$class: 'BooleanParameterDefinition', defaultValue: false, description: 'If true terraform destroy will be run', name: 'destroy'] ])
        }
      }
    }
        stage('Infrastructure Destruction') {
      agent {
        docker {
          image 'abelgana/terraformbuilder:1.0.1'
          args '-e TF_IN_AUTOMATION=1 --entrypoint=\'\''
        }
      }
      steps {
        dir ('infra') {
          echo 'provisioning....'
          sh 'terraform init -backend-config workspace_key_prefix=$JOB_NAME'
          sh 'terraform destroy -auto-approve \
              -var ARM_CLIENT_ID=$ARM_CLIENT_ID \
              -var ARM_CLIENT_SECRET=$ARM_CLIENT_SECRET'
        }
      }
    }
  }
}
