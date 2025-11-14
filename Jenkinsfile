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
        SMOKE TEST (HARDENED + DEBUG OUTPUT + RETRY)
        ---------------------------------------------------------
        */
        stage('Smoke Test Docker Container') {

            steps {
                script {
                    echo "Starting smoke test for ${IMAGE_NAME}:${IMAGE_TAG}"

                    def img = docker.image("${IMAGE_NAME}:${IMAGE_TAG}")

                    // This runs the container and exposes port 8000
                    img.inside('-p 8000:8000') {

                        sh '''
                            echo "*** Waiting for Django to start ***"

                            # Retry loop (8 attempts, 2 sec apart)
                            attempts=0
                            max=8
                            success=0

                            while [ $attempts -lt $max ]; do
                                echo "Attempt $(($attempts+1))/$max..."

                                # Save response to a file
                                curl -s http://localhost:8000 -o response.txt || true

                                # Print first lines so Jenkins shows actual output
                                echo "---- RESPONSE START ----"
                                head -n 40 response.txt || true
                                echo "---- RESPONSE END ----"

                                # Check for expected text
                                if grep -q "Hello from Jenkins Django Demo!" response.txt; then
                                    echo "Smoke Test: PASS"
                                    success=1
                                    break
                                fi

                                attempts=$((attempts+1))
                                sleep 2
                            done

                            if [ $success -ne 1 ]; then
                                echo "Smoke Test FAILED after $attempts attempts!"
                                echo "Complete Response:"
                                cat response.txt || true
                                exit 1
                            fi
                        '''
                    }
                }
            }
        }

    } // end of stages

    /*
    ---------------------------------------------------------
    POST ACTIONS
    ---------------------------------------------------------
    */
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
