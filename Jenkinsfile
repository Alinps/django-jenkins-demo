pipeline {
    agent any

    environment {
        IMAGE_NAME = "django-demo"
        IMAGE_TAG  = "${BUILD_NUMBER}"
    }

    stages {

        /*
        ---------------------------------------------------------
        CHECKOUT CODE
        ---------------------------------------------------------
        */
        stage('Checkout') {
            steps {
                echo "Checking out source code"
                checkout scm
            }
        }

        /*
        ---------------------------------------------------------
        SETUP PYTHON + INSTALL DEPENDENCIES
        ---------------------------------------------------------
        */
        stage('Setup Python & Install Dependencies') {
            steps {
                sh '''
                    python3 -m venv venv
                    . venv/bin/activate
                    pip install --no-cache-dir -r requirements.txt
                '''
            }
        }

        /*
        ---------------------------------------------------------
        RUN TESTS
        ---------------------------------------------------------
        */
        stage('Run Tests') {
            steps {
                sh '''
                    . venv/bin/activate
                    pytest -q
                '''
            }
        }

        /*
        ---------------------------------------------------------
        BUILD DOCKER IMAGE
        ---------------------------------------------------------
        */
        stage('Build Docker Image') {
            steps {
                script {
                    echo "Building Docker image: ${IMAGE_NAME}:${IMAGE_TAG}"
                    sh """
                        docker build -t ${IMAGE_NAME}:${IMAGE_TAG} .
                    """
                }
            }
        }

        /*
        ---------------------------------------------------------
        SMOKE TEST (RUN CONTAINER NORMALLY)
        ---------------------------------------------------------
        */
        stage('Smoke Test Docker Container') {
            steps {
                script {
                    echo "Starting smoke test for ${IMAGE_NAME}:${IMAGE_TAG}"

                    sh """
                        # Start container in background using Dockerfile CMD
                        CONTAINER_ID=\$(docker run -d -p 8000:8000 ${IMAGE_NAME}:${IMAGE_TAG})
                        echo "Container started with ID: \$CONTAINER_ID"

                        echo "*** Waiting for Django to start ***"

                        attempts=0
                        max
