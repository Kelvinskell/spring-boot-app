pipeline {
    agent any
    environment {
        AWS_ACCESS_KEY_ID      = credentials('aws-access-key-id')
        AWS_SECRET_ACCESS_KEY  = credentials('aws-secret-access-key')
        DB_USERNAME_DEV        = credentials('db-username-dev')
        DB_PASSWORD_DEV        = credentials('db-password-dev')
        DB_USERNAME_STAGING    = credentials('db-username-staging')
        DB_PASSWORD_STAGING    = credentials('db-password-staging')
        DB_USERNAME_PROD       = credentials('db-username-prod')
        DB_PASSWORD_PROD       = credentials('db-password-prod')
        SNS_EMAIL              = credentials('sns-email-address')
        CONTAINER_NAME         = "Spring-Boot-App"
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
                    def imageTag = "${env.BUILD_ID}"  
                    def imageName = "kelvinskell/bh-spring-boot-app:${imageTag}" // Change this image name to reflect your own image repository
                    env.IMAGE_NAME = imageName
                    
                    sh """
                    docker build -t ${imageName} .
                    """
                }
            }
        }

        stage('Scan Image with Trivy') {
            steps {
                script {
                    sh """
                    trivy image --exit-code 0 --severity HIGH,CRITICAL ${env.IMAGE_NAME}
                    """
                }
            }
        }

        stage('Push Docker Image to DockerHub') {
            steps {
                script {
                    withDockerRegistry(credentialsId: 'docker') {
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
                                       -var='sns_email_address=${SNS_EMAIL}' \
                                       -var-file=${environment}.tfvars -auto-approve 
                        """
                    }
                    
                    // Get Values from Terraform outputs
                    env.CLUSTER_NAME_DEV = sh(script: 'terraform output -raw ecs_cluster_name', returnStdout: true).trim()
                    env.SERVICE_NAME_DEV = sh(script: 'terraform output -raw ecs_service_name', returnStdout: true).trim()
                    env.AWS_REGION_DEV = sh(script: 'terraform output -raw aws_region', returnStdout: true).trim()
                }
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
                                       -var='sns_email_address=${SNS_EMAIL}' \
                                       -var-file=${environment}.tfvars -auto-approve 
                        """
                    }

                    // Get the ECS cluster name from Terraform outputs
                    env.CLUSTER_NAME_STAGING = sh(script: 'terraform output -raw ecs_cluster_name', returnStdout: true).trim()
                    env.SERVICE_NAME_STAGING = sh(script: 'terraform output -raw ecs_service_name', returnStdout: true).trim()
                    env.AWS_REGION_STAGING = sh(script: 'terraform output -raw aws_region', returnStdout: true).trim()
                }
            }
        }

        stage('Update ECS Services') {
            steps {
                script {
                    // Update ECS Service for Development Environment
                    def currentTaskDefinitionDev = sh(script: """
                        aws ecs describe-services --cluster ${env.CLUSTER_NAME_DEV} \
                            --services ${env.SERVICE_NAME_DEV} \
                            --region ${env.AWS_REGION_DEV} \
                            --query 'services[0].taskDefinition' \
                            --output text
                    """, returnStdout: true).trim()

                    echo "Updating Development ECS Service: Current Task Definition: ${currentTaskDefinitionDev}"

                    sh """
                        aws ecs update-service --cluster ${env.CLUSTER_NAME_DEV} \
                                               --service ${env.SERVICE_NAME_DEV} \
                                               --force-new-deployment \
                                               --region ${env.AWS_REGION_DEV} \
                                               --task-definition ${currentTaskDefinitionDev} \
                                               --container-overrides '[
                                                   {
                                                       "name": "${env.CONTAINER_NAME}",
                                                       "image": "${env.IMAGE_NAME}"
                                                   }
                                               ]'
                    """

                    // Update ECS Service for Staging Environment
                    def currentTaskDefinitionStaging = sh(script: """
                        aws ecs describe-services --cluster ${env.CLUSTER_NAME_STAGING} \
                            --services ${env.SERVICE_NAME_STAGING} \
                            --region ${env.AWS_REGION_STAGING} \
                            --query 'services[0].taskDefinition' \
                            --output text
                    """, returnStdout: true).trim()

                    echo "Updating Staging ECS Service: Current Task Definition: ${currentTaskDefinitionStaging}"

                    sh """
                        aws ecs update-service --cluster ${env.CLUSTER_NAME_STAGING} \
                                               --service ${env.SERVICE_NAME_STAGING} \
                                               --force-new-deployment \
                                               --region ${env.AWS_REGION_STAGING} \
                                               --task-definition ${currentTaskDefinitionStaging} \
                                               --container-overrides '[
                                                   {
                                                       "name": "${env.CONTAINER_NAME}",
                                                       "image": "${env.IMAGE_NAME}"
                                                   }
                                               ]'
                    """
                }
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
                                       -var='sns_email_address=${SNS_EMAIL}' \
                                       -var-file=${environment}.tfvars -auto-approve
                        """
                    }

                    // Get the ECS cluster name from Terraform outputs
                    env.CLUSTER_NAME_PROD = sh(script: 'terraform output -raw ecs_cluster_name', returnStdout: true).trim()
                    env.SERVICE_NAME_PROD = sh(script: 'terraform output -raw ecs_service_name', returnStdout: true).trim()
                    env.AWS_REGION_PROD = sh(script: 'terraform output -raw aws_region', returnStdout: true).trim()
                }
            }
        }

        stage('Update ECS Service For Prod Environment') {
            steps {
                script {
                    // Get the current task definition ARN for the service
                    def currentTaskDefinitionProd = sh(script: """
                        aws ecs describe-services --cluster ${env.CLUSTER_NAME_PROD} \
                            --services ${env.SERVICE_NAME_PROD} \
                            --region ${env.AWS_REGION_PROD} \
                            --query 'services[0].taskDefinition' \
                            --output text
                    """, returnStdout: true).trim()

                    echo "Updating Production ECS Service: Current Task Definition: ${currentTaskDefinitionProd}"

                    // Update the ECS service with the new task definition and image override
                    sh """
                        aws ecs update-service --cluster ${env.CLUSTER_NAME_PROD} \
                                               --service ${env.SERVICE_NAME_PROD} \
                                               --force-new-deployment \
                                               --region ${env.AWS_REGION_PROD} \
                                               --task-definition ${currentTaskDefinitionProd} \
                                               --container-overrides '[
                                                   {
                                                       "name": "${env.CONTAINER_NAME}",
                                                       "image": "${env.IMAGE_NAME}"
                                                   }
                                               ]'
                    """
                }
            }
        }
    }

    post {
        success {
            script {
                snsPublish topicArn: "${env.SNS_TOPIC_ARN}", message: "Deployment of ECS service completed with image ${env.IMAGE_NAME} is Successful."
            }
        }
    }
}