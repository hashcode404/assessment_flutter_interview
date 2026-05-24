pipeline {
    agent any

    environment {
        PATH = "/Users/pranav/flutter/bin:/opt/homebrew/bin:/usr/local/bin:${env.PATH}"
        
    }

    stages {

        stage('Checkout') {
            steps {
                git branch: 'feature/jenkins-setup',
                url: 'https://github.com/hashcode404/assessment_flutter_interview.git'
            }
        }

        stage('Flutter Doctor') {
            steps {
                sh 'flutter doctor'
            }
        }

        stage('Flutter Pub Get') {
            steps {
                sh 'flutter pub get'
            }
        }

        stage('Build APK') {
            steps {
                sh 'flutter build apk --release'
            }
        }

         stage('Upload to Firebase') {
            steps {

                withCredentials([
                    string(
                        credentialsId: 'FIREBASE_TOKEN',
                        variable: 'FIREBASE_TOKEN'
                    ),
                    string(
                        credentialsId: 'FIREBASE_ANDROID_APP_ID',
                        variable: 'FIREBASE_ANDROID_APP_ID'
                    )
                ]) {

                    sh '''
                    firebase appdistribution:distribute \
                    build/app/outputs/flutter-apk/app-release.apk \
                    --app $FIREBASE_ANDROID_APP_ID \
                    --groups "qa-team" \
                    --release-notes "$(git log -1 --pretty=%B)" \
                    --token "$FIREBASE_TOKEN"
                    '''
                }
            }
        }
    }
}