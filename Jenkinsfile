
pipeline {
    agent any
 
    tools {
        jdk 'jdk'
        nodejs 'node'
    }
 
    environment {
        SCANNER_HOME = tool 'sonar-scanner'
    }
 
    parameters {
        string(
            name: 'tf_action',
            defaultValue: 'apply',
            description: 'Terraform action for the EKS stage: apply or destroy'
        )
    }
 
    stages {
 
        stage('Clean Workspace') {
            steps {
                cleanWs()
            }
        }
 
        stage('Checkout from Git') {
            steps {
                git branch: 'master', credentialsId: 'github-token', url: 'https://github.com/GitHarsh999/DevsecOps.git'
            }
        }
 
        stage('Sonarqube Analysis') {
            steps {
                withSonarQubeEnv('SonarQube') {
                    sh ''' $SCANNER_HOME/bin/sonar-scanner -Dsonar.projectName=Hotstar \
                    -Dsonar.projectKey=Hotstar '''
                }
            }
        }
 
        stage('Quality Gate') {
            steps {
                script {
                    waitForQualityGate abortPipeline: false, credentialsId: 'Sonar-token'
                }
            }
        }
 
        stage('Install Dependencies') {
            steps {
                sh "npm install"
            }
        }
 
        stage('OWASP FS SCAN') {
            steps {
                dependencyCheck additionalArguments: '--scan ./ --disableYarnAudit --disableNodeAudit --nvdApiKey d7e8c629-7da9-4f96-8a4a-a45fd3f213ba', odcInstallation: 'DC'
                dependencyCheckPublisher pattern: '**/dependency-check-report.xml'
            }
        }
 
        stage('TRIVY FS SCAN') {
            steps {
                sh "trivy fs . > trivyfs.txt"
            }
        }
 
        stage('Docker Build & Push') {
            steps {
                script {
                    withDockerRegistry(credentialsId: 'docker', toolName: 'docker') {
                        sh "docker build -t hotstar ."
                        sh "docker tag hotstar bukbukbucket/hotstar:latest"
                        sh "docker push bukbukbucket/hotstar:latest"
                    }
                }
            }
        }
 
        stage('TRIVY Image Scan') {
            steps {
                sh "trivy image bukbukbucket/hotstar:latest > trivyimage.txt"
            }
        }
 
        stage('Terraform Init & Validate') {
            steps {
                dir('Terraform') {
                    sh 'terraform init'
                    sh 'terraform validate'
                }
            }
        }
 
        stage('Terraform Plan') {
            steps {
                dir('Terraform') {
                    withCredentials([
                        [$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-cred']
                    ]) {
                        sh 'terraform plan -var="key_name=terra"'
                    }
                }
            }
        }
 
        stage('Terraform Apply/Destroy (VPC + EKS)') {
            steps {
                dir('Terraform') {
                    withCredentials([
                        [$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-cred']
                    ]) {
                        sh 'terraform ${tf_action} -var="key_name=terra" --auto-approve'
                    }
                }
            }
        }
 
        stage('Configure kubectl') {
            when {
                expression { params.tf_action == 'apply' }
            }
            steps {
                withCredentials([
                    [$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-cred']
                ]) {
                    sh 'aws eks update-kubeconfig --region ap-south-1 --name hotstar-eks-cluster'
                }
            }
        }
 
        stage('Deploy to EKS') {
            when {
                expression { params.tf_action == 'apply' }
            }
            steps {
                sh 'kubectl apply -f K8S/manifest.yml'
                sh 'kubectl get pods -o wide'
                sh 'kubectl get svc hotstar-service'
            }
        }
    }
 
    post {
        always {
            script {
                def buildStatus = currentBuild.currentResult
                def buildUser = currentBuild.getBuildCauses('hudson.model.Cause$UserIdCause')[0]?.userId ?: 'Github User'
 
                emailext (
                    subject: "Pipeline ${buildStatus}: ${env.JOB_NAME} #${env.BUILD_NUMBER}",
                    body: """
                        <p>This is a Jenkins HOTSTAR CICD + EKS deployment pipeline status.</p>
                        <p>Project: ${env.JOB_NAME}</p>
                        <p>Build Number: ${env.BUILD_NUMBER}</p>
                        <p>Build Status: ${buildStatus}</p>
                        <p>Terraform action: ${params.tf_action}</p>
                        <p>Started by: ${buildUser}</p>
                        <p>Build URL: <a href="${env.BUILD_URL}">${env.BUILD_URL}</a></p>
                    """,
                    to: 'naganeharshwardhan64@gmail.com',
                    from: 'naganeharshwardhan64@gmail.com',
                    replyTo: 'naganeharshwardhan64@gmail.com',
                    mimeType: 'text/html',
                    attachmentsPattern: 'trivyfs.txt,trivyimage.txt'
                )
            }
        }
    }
}
 
