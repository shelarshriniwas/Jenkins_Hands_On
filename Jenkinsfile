pipeline {

    agent any

    stages {

        stage('Webhook Triggered') {
            steps {
                echo 'GitHub Webhook triggered Jenkins!'
            }
        }

        stage('Checkout') {
            steps {
                echo 'GitHub repository checked out.'
            }
        }

        stage('Check Files') {
            steps {
                bat 'dir'
            }
        }

        stage('Build') {
            steps {
                echo 'Build completed successfully.'
            }
        }
    }

    post {
        success {
            echo 'Pipeline SUCCESS'
        }

        failure {
            echo 'Pipeline FAILED'
        }
    }
}