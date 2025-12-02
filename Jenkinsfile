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
                sh '''
                    echo "Node and npm versions:"
                    node -v
                    npm -v
                '''
                // sh 'ng version'
            }
        }
        stage('Install Dependencies') {
            steps {
                echo '=== Installing npm dependencies ==='
                sh 'npm ci'  
                
            }
        }
        stage('Build Angular App') {
            steps {
                echo '=== Building Angular application ==='
                sh 'npm run build --configuration=production'
                // sh 'npm run build -- --configuration=production'
            }
        }
        // stage('Deploy') {
        //     steps {
        //         script {
        //             if (fileExists(BUILD_DIR)) {
        //                 echo "Deploying build from ${BUILD_DIR} to ${DEPLOY_DIR}..."
        //                // Ignore errors if DEPLOY_DIR does not exist
        //                 sh "rm -rf ${DEPLOY_DIR} || true"
                
        //                 // Create the deployment directory
        //                 sh "mkdir -p ${DEPLOY_DIR}"
                
        //                 // Copy build artifacts
        //                 sh "cp -r ${BUILD_DIR}/* ${DEPLOY_DIR}/"
        //                 echo "Deployment complete."
        //             }else {
        //                 error "Build directory not found: ${BUILD_DIR}"
        //             }
        //         }
        //     }
        // }
        stage('Archive build artifacts') {
            steps {
                echo "Archiving ${BUILD_DIR}"
                archiveArtifacts artifacts: "${BUILD_DIR}/**/*", fingerprint: true
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
