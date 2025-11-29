pipeline {
  agent any

  environment {
    IMAGE = "jsandeep9866/frontend-application:latest"
    NODE_IMAGE = "node:18-alpine"
    DOCKER_CLIENT_IMAGE = "docker:24.0.5"
    WORKDIR = "${env.WORKSPACE}"
  }

  stages {

    stage('Verify Node (inside node container)') {
      steps {
        script {
          docker.image(NODE_IMAGE).inside("-u root:root -v ${WORKDIR}:${WORKDIR}") {
            sh 'node --version && npm --version'
          }
        }
      }
    }

    stage('Prepare workspace & Install (npm ci, cache)') {
      steps {
        script {
          docker.image(NODE_IMAGE).inside("-u root:root -v ${WORKDIR}:${WORKDIR}") {
            sh '''
              set -eux
              cd "$WORKSPACE"
              echo "Preparing npm cache..."
              mkdir -p npm_cache
              timestamp=$(date +%s)
              cacheFolder="run-${timestamp}"
              mkdir -p "$cacheFolder"
              export npm_config_cache="$PWD/$cacheFolder"
              npm ci
              echo "export TIMESTAMP=\\"$timestamp\\"" > cache_info.txt
              echo "export CACHE_FOLDER=\\"$cacheFolder\\"" >> cache_info.txt
              echo "npm ci completed, cacheFolder=$cacheFolder"
            '''
          }
        }
      }
    }

    stage('Build Angular App (inside node container)') {
      steps {
        script {
          docker.image(NODE_IMAGE).inside("-u root:root -v ${WORKDIR}:${WORKDIR}") {
            sh '''
              set -eux
              cd "$WORKSPACE"
              echo "Building Angular (production)..."
              npm run build -- --configuration production
              echo "Angular build finished."
            '''
          }
        }
      }
    }

    stage('Package cache into timestamped file') {
      steps {
        sh '''
          set -eux
          if [ -f cache_info.txt ]; then
            . ./cache_info.txt
            mkdir -p npm_cache
            tar czf "npm_cache/npm-cache-${TIMESTAMP}-build${BUILD_NUMBER}.tar.gz" -C . "$CACHE_FOLDER"
            ln -sf "npm-cache-${TIMESTAMP}-build${BUILD_NUMBER}.tar.gz" npm_cache/latest.tar.gz
            echo "Packed npm cache: npm_cache/npm-cache-${TIMESTAMP}-build${BUILD_NUMBER}.tar.gz"
          else
            echo "No cache_info.txt found — skipping cache packaging."
          fi
        '''
      }
    }

    stage('Archive Artifacts') {
      steps {
        archiveArtifacts artifacts: 'npm_cache/npm-cache-*-build*.tar.gz', fingerprint: true, allowEmptyArchive: true
      }
    }

    stage('Preserve Cache Inside Workspace (Safe)') {
      steps {
        sh '''
          set -eux
          if [ -f cache_info.txt ]; then
            . ./cache_info.txt
            PERSIST_DIR=".jenkins_cache"
            mkdir -p "$PERSIST_DIR"
            cp "npm_cache/npm-cache-${TIMESTAMP}-build${BUILD_NUMBER}.tar.gz" "$PERSIST_DIR/" || echo "No cache artifact to copy"
            ln -sf "npm-cache-${TIMESTAMP}-build${BUILD_NUMBER}.tar.gz" "$PERSIST_DIR/latest.tar.gz" || true
            echo "Saved persistent cache to $PERSIST_DIR/"
          else
            echo "No cache_info.txt found — skipping persist."
          fi
        '''
      }
    }

    stage('Build & Push Docker Image (docker client container)') {
      steps {
        script {
          docker.image(DOCKER_CLIENT_IMAGE).inside(
            "-u root:root -v /var/run/docker.sock:/var/run/docker.sock -v ${WORKDIR}:${WORKDIR}"
          ) {
            sh '''
              set -eux
              cd "$WORKSPACE"

              echo "Listing workspace:"
              ls -la

              # quick sanity check: ensure build output exists
              if [ ! -d "dist/angular-mean-crud-tutorial" ]; then
                echo "ERROR: expected dist/angular-mean-crud-tutorial not found. Did the Angular build succeed?"
                ls -la dist || true
                exit 1
              fi

              echo "Building Docker image ${IMAGE} (with --pull)..."
              docker build --pull -t ${IMAGE} .
              echo "Docker image built: ${IMAGE}"
            '''
            withCredentials([string(credentialsId: 'FrontendDockerHubID', variable: 'DOCKER_PASS')]) {
              sh '''
                set -eux
                echo "Logging into Docker Hub..."
                docker login -u jsandeep9866 -p "${DOCKER_PASS}"
                echo "Pushing image ${IMAGE}..."
                docker push ${IMAGE}
                echo "Image pushed: ${IMAGE}"
              '''
            }
          }
        }
      }
    }

  } // stages

  post {
    success { echo '=========================== Build successful!===========================' }
    failure { echo '=========================== Build failed!===============================' }
    always  { echo '============================Pipeline finished============================' }
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

