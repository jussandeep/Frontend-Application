pipeline{
    agent {
        docker {
            // Node version compatible with Angular 14
            image 'node:16-alpine'
            // Cache npm between builds (optional but good)
            // args '-v $HOME/.npm:/root/.npm'
        }
    }
    // environment {
    //     NODE_OPTIONS = '--max_old_space_size=4096'
    //     npm_config_cache = 'npm-cache'  // ← Use local cache folder
    // }
    stages{
        // stage('Checkout'){
        //     steps {
        //         // Use the same checkout you had but inside steps
        //         checkout scmGit(
        //             branches: [[name: '*/main']],
        //             extensions: [],
        //             userRemoteConfigs: [[url: 'https://github.com/jussandeep/Frontend-Application.git']]
        //         )
        //     }
        // }
        stage('Verify Node') {
            steps {
                // quick check to ensure node/npm available on agent
                sh 'node -v'
                sh 'npm -v'
            }
        }
        stage('Install Dependencies'){
            steps{
                sh 'npm ci'
            }
        }
        stage('Build Angular App'){
            steps{
                sh 'npm run build -- --configuration production'
                
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
            echo '=========================== Build successful!==========================='
        }
        failure {
            echo '=========================== Build failed!==============================='
        }
        always {
            echo '============================Pipeline finished============================'
            cleanWs()
        }
    }
}