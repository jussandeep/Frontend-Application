pipeline {
  agent {
    docker { image 'node:16-alpine' }
  }

  environment {
    NODE_OPTIONS = '--max_old_space_size=4096'
    // we don't set npm_config_cache here; we set it in the shell for each run
  }

  stages {
    stage('Verify Node') {
      steps {
        sh 'node -v; npm -v'
      }
    }

    stage('Prepare workspace cache & Install') {
        steps {
            sh '''
            set -e
            WORKSPACE_CACHE_DIR="${WORKSPACE}/npm_cache"
            mkdir -p "$WORKSPACE_CACHE_DIR"

            TIMESTAMP=$(date +%Y%m%d-%H%M%S)
            RUN_CACHE_DIR="${WORKSPACE_CACHE_DIR}/run-${TIMESTAMP}"
            mkdir -p "$RUN_CACHE_DIR"

            echo "Using run cache dir: $RUN_CACHE_DIR"
            export npm_config_cache="$RUN_CACHE_DIR"

            npm ci --cache "$RUN_CACHE_DIR" --prefer-offline

            # safe: write quoted export lines so later `source` handles spaces
            cat > cache_info.txt <<EOF
            export WORKSPACE_CACHE_DIR='${WORKSPACE_CACHE_DIR}'
            export RUN_CACHE_DIR='${RUN_CACHE_DIR}'
            export TIMESTAMP='${TIMESTAMP}'
            EOF
            '''
        }
    }


    stage('Build Angular App') {
      steps {
        sh '''
        set -e
        if [ -f cache_info.txt ]; then source cache_info.txt; else echo "cache_info.txt missing"; exit 1; fi
        echo "Building using cache: $RUN_CACHE_DIR"
        npm run build -- --configuration production
        '''
      }
    }

    stage('Package cache into timestamped file (in workspace)') {
      steps {
        sh '''
        set -e
        if [ -f cache_info.txt ]; then source cache_info.txt; else echo "cache_info.txt missing"; exit 1; fi

        # create a single tar.gz file inside workspace/npm_cache/
        TAR_NAME="npm-cache-${TIMESTAMP}-build${BUILD_NUMBER}.tar.gz"
        TAR_PATH="${WORKSPACE_CACHE_DIR}/${TAR_NAME}"
        echo "Creating tarball in workspace: $TAR_PATH"
        # tar from the parent dir so tar has only the run folder inside the archive
        tar -C "$(dirname "$RUN_CACHE_DIR")" -czf "$TAR_PATH" "$(basename "$RUN_CACHE_DIR")"

        # also create/update a workspace latest symlink for convenience
        ln -sfn "$TAR_PATH" "${WORKSPACE_CACHE_DIR}/latest.tar.gz"
        ls -lh "$WORKSPACE_CACHE_DIR"
        '''
      }
    }

    stage('Optional: copy timestamped file to persistent storage (survives cleanWs)') {
      steps {
        sh '''
        set -e
        if [ -f cache_info.txt ]; then source cache_info.txt; else echo "cache_info.txt missing"; exit 1; fi

        # Persistent storage location (outside workspace)
        PERSISTENT_BASE="${JENKINS_HOME:-/var/jenkins_home}/npm-cache/${JOB_NAME}"
        mkdir -p "$PERSISTENT_BASE"

        # copy the workspace tarball to the persistent dir (keeps a copy if workspace is cleaned)
        SRC_TARBALL="${WORKSPACE_CACHE_DIR}/npm-cache-${TIMESTAMP}-build${BUILD_NUMBER}.tar.gz"
        cp -a "$SRC_TARBALL" "$PERSISTENT_BASE/"

        # update 'latest' symlink in persistent storage too
        ln -sfn "$PERSISTENT_BASE/$(basename "$SRC_TARBALL")" "$PERSISTENT_BASE/latest.tar.gz"

        echo "Copied $SRC_TARBALL -> $PERSISTENT_BASE/"
        ls -lh "$PERSISTENT_BASE"
        '''
      }
    }

    stage('Archive Artifacts') {
      steps {
        archiveArtifacts artifacts: 'dist/**/*', fingerprint: true
      }
    }
  }

  post {
    success {
      echo '=========================== Build successful! ==========================='
    }
    failure {
      echo '=========================== Build failed! ================================'
    }
    always {
      echo '============================ Pipeline finished ============================='
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