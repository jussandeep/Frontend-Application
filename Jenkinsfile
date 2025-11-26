pipeline{
    agent {
        docker {
            // Node version compatible with Angular 14
            image 'node:16-alpine'
            // Cache npm between builds (optional but good)
            args '-v $HOME/.npm:/root/.npm'
        }
    }
    
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
                sh 'node -v || echo "Node not found; install node on agent" && node -v'
                sh 'npm -v || echo "npm not found; install npm on agent" && npm -v'
            }
        }
        stage('Install Dependencies'){
            steps{
                sh 'npm install'
            }
        }
        stage('Build Angular App'){
            steps{
                sh 'npm run build -- --configuration production'
                
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