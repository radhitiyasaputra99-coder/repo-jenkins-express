pipeline {
    agent any

    environment {
        IMAGE_NAME = 'repo-jenkins-express'
        IMAGE_TAG  = "${env.BUILD_NUMBER}"
    }

    stages {
        stage('Install & Lint & Test') {
            // This Jenkins runs on Kubernetes (Kubernetes plugin), so we ask for a
            // pod with a Node.js container instead of agent { docker { ... } },
            // which needs a Docker daemon that the default agent pod doesn't have.
            agent {
                kubernetes {
                    yaml '''
                        apiVersion: v1
                        kind: Pod
                        spec:
                          containers:
                          - name: node
                            image: node:20-alpine
                            command: ["sleep"]
                            args: ["infinity"]
                    '''
                }
            }
            steps {
                container('node') {
                    sh '''
                        corepack enable
                        pnpm install --frozen-lockfile
                        pnpm run lint
                        pnpm test
                    '''
                }
            }
        }

        stage('Build Docker Image') {
            // Heads up: the default agent pod has no Docker daemon either, so this
            // stage will fail as-is. Building images from inside Kubernetes normally
            // needs kaniko (or Docker-in-Docker) wired into the pod template - a
            // separate follow-up once Install & Lint & Test is green.
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
