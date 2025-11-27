pipeline {
    agent {
        docker { image 'node:16-alpine' }
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
    }

    post {
        always {
            cleanWs()
        }
    }
}



// pipeline{
//     agent {
//         docker {
//             // Node version compatible with Angular 14
//             image 'node:16-alpine'
//             // Cache npm between builds (optional but good)
//             // args '-v $HOME/.npm:/root/.npm'
//         }
//     }
//     environment {
//         NODE_OPTIONS = '--max_old_space_size=4096'
//         // we do NOT hardcode npm_config_cache here because we create a per-build timestamped cache in the steps
//     }
//     stages{
//         // stage('Checkout'){
//         //     steps {
//         //         // Use the same checkout you had but inside steps
//         //         checkout scmGit(
//         //             branches: [[name: '*/main']],
//         //             extensions: [],
//         //             userRemoteConfigs: [[url: 'https://github.com/jussandeep/Frontend-Application.git']]
//         //         )
//         //     }
//         // }
//         stage('Verify Node') {
//             steps {
//                 // quick check to ensure node/npm available on agent
//                 sh 'node -v'
//                 sh 'npm -v'
//             }
//         }
//         // stage('Install Dependencies'){
//         //     steps{
//         //         sh 'npm ci'
//         //     }
//         // }
//         stage('Prepare cache & Install Dependencies') {
//         steps {
//                 // create a timestamped cache, use it for npm, then run npm ci
//                 sh '''
//                 set -e
//                 TIMESTAMP=$(date +%Y%m%d-%H%M%S)
//                 CACHE_DIR="${WORKSPACE}/npm-cache-${TIMESTAMP}"
//                 echo "Using cache dir: $CACHE_DIR"
//                 mkdir -p "$CACHE_DIR"
//                 # ensure npm uses this cache for this shell
//                 export npm_config_cache="$CACHE_DIR"
//                 # run install using explicit --cache as well
//                 npm ci --cache "$CACHE_DIR" --prefer-offline
//                 # expose variables for later stages (optional logging)
//                 echo "CACHE_DIR=$CACHE_DIR" > cache_info.txt
//                 '''
//             }
//         }
//         // stage('Build Angular App'){
//         //     steps{
//         //         sh 'npm run build -- --configuration production'
                
//         //     }
//         // }
//         stage('Build Angular App') {
//             steps {
//                 sh '''
//                 # read CACHE_DIR we created earlier (if needed)
//                 if [ -f cache_info.txt ]; then source cache_info.txt; fi
//                 echo "Building, using cache: $CACHE_DIR"
//                 npm run build -- --configuration production
//                 '''
//             }
//         }

//         stage('Persist cache (save timestamped copy)') {
//             steps {
//                 sh '''
//                 set -e
//                 # read CACHE_DIR created above
//                 if [ -f cache_info.txt ]; then source cache_info.txt; else echo "cache_info.txt missing"; exit 1; fi

//                 # persistent target outside workspace so cleanWs won't remove it
//                 PERSISTENT_BASE="${JENKINS_HOME:-/var/jenkins_home}/npm-cache/${JOB_NAME}"
//                 mkdir -p "$PERSISTENT_BASE"
//                 # copy the timestamped cache dir to persistent storage (keep the timestamp)
//                 cp -a "$CACHE_DIR" "$PERSISTENT_BASE/" 
//                 # update a 'latest' symlink for convenience
//                 ln -sfn "$PERSISTENT_BASE/$(basename "$CACHE_DIR")" "$PERSISTENT_BASE/latest"
//                 echo "Saved cache to $PERSISTENT_BASE/$(basename "$CACHE_DIR")"
//                 '''
//             }
//         }
//         stage('Archive Artifacts') {
//             steps {
//                 archiveArtifacts artifacts: 'dist/**/*', fingerprint: true
//             }
//         }
        
//     }
//      post {
//         success {
//             echo '=========================== Build successful!==========================='
//         }
//         failure {
//             echo '=========================== Build failed!==============================='
//         }
//         always {
//             echo '============================Pipeline finished============================'
//             cleanWs()
//         }
//     }
// }