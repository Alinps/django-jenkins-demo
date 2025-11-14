pipeline {
    agent any

    environment {
        IMAGE_NAME = "django-demo"
        IMAGE_TAG  = "${BUILD_NUMBER}"
    }

    stages {

        stage('Checkout') {
            steps {
                echo "Checking out source code"
                checkout scm
            }
        }

        stage('Setup Python & Install Dependencies') {
            steps {
                sh '''
                    python3 -m venv venv
                    . venv/bin/activate
                    pip install --no-cache-dir -r requirements.txt
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
                    echo "Building Docker image: ${IMAGE_NAME}:${IMAGE_TAG}"
                    sh "docker build -t ${IMAGE_NAME}:${IMAGE_TAG} ."
                }
            }
        }

        stage('Smoke Test Docker Container') {
            steps {
                script {
                    echo "Starting smoke test for ${IMAGE_NAME}:${IMAGE_TAG}"

                    sh """
                        # Start container using Dockerfile CMD
                        CONTAINER_ID=\$(docker run -d -p 8000:8000 ${IMAGE_NAME}:${IMAGE_TAG})
                        echo "Container ID: \$CONTAINER_ID"

                        echo "Waiting for Django to start..."

                        attempts=0
                        max=8
                        success=0

                        while [ \$attempts -lt \$max ]; do
                            echo "Attempt \$((attempts+1))/\$max ..."

                            curl -s http://localhost:8000 -o response.txt || true

                            echo "---- RESPONSE START ----"
                            head -n 40 response.txt || true
                            echo "---- RESPONSE END ----"

                            if grep -q "Hello from Jenkins Django Demo!" response.txt; then
                                echo "Smoke Test PASSED!"
                                success=1
                                break
                            fi

                            attempts=\$((attempts+1))
                            sleep 2
                        done

                        if [ \$success -ne 1 ]; then
                            echo "Smoke Test FAILED!"
                            echo "Container logs:"
                            docker logs \$CONTAINER_ID || true
                            docker stop \$CONTAINER_ID || true
                            docker rm \$CONTAINER_ID || true
                            exit 1
                        fi

                        docker stop \$CONTAINER_ID || true
                        docker rm \$CONTAINER_ID || true
                    """
                }
            }
        }

    }

    post {
        success {
            echo "Build SUCCESS — Passed all stages."
        }
        failure {
            echo "Build FAILED at: ${BUILD_URL}"
        }
        always {
            cleanWs()
        }
    }
}
