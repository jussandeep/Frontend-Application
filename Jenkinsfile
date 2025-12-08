pipeline {
    agent any
    tools {
        nodejs 'NodeJS-18' 
    }
    
    environment {
        DOCKER_HUB_USER = 'jsandeep9866'
        IMAGE = "${DOCKER_HUB_USER}/frontend-application"
        TAG = "v1.0.${BUILD_NUMBER}"

        
    }
    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', 
                    url: 'https://github.com/jussandeep/Frontend-Application.git'
            }
        }
        // stage('Verify Node.js and npm') {
        //     steps {
        //         sh '''
        //             echo "Node and npm versions:"
        //             node -v
        //             npm -v
        //         '''
                
        //     }
        // }
        
        stage('Docker Build') {
            steps {
                sh "docker build -t ${IMAGE}:${TAG} ."
            }
        }
        stage('Push Docker Image') {
            steps {
                script {
                    withCredentials([string(credentialsId: 'DockerHubID', variable: 'DockerHubPwd')]) {
                        sh 'echo $DockerHubPwd | docker login -u ${DOCKER_HUB_USER} --password-stdin'
                        sh "docker push ${IMAGE}:${TAG}"
                        sh "docker push ${IMAGE}:latest"
    
                   }
                    
                }
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
