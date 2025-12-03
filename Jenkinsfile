pipeline {
    agent any
    tools {
        nodejs 'NodeJS-18' 
    }
    
    environment {
        BUILD_DIR = "dist/angular-mean-crud-tutorial"  
        DEPLOY_DIR = "/var/www/angular_app"

        
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
                
            }
        }
        // stage('Deploy App') {
        //     steps {
        //         sh '''
        //           rm -rf ${DEPLOY_DIR}/*
        //           cp -r ${WORKSPACE}/${BUILD_DIR}/* ${DEPLOY_DIR}/
        //           chmod -R 755 ${DEPLOY_DIR}
        //         '''
        //     }
        // }
        stage('Deploy to nginx') {
            steps {
                sh '''
                  # fail if build folder is missing
                  if [ ! -d "${WORKSPACE}/${BUILD_DIR}" ]; then
                    echo "ERROR: Build folder not found: ${WORKSPACE}/${BUILD_DIR}"
                    exit 1
                  fi

                  # remove old files (but keep folder)
                  rm -rf ${DEPLOY_DIR}/*

                  # copy new build files to deploy dir
                  cp -r ${WORKSPACE}/${BUILD_DIR}/* ${DEPLOY_DIR}/

                  # fix permissions (jenkins owns folder already)
                  chmod -R 755 ${DEPLOY_DIR}
                '''
            }
        }

        stage('Post-deploy check') {
            steps {
                echo "Deployed files at ${DEPLOY_DIR}:"
                sh "ls -la ${DEPLOY_DIR} | sed -n '1,120p'"
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
