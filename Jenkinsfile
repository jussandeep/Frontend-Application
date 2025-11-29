pipeline {
    agent {
        docker { image 'node:18-alpine' }
    }

    stages {
        stage('Verify Node') {
            steps {
                sh 'node --version && npm --version'
            }
        }

        stage('Prepare workspace & Install') {
            steps {
                sh '''
                    mkdir -p npm_cache
                    timestamp=$(date +%s)
                    cacheFolder="run-${timestamp}"
                    mkdir -p "$cacheFolder"
                    export npm_config_cache="$PWD/$cacheFolder"
                    npm ci
                    # Save variables for next stages
                    echo "export TIMESTAMP=\\"$timestamp\\"" > cache_info.txt
                    echo "export CACHE_FOLDER=\\"$cacheFolder\\"" >> cache_info.txt
                '''
            }
        }

        stage('Build Angular App') {
            steps {
                sh 'npm run build -- --configuration production'
            }
        }

        stage('Package cache into timestamped file') {
            steps {
                sh '''
                    . ./cache_info.txt
                    mkdir -p npm_cache
                    tar czf "npm_cache/npm-cache-${TIMESTAMP}-build${BUILD_NUMBER}.tar.gz" -C . "$CACHE_FOLDER"
                    ln -sf "npm-cache-${TIMESTAMP}-build${BUILD_NUMBER}.tar.gz" npm_cache/latest.tar.gz
                '''
            }
        }

        stage('Archive Artifacts') {
            steps {
                archiveArtifacts artifacts: 'npm_cache/npm-cache-*-build*.tar.gz', fingerprint: true
            }
        }

        

        stage('Preserve Cache Inside Workspace (Safe)') {
            steps {
                sh '''
                    . ./cache_info.txt
                    PERSIST_DIR=".jenkins_cache"
                    mkdir -p "$PERSIST_DIR"
                    cp "npm_cache/npm-cache-${TIMESTAMP}-build${BUILD_NUMBER}.tar.gz" "$PERSIST_DIR/"
                    ln -sf "npm-cache-${TIMESTAMP}-build${BUILD_NUMBER}.tar.gz" "$PERSIST_DIR/latest.tar.gz"
                    echo "Saved persistent cache to $PERSIST_DIR/"
                '''
            }
        }


        stage('Build Docker Image') {
            steps {
                sh '''
                    docker build -t jsandeep9866/frontend-application:latest.
                '''
            }
        }
        stage('Push image to Docker Hub') {
            steps{
                script {
                    withCredentials([string(credentialsId: 'FrontendDockerHubID', variable: 'FrontendDockerDubPwd')]) {
                        sh 'docker login -u jsandeep9866 -p ${FrontendDockerDubPwd}'
                        sh 'docker push jsandeep9866/frontend-application:latest
'
                    }
                }
            }
        }
    


    }

    post {
        success {
            echo '=========================== Build successful!==========================='
        }
        failure {
            echo '=========================== Build failed!==============================='
        }
        always {
            echo '============================Pipeline finished============================'
            
        }
    }
}

