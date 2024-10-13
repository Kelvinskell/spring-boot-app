pipeline {
    agent any
    environment {
        AWS_ACCESS_KEY_ID      = credentials('aws-access-key-id')
        AWS_SECRET_ACCESS_KEY  = credentials('aws-secret-access-key')
        DB_USERNAME            = credentials('db-username')
        DB_PASSWORD            = credentials('db-password')
        SNS_EMAIL              = credentials('sns-email-address')
    }
    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Run Basic Tests') {
            steps {
                script {
                    sh 'mvn test'
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    // Dynamically tag the Docker image
                    def imageTag = "${env.BUILD_ID}"  
                    def imageName = "kelvinskell/bh-spring-boot-app:${imageTag}"
                    env.IMAGE_NAME = imageName // Make it accessible to other stages
                    
                    // Build the Docker image
                    sh """
                    docker build -t ${imageName} .
                    """
                }
            }
        }

        stage('Scan Image with Trivy') {
            steps {
                script {
                    sh '''
                    trivy image --exit-code 1 --severity HIGH,CRITICAL $DOCKERHUB_REPO:$IMAGE_TAG
                    '''
                }
            }
        }

        stage('Push Docker Image to DockerHub'){
        steps{
            script{
            withDockerRegistry(credentialsId: 'docker'){
                sh """
                docker push ${env.IMAGE_NAME}
                """
            }
        }
    }
        }
        
        stage('Deploy to Dev Environment') {
            steps {
                script {
                    dir('terraform') {
                    def environment = 'dev'
                    sh """
                    terraform init -input=false
                    terraform workspace select ${environment} || terraform workspace new ${environment}
                    terraform apply -var='db_username=${DB_USERNAME_DEV}' \
                                   -var='db_password=${DB_PASSWORD_DEV}' \
                                   -var='image_name=${env.IMAGE_NAME}' \
                                   -var-file=${environment}.tfvars -auto-approve \
                                   -json > tf-output.json
                    """
                    }
                }

                    // Update ECS service in Dev
                    script {
                        def tfOutput = readJSON file: "terraform/tf-output.json"
                        env.CLUSTER_NAME_DEV = tfOutput.values.outputs.ecs_cluster_name.value
                        env.SERVICE_NAME_DEV = tfOutput.values.outputs.ecs_service_name.value
                        env.AWS_REGION_DEV = tfOutput.values.outputs.region
                    }
                    sh """
                    aws ecs update-service --cluster ${CLUSTER_NAME_DEV} \
                                           --service ${SERVICE_NAME_DEV} \
                                           --force-new-deployment \
                                           --region ${AWS_REGION_DEV} \
                                           --desired-count 1 \
                                           --cli-input-json '{
                                                "taskDefinition": {
                                                    "containerDefinitions": [
                                                        {
                                                            "name": "${env.CONTAINER_NAME}",
                                                            "image": "${env.IMAGE_NAME}"
                                                        }
                                                    ]
                                                }
                                            }'
                    """
                }
            }

        stage('Deploy to Staging Environment') {
            steps {
                script {
                    dir('terraform') {
                    def environment = 'staging'
                    sh """
                    terraform init -input=false
                    terraform workspace select ${environment} || terraform workspace new ${environment}
                    terraform apply -var='db_username=${DB_USERNAME_STAGING}' \
                                   -var='db_password=${DB_PASSWORD_STAGING}' \
                                   -var='image_name=${env.IMAGE_NAME}' \
                                   -var-file=${environment}.tfvars -auto-approve \
                                   -json > tf-output.json
                    """
                    }
                }

                    // Update ECS service in staging
                    script {
                        def tfOutput = readJSON file: "terraform/tf-output.json"
                        env.CLUSTER_NAME_STAGING = tfOutput.values.outputs.ecs_cluster_name.value
                        env.SERVICE_NAME_DSTAGING = tfOutput.values.outputs.ecs_service_name.value
                        env.AWS_REGION_STAGING = tfOutput.values.outputs.region
                    }
                    sh """
                    aws ecs update-service --cluster ${CLUSTER_NAME_STAGING} \
                                           --service ${SERVICE_NAME_STAGING} \
                                           --force-new-deployment \
                                           --region ${AWS_REGION_STAGING} \
                                           --desired-count 1 \
                                           --cli-input-json '{
                                                "taskDefinition": {
                                                    "containerDefinitions": [
                                                        {
                                                            "name": "${env.CONTAINER_NAME}",
                                                            "image": "${env.IMAGE_NAME}"
                                                        }
                                                    ]
                                                }
                                            }'
                    """
                }
            }

        stage('Deploy to Prod (Manual Approval)') {
            steps {
                script {
                input message: 'Approve Deployment to Production?', ok: 'Deploy to Prod'
                def environment = 'prod'
                dir('terraform') {
                    sh """
                    terraform init -input=false
                    terraform workspace select ${environment} || terraform workspace new ${environment}
                    terraform apply -var='db_username=${DB_USERNAME_PROD}' \
                                   -var='db_password=${DB_PASSWORD_PROD}' \
                                   -var='image_name=${env.IMAGE_NAME}' \
                                   -var-file=${environment}.tfvars -auto-approve \
                                   -json > tf-output.json
                    """
                    }
                }

                    // Update ECS service in prod
                    script {
                        def tfOutput = readJSON file: "terraform/tf-output.json"
                        env.CLUSTER_NAME_PROD = tfOutput.values.outputs.ecs_cluster_name.value
                        env.SERVICE_NAME_PROD = tfOutput.values.outputs.ecs_service_name.value
                        env.SNS_TOPIC_ARN = tfOutput.values.outputs.sns_topic_arn
                        env.AWS_REGION_PROD = tfOutput.values.outputs.region
                    }
                    sh """
                    aws ecs update-service --cluster ${CLUSTER_NAME_PROD} \
                                           --service ${SERVICE_NAME_PROD} \
                                           --force-new-deployment \
                                           --region ${AWS_REGION} \
                                           --desired-count 1 \
                                           --cli-input-json '{
                                                "taskDefinition": {
                                                    "containerDefinitions": [
                                                        {
                                                            "name": "${env.CONTAINER_NAME}",
                                                            "image": "${imageName}"
                                                        }
                                                    ]
                                                }
                                            }'
                    """
                }
            }

        
        stage('Notify SNS on Prod Deployment') {
            steps {
                
            }
        }
    }

    post {
        failure {
            script {
                snsNotify topicArn: "$SNS_TOPIC_ARN", message: "Deployment failed in the pipeline!"
            }
        }
        success {
            script {
                    snsNotify topicArn: "${env.SNS_TOPIC_ARN}", message: "Deployment of ECS service completed with image $IMAGE_TAG is Successful."
                }
        }
    }
}