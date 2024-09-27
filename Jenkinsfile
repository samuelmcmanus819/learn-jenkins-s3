pipeline {
    agent any
    environment {
        AWS_ACCESS_KEY_ID = credentials('aws-access-key-id')
        AWS_SECRET_ACCESS_KEY = credentials('aws-access-key')
        //Don't add build ID, because that will break if terraform doesn't need to re-deploy
        REACT_APP_VERSION = "1.2.3"
    }

    stages {
        stage('Build') {
            agent {
                docker {
                    image 'node:18-alpine'
                    reuseNode true
                }
            }
            steps {
                sh '''
                    cd learn-jenkins-app
                    npm install
                    npm run build
                '''
                stash includes: 'learn-jenkins-app/build/**, learn-jenkins-app/node_modules/**, learn-jenkins-app/package-lock.json', name: 'build-artifacts'
            }
        }

        stage('Dependency Scan') {
            agent {
                docker {
                    image 'node:18-alpine'
                }
            }
            steps {
                sh '''
                    cd learn-jenkins-app
                    mkdir -p scan-results
                    npm audit --json > scan-results/dependency-scan.json || true
                '''
            }
            post {
                always {
                    archiveArtifacts artifacts: 'learn-jenkins-app/scan-results/*', allowEmptyArchive: false
                }
            }
        }

        stage('Unit Test') {
            agent {
                docker {
                    image 'node:18-alpine'
                }
            }
            steps {
                unstash 'build-artifacts'
                sh '''
                    cd learn-jenkins-app
                    npm test
                '''
            }
            post {
                always {
                    junit 'learn-jenkins-app/test-results/junit.xml'
                }
            }
        }

        stage('Scan Terraform') {
            agent {
                docker {
                    image 'aquasec/tfsec:v1.28'
                     args '--entrypoint="" --user="root"'
                }
            }
            steps {
                sh '''
                    cd terraform
                    tfsec
                '''
            }
        }

        stage('Deploy'){
            agent {
                docker {
                    image 'hashicorp/terraform:1.9'
                     args '--entrypoint="" --user="root" -e AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID -e AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY'
                }
            }
            steps {
                unstash 'build-artifacts'
                sh '''
                    # Output the AWS environment variables
                    echo "AWS_ACCESS_KEY_ID: $AWS_ACCESS_KEY_ID" > junk2
                    echo "AWS_SECRET_ACCESS_KEY: $AWS_SECRET_ACCESS_KEY"
                    
                    # Install AWS CLI
                    apk add --no-cache aws-cli
                    export AWS_DEFAULT_REGION=us-east-1

                    # Deploy Jenkins App
                    cd terraform
                    terraform init
                    terraform apply -auto-approve
                    terraform output -json > terraform-output.json
                '''
                stash includes: 'terraform/terraform-output.json', name: 'terraform-output'
            }
        }

        stage('E2E Test') {
            agent {
                docker {
                    image 'mcr.microsoft.com/playwright:v1.39.0-jammy'
                    args '--user root'
                }
            }
            steps {
                dir('jenkins/deploy') {
                    unstash 'terraform-output'
                }
                sh '''
                    cd jenkins-app
                    apt update && apt install -y jq
                    export CI_ENVIRONMENT_URL="http://$(cat jenkins/deploy/terraform-output.json | jq -r '.website_url.value')" 
                    npx playwright test
                '''
            }
                post {
                always {
                    archiveArtifacts artifacts: 'jenkins-app/playwright-report/index.html', allowEmptyArchive: false
                }
            }
        }

        stage('Destroy'){
            agent {
                docker {
                    image 'hashicorp/terraform:1.9'
                     args '--entrypoint="" --user="root" -e AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID -e AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY'
                }
            }
            steps {
                unstash 'build-artifacts'
                sh '''
                    # Output the AWS environment variables
                    echo "AWS_ACCESS_KEY_ID: $AWS_ACCESS_KEY_ID" > junk2
                    echo "AWS_SECRET_ACCESS_KEY: $AWS_SECRET_ACCESS_KEY"
                    
                    # Install AWS CLI
                    apk add --no-cache aws-cli
                    export AWS_DEFAULT_REGION=us-east-1

                    # Deploy Jenkins App
                    cd terraform
                    terraform init
                    terraform destroy -auto-approve
                '''
            }
        }
    }
    // post {
    //     always {
    //         cleanWs()
    //     }
    // }
}
