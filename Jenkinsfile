pipeline {
    agent any
    environment {
        BUILD_DIR = "dist/angular-mean-crud-tutorial"  // Output folder after Angular build
        DEPLOY_DIR = "/usr/share/nginx/html/angular-app" // Target directory for deployment
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
                echo '=== Checking Node.js and npm versions ==='
                sh 'node -v'
                sh 'npm -v'
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
                sh 'npm run build -- --configuration=production'
            }
        }
        stage('Verify Build Output') {
            steps {
                echo '=== Verifying build output ==='
                sh "ls -la ${BUILD_DIR}"
            }
        }

        stage('Deploy to Nginx') {
            steps {
                echo '=== Deploying to Nginx ==='
                
                // Create deployment directory
                sh "sudo mkdir -p ${DEPLOY_DIR}"
                
                // Remove old files
                sh "sudo rm -rf ${DEPLOY_DIR}/*"
                
                // Copy new build
                sh "sudo cp -r ${BUILD_DIR}/* ${DEPLOY_DIR}/"
                
                // Set permissions
                sh "sudo chown -R ${NGINX_USER}:${NGINX_USER} ${DEPLOY_DIR}"
                sh "sudo chmod -R 755 ${DEPLOY_DIR}"
                
                echo "✅ Deployment complete"
            }
        }

        stage('Reload Nginx') {
            steps {
                echo '=== Reloading Nginx ==='
                sh 'sudo systemctl reload nginx'
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






// pipeline {
//     agent any
//     // {
//     //     docker { image 'node:18-alpine' }
//     // }

//     stages {
//         stage('Verify Node') {
//             steps {
//                 sh 'node --version && npm --version'
//             }
//         }

//         stage('Prepare workspace & Install') {
//             steps {
//                 sh '''
//                     mkdir -p npm_cache
//                     timestamp=$(date +%s)
//                     cacheFolder="run-${timestamp}"
//                     mkdir -p "$cacheFolder"
//                     export npm_config_cache="$PWD/$cacheFolder"
//                     npm ci
//                     # Save variables for next stages
//                     echo "export TIMESTAMP=\\"$timestamp\\"" > cache_info.txt
//                     echo "export CACHE_FOLDER=\\"$cacheFolder\\"" >> cache_info.txt
//                 '''
//             }
//         }

//         stage('Build Angular App') {
//             steps {
//                 sh 'npm run build -- --configuration production'
//             }
//         }

//         stage('Package cache into timestamped file') {
//             steps {
//                 sh '''
//                     . ./cache_info.txt
//                     mkdir -p npm_cache
//                     tar czf "npm_cache/npm-cache-${TIMESTAMP}-build${BUILD_NUMBER}.tar.gz" -C . "$CACHE_FOLDER"
//                     ln -sf "npm-cache-${TIMESTAMP}-build${BUILD_NUMBER}.tar.gz" npm_cache/latest.tar.gz
//                 '''
//             }
//         }

//         stage('Archive Artifacts') {
//             steps {
//                 archiveArtifacts artifacts: 'npm_cache/npm-cache-*-build*.tar.gz', fingerprint: true
//             }
//         }

        

//         stage('Preserve Cache Inside Workspace (Safe)') {
//             steps {
//                 sh '''
//                     . ./cache_info.txt
//                     PERSIST_DIR=".jenkins_cache"
//                     mkdir -p "$PERSIST_DIR"
//                     cp "npm_cache/npm-cache-${TIMESTAMP}-build${BUILD_NUMBER}.tar.gz" "$PERSIST_DIR/"
//                     ln -sf "npm-cache-${TIMESTAMP}-build${BUILD_NUMBER}.tar.gz" "$PERSIST_DIR/latest.tar.gz"
//                     echo "Saved persistent cache to $PERSIST_DIR/"
//                 '''
//             }
//         }


//         stage('Build Docker Image') {
//             steps {
//                 sh 'docker build -t jsandeep9866/frontend-application:latest .'
//             }
//         }
//         stage('Push image to Docker Hub') {
//             steps{
//                 script {
//                     withCredentials([string(credentialsId: 'FrontendDockerHubID', variable: 'FrontendDockerDubPwd')]) {
//                         sh "docker login -u jsandeep9866 -p ${FrontendDockerDubPwd}"
//                         sh 'docker push jsandeep9866/frontend-application:latest'
//                     }
//                 }
//             }
//         }
    


//     }

//     post {
//         success {
//             echo '=========================== Build successful!==========================='
//         }
//         failure {
//             echo '=========================== Build failed!==============================='
//         }
//         always {
//             echo '============================Pipeline finished============================'
            
//         }
//     }
// }

