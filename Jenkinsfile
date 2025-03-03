pipeline {
    agent any  // Utilise un agent disponible pour l'exécution du pipeline

    tools {
        jdk 'jdk-17'  // Spécifie l'emplacement de JDK à utiliser
        maven 'maven-3.9.9'  // Spécifie l'emplacement de Maven à utiliser
    }

    environment {
        // Définition des variables d'environnement utilisées tout au long du pipeline
        GIT_REPO_URL = 'https://github.com/ghislinho01/ProjetTestavecJenkins.git'  // URL du dépôt Git
        BRANCH = 'main'  // Branche du dépôt à utiliser pour le checkout
        BUILD_DIR = 'target'  // Répertoire de sortie pour le build Maven
        //JAR_NAME = 'monprojetspringboot-0.0.1-SNAPSHOT.jar'  // Nom du fichier JAR généré par Maven
        JAR_NAME = 'projettest.jar'  // Nom du fichier JAR généré par Maven
        //DEPLOY_DIR = 'C:\\Users\\DGMP\\Desktop\\JAR\\test\\Dev\\back'  // Répertoire de déploiement sur windows
        DEPLOY_DIR = 'C:\\Users\\HP\\Desktop\\JAR\\test\\Dev\\back'  // Répertoire de déploiement sur windows
        CONFIG_FILE = "${DEPLOY_DIR}\\config\\application-dev.properties"  // Fichier de configuration de l'application
    }

    stages {
        // Première étape : Paramétrage
        stage('Parametrage') {
            steps {
                // Récupération du code source depuis le dépôt Git spécifié
                git branch: "${BRANCH}", url: "${GIT_REPO_URL}"
            }
        }

        // Deuxième étape : Construction du fichier JAR avec Maven
        stage('Construction du JAR') {
            steps {
                script {
                    echo "Nettoyage et construction du JAR..."
                    // Exécution de Maven pour nettoyer et construire le JAR avec les arguments spécifiés pour la mémoire
                    bat "mvn clean package -e -DargLine=\"-Xmx1024m -Xms512m\""
                }
            }
        }

        // Troisième étape : Déploiement de l'application
        stage('Deploiement') {
            steps {
                script {
                    echo "Vérification de l'existence du fichier JAR..."

                    // Vérifie si le fichier JAR existe après la construction
                    def jarExists = fileExists("${BUILD_DIR}\\${JAR_NAME}")
                    if (!jarExists) {
                        error "Fichier JAR introuvable : ${BUILD_DIR}\\${JAR_NAME}"
                    }

                    // Sauvegarde du fichier JAR précédent s'il existe déjà
                    echo "Sauvegarde de l'ancien JAR si nécessaire..."
                    def oldJarPath = "${DEPLOY_DIR}\\${JAR_NAME}"
                    if (fileExists(oldJarPath)) {
                        def backupPath = "${DEPLOY_DIR}\\backup_${JAR_NAME}_${new Date().format('yyyyMMddHHmmss')}"
                        echo "Sauvegarde de l'ancien JAR vers ${backupPath}"
                        bat "move /Y ${oldJarPath} ${backupPath}"
                    }

                    // Copie du nouveau fichier JAR dans le répertoire de déploiement
                    echo "Copie du nouveau JAR vers ${DEPLOY_DIR}"
                    bat "copy /Y ${BUILD_DIR}\\${JAR_NAME} ${DEPLOY_DIR}\\${JAR_NAME}"

                    // Lancement du fichier JAR directement sans créer un service Windows
                    echo "Lancement de l'application avec Java..."
                    bat "start java -jar ${DEPLOY_DIR}\\${JAR_NAME}"

                    echo "Déploiement réussi et application lancée sans service Windows."
                }
            }
        }
    }

    // Étapes post-pipeline : actions après la fin du pipeline
    post {
        // Si le pipeline réussit, afficher un message de succès
        success {
            echo "Build et déploiement de ${JAR_NAME} réussis."
        }
        // Si le pipeline échoue, afficher un message d'échec
        failure {
            echo "Échec du build ou du déploiement de ${JAR_NAME}."
        }
    }
}
