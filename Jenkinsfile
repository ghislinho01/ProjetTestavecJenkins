pipeline {
    agent any  // Utilise un agent disponible pour l'exécution du pipeline

    tools {
        jdk 'JAVA_HOME'  // Spécifie l'emplacement de JDK à utiliser
        maven 'MAVEN_HOME'  // Spécifie l'emplacement de Maven à utiliser
        dockerTool 'DOCKER_HOME'  // Spécifie l'emplacement de Docker à utiliser
    }

    environment {
        GIT_REPO_URL = 'https://github.com/ghislinho01/ProjetTestavecJenkins.git'
        BRANCH = 'main'
        BUILD_DIR = 'target'
        JAR_NAME = 'projettest.jar'
        DEPLOY_DIR = 'C:\\Users\\DGMP\\Desktop\\JAR\\test\\Dev\\back'
        NSSM_PATH = 'C:\\nssm\\nssm.exe'
        SERVICE_NAME = 'atsinDev'
        DOCKER_REGISTRY = 'docker.io/ghislain92'
        DOCKER_IMAGE_NAME = 'projettest2'
        SWARM_STACK_NAME = 'springboot-stack1'
    }

    stages {
        stage('Paramétrage') {
            steps {
                git branch: "${BRANCH}", url: "${GIT_REPO_URL}"
            }
        }

        stage('Construction du JAR') {
            steps {
                script {
                    echo "Nettoyage et construction du JAR..."
                    bat 'mvn clean install -DskipTests'
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    echo "Build de l'image Docker..."
                    // Utilisation de Git Bash via bat pour Docker Build
                    bat '"C:\\Program Files\\Git\\bin\\bash.exe" -c "docker build -t ${DOCKER_REGISTRY}/${DOCKER_IMAGE_NAME}:latest ."'
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                script {
                    echo "Pousser l'image Docker vers le registre..."
                    // Utilisation de Git Bash pour Docker Push
                    bat '"C:\\Program Files\\Git\\bin\\bash.exe" -c "docker push ${DOCKER_REGISTRY}/${DOCKER_IMAGE_NAME}:latest"'
                }
            }
        }

        stage('Deploy to Docker Swarm') {
            steps {
                script {
                    echo "Déploiement de l'application sur Docker Swarm..."
                    // Déploiement Docker Swarm via Git Bash
                    bat '"C:\\Program Files\\Git\\bin\\bash.exe" -c "docker stack deploy -c docker-compose.yml ${SWARM_STACK_NAME}"'
                }
            }
        }
    }

    post {
        success {
            echo "Build et déploiement sur Docker Swarm réussis."
        }
        failure {
            echo "Échec du build ou du déploiement."
        }
    }
}
