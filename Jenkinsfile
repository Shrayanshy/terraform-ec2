pipeline {
    agent any
    stages {
        stage('git checkout onlinebookstore') {
            steps {
                sh 'rm -rf *'
                git 'https://github.com/Pritam-Khergade/onlinebookstore.git'
            }
        }
        stage('maven build') {
            steps {
                sh'''sudo yum -y install maven 
                mvn clean package 
                '''
            }
        }
        stage('aws s3 copy') {
            steps {
                sh''' aws s3 ls 
                aws s3 cp ./target/onlinebookstore.war s3://selmonbhoi-ki-bucket/onlinebookstore${BUILD_NUMBER}.war
                '''
            }
        }
        stage('git checkout') {
            steps {
                sh 'rm -rf *'
                sh 'git clone https://github.com/Shrayanshy/terraform-ec2.git'
            }
        }
        stage('change directory') {
            steps {
                sh'''
                ls -al
                terraform init 
                terraform plan 
                terraform apply --auto-approve
                '''
            }
        }
    }
}
