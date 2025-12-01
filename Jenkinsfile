pipeline {
    agent any
    tools {
        nodejs 'NodeJS-18' // Ensure this matches the name configured in Jenkins
    }
    
    environment {
        BUILD_DIR = "dist/angular-mean-crud-tutorial"  // Output folder after Angular build
        DEPLOY_DIR = "/usr/share/nginx/html" // Target directory for deployment
        
    }
    stages {
        stage('Clone Repository') {
            steps {
                git branch: 'main', 
                    url: 'https://github.com/jussandeep/Frontend-Application.git'
            }
        }
        stage('Verify Node.js and npm') {
            steps {
                sh 'node -v'
                sh 'npm -v'
                // sh 'ng version'
            }
        }
        stage('Install Dependencies') {
            steps {
                echo '=== Installing npm dependencies ==='
                // sh 'npm ci'  
                sh 'npm ci --cache .npm-cache --prefer-offline'
            }
        }
        stage('Build Angular App') {
            steps {
                echo '=== Building Angular application ==='
                // sh 'ng build --configuration=production'
                sh 'npm run build -- --configuration=production'
            }
        }
        stage('Deploy') {
            steps {
                script {
                    if (fileExists(BUILD_DIR)) {
                        echo "Deploying build from ${BUILD_DIR} to ${DEPLOY_DIR}..."
                        // ensure deploy dir exists and remove only its contents
                        // sh "sudo mkdir -p ${DEPLOY_DIR}"
                        // sh "sudo rm -rf ${DEPLOY_DIR}/* || true"
                        // // copy build content with sudo
                        // sh "sudo cp -r ${BUILD_DIR}/* ${DEPLOY_DIR}/"
                        // // set ownership and permissions so nginx can serve files
                        // sh "sudo chown -R www-data:www-data ${DEPLOY_DIR} || true"
                        // sh "sudo chmod -R 755 ${DEPLOY_DIR} || true"
                        // echo "Deployment complete."
                        echo "Deploying from ${BUILD_DIR} to ${DEPLOY_DIR}..."
                        sh """
                            sudo mkdir -p ${DEPLOY_DIR}
                            sudo rm -rf ${DEPLOY_DIR}/*
                            sudo cp -r ${BUILD_DIR}/* ${DEPLOY_DIR}/
                            sudo chown -R www-data:www-data ${DEPLOY_DIR}
                            sudo chmod -R 755 ${DEPLOY_DIR}
                        """
                        echo "Deployment complete!"
                    }else {
                        error "Build directory not found: ${BUILD_DIR}"
                    }
                }
            }
        }
    }
    post {
        success {
            echo 'Build and Deployment Successful!'
        }
        failure {
            echo 'Build Failed!'
        }
    }
}
