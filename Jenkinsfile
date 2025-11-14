pipeline {
    agent any

    environment {
        IMAGE_NAME = "django-demo"
        IMAGE_TAG  = "${BUILD_NUMBER}"
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Setup Python & Install Dependencies') {
            steps {
                sh '''
                python3 -m venv venv
                . venv/bin/activate
                pip install -r requirements.txt
                '''
            }
        }

        stage('Run Tests') {
            steps {
                sh '''
                . venv/bin/activate
                pytest -q
                '''
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    docker.build("${IMAGE_NAME}:${IMAGE_TAG}")
                }
            }
        }

        stage('Smoke Test Docker Container') {
            steps {
                script {
                    def img = docker.image("${IMAGE_NAME}:${IMAGE_TAG}")

                    img.inside('-p 8000:8000') {
                        sh '''
                        sleep 3
                        curl -s http://localhost:8000 | grep "Hello from Jenkins Django Demo!"
                        '''
                    }
                }
            }
        }

        stage('Archive Important Files') {
            steps {
                archiveArtifacts artifacts: 'simple_django_app/**/*.py, app/**/*.py, requirements.txt', fingerprint: true
            }
        }
    }

    post {
        success {
            echo "Build succeeded at ${BUILD_URL}"
        }
        failure {
            echo "Build failed at ${BUILD_URL}"
        }
        always {
            cleanWs()
        }
    }
}
