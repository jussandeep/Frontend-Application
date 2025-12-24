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
                sh "docker tag ${IMAGE}:${TAG} ${IMAGE}:latest"
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

        // stage('Deploy to google cloud in k8s') {
        //     steps {
        //         script {
        //             // Load the JSON key file
        //             withCredentials([file(credentialsId: 'GOOGLE_CLOUD_KEY', variable: 'GOOGLE_KEY_FILE')]) {
                        
        //                 // --- Configuration (Set using confirmed values) ---
        //                 def PROJECT_ID = "adroit-poet-452006-a3" 
        //                 def CLUSTER_NAME = "k8scluster1"   
        //                 def CLUSTER_ZONE = "africa-south1-c"    
        //                 // -----------------------------------------------------------------

        //                 // 1. Activate the service account
        //                 sh "gcloud auth activate-service-account --key-file=${GOOGLE_KEY_FILE}"
                        
        //                 // 2. Set the project config (Answer to Question 1: YES)
        //                 sh "gcloud config set project ${PROJECT_ID}"

        //                 // 3. Get the credentials for the GKE cluster (Answer to Question 2: YES, the approach is correct)
        //                 sh "gcloud container clusters get-credentials ${CLUSTER_NAME} --zone ${CLUSTER_ZONE} --project ${PROJECT_ID}"

        //                 // 4. Apply the Kubernetes manifest (Answer to Question 3: MUST use frontend-app.yaml)
        //                 // Ensure your frontend-app.yaml is configured to pull the image using ${IMAGE}:${TAG}
        //                 sh "kubectl apply -f frontend-app.yaml" 
        //             }
        //         }
        //     }
        // }
        stage('Deploy to AWS EKS') {
            steps {
                sh '''
                  aws eks update-kubeconfig \
                    --region ap-south-1 \
                    --name new-cluster

                  kubectl apply -f frontend-app.yaml
                  kubectl rollout status deployment/frontend-deployment
                '''
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
