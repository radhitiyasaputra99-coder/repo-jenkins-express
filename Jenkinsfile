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

        stage('Build Image') {
            // kaniko builds the image from inside a pod - no Docker daemon and no
            // privileged container needed, which is what makes it work here.
            // /busybox/cat + tty keeps the container alive; its shell lives at
            // /busybox/sh, so the container step is pointed at it explicitly.
            agent {
                kubernetes {
                    yaml '''
                        apiVersion: v1
                        kind: Pod
                        spec:
                          containers:
                          - name: kaniko
                            image: gcr.io/kaniko-project/executor:debug
                            command: ["/busybox/cat"]
                            tty: true
                    '''
                }
            }
            steps {
                container(name: 'kaniko', shell: '/busybox/sh') {
                    // To publish instead of just building: drop --no-push, add
                    // --destination <registry>/<user>/${IMAGE_NAME}:${IMAGE_TAG},
                    // and mount a registry credential at /kaniko/.docker/config.json.
                    sh '/kaniko/executor --context "$(pwd)" --dockerfile Dockerfile --no-push'
                }
            }
        }
    }

    post {
        success {
            echo "Pipeline sukses - lint, test, dan image build (${IMAGE_NAME}:${IMAGE_TAG}) semua lolos. Image tidak di-push."
        }
        failure {
            echo 'Pipeline gagal, cek Console Output di atas buat detail error-nya.'
        }
    }
}
