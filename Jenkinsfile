pipeline {
    agent any

    environment {
        IMAGE_NAME = 'repo-jenkins-express'
        IMAGE_TAG  = "${env.BUILD_NUMBER}"
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Install & Lint & Test') {
            agent {
                docker { image 'node:20-alpine' args '-u root' }
            }
            steps {
                sh '''
                    corepack enable
                    pnpm install --frozen-lockfile
                    pnpm run lint
                    pnpm test
                '''
            }
        }

        stage('Build Docker Image') {
            // Needs Docker (or an equivalent, e.g. kaniko on a k8s agent) available
            // on the node that runs this stage.
            steps {
                sh "docker build -t ${IMAGE_NAME}:${IMAGE_TAG} ."
            }
        }

        // Next step once you have a registry + credentials configured in Jenkins:
        // stage('Push Docker Image') {
        //     steps {
        //         withCredentials([usernamePassword(credentialsId: 'registry-creds', usernameVariable: 'REG_USER', passwordVariable: 'REG_PASS')]) {
        //             sh """
        //                 echo \$REG_PASS | docker login <your-registry> -u \$REG_USER --password-stdin
        //                 docker push ${IMAGE_NAME}:${IMAGE_TAG}
        //             """
        //         }
        //     }
        // }
    }

    post {
        success {
            echo "Pipeline sukses - image ${IMAGE_NAME}:${IMAGE_TAG} siap dipakai."
        }
        failure {
            echo 'Pipeline gagal, cek Console Output di atas buat detail error-nya.'
        }
    }
}
