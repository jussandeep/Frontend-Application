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

        stage('Install Dependencies & Cache') {
            steps {
                // The cache step restores the 'node_modules' directory if a cache key exists.
                // It saves the directory if the step completes successfully.
                cache(path: 'node_modules', key: "node-cache-${hashFiles('package-lock.json')}") {
                    // Use 'npm ci' for clean, repeatable installs based on package-lock.json
                    sh 'npm ci' 
                }
            }
        }

        stage('Build Angular App') {
            steps {
                sh 'npm run build -- --configuration production'
            }
        }
        
        // --- Remove the following stages as they are no longer necessary ---
        // stage('Package cache into timestamped file') { ... }
        // stage('Preserve Cache Inside Workspace (Safe)') { ... }
        
        stage('Archive Build Artifacts') {
            steps {
                // Assuming your build output is in a directory like 'dist' or similar
                archiveArtifacts artifacts: 'dist/**/*', fingerprint: true
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


// pipeline {
//     agent {
//         docker { image 'node:16-alpine' }
//     }

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

