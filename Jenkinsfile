pipeline {
  agent any
  options { timestamps(); disableConcurrentBuilds() }
  environment {
    DOCKER_IMAGE = "docker.io/ubedk1909/demo-app"
  }
  stages {
    stage('Checkout (SCM)') {
      steps {
        // remove credentialsId if repo is public
        git branch: 'main',
            url: "https://github.com/ubedk1909-star/demo-app.git",
            credentialsId: 'github-pat'
      }
    }
    stage('Build & Unit Test') {
      steps {
        sh 'bash -n app/main.sh'
      }
    }
   stage('Docker Build & Push') {
  steps {
    withCredentials([usernamePassword(
      credentialsId: 'dockerhub-creds',    // <-- upar wala ID
      usernameVariable: 'DOCKER_USER',
      passwordVariable: 'DOCKER_PASS'
    )]) {
      sh '''
        set -e
        echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin

        IMAGE="docker.io/ubedk1909/demo-app:${BUILD_NUMBER}"
        docker build -t "$IMAGE" .
        docker push "$IMAGE"

        docker logout || true
      '''
    }
  }
}

    stage('Deploy to Kubernetes') {
      when { expression { return false } } // true karo jab kubeconfig ready ho
      steps {
        withCredentials([file(credentialsId: 'kubeconfig', variable: 'KUBECONFIG')]) {
          sh '''
            kubectl apply -f k8s/deployment.yaml
            kubectl apply -f k8s/service.yaml || true
            kubectl rollout status deploy/demo-app --timeout=60s || true
          '''
        }
      }
    }
    stage('Terraform (IaC)') {
      steps {
        dir('terraform') {
          sh '''
            terraform init -input=false
            terraform plan -out=plan.out -input=false
            terraform apply -auto-approve plan.out
          '''
        }
      }
    }
  }
  post {
    always { archiveArtifacts artifacts: '**/plan.out', allowEmptyArchive: true }
  }
}
