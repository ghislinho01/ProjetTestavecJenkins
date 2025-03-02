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
        DEPLOY_DIR = 'C:\\Users\\DGMP\\Desktop\\JAR\\test\\Dev\\back'  // Répertoire de déploiement sur windows
        CONFIG_FILE = "${DEPLOY_DIR}\\config\\application-dev.properties"  // Fichier de configuration de l'application
        NSSM_PATH = 'C:\\nssm\\nssm.exe'  // Chemin vers l'outil NSSM pour gérer le service Windows
        SERVICE_NAME = 'atsinDev'  // Nom du service Windows
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
                    echo "Vérification de l'existence du service ${SERVICE_NAME}..."

                    // Vérifie si le service existe déjà sur la machine Windows
                    def serviceExists = bat(script: "sc query ${SERVICE_NAME} | findstr /C:\"SERVICE_NAME\"", returnStatus: true) == 0

                    // Si le service existe, il est arrêté et supprimé avant d'être recréé
                    if (serviceExists) {
                        echo "Service ${SERVICE_NAME} trouvé. Arrêt et suppression..."
                        bat "${NSSM_PATH} stop ${SERVICE_NAME} || echo Service non démarré"
                        sleep 5  // Pause de 5 secondes avant suppression
                        bat "${NSSM_PATH} remove ${SERVICE_NAME} confirm"
                    } else {
                        echo "Service ${SERVICE_NAME} non trouvé, création d'un nouveau service."
                    }

                    // Vérifie si le fichier JAR existe après la construction
                    echo "Vérification de l'existence du fichier JAR..."
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

                    // Création et démarrage du service avec NSSM
                    echo "Création du service ${SERVICE_NAME} avec NSSM..."
                    bat """
                    ${NSSM_PATH} install ${SERVICE_NAME} "${JAVA_HOME}\\bin\\java.exe" "-jar ${DEPLOY_DIR}\\${JAR_NAME}"
                    ${NSSM_PATH} set ${SERVICE_NAME} AppDirectory ${DEPLOY_DIR}
                    ${NSSM_PATH} set ${SERVICE_NAME} AppStdout ${DEPLOY_DIR}\\app.log
                    ${NSSM_PATH} set ${SERVICE_NAME} AppStderr ${DEPLOY_DIR}\\app.log
                    ${NSSM_PATH} set ${SERVICE_NAME} Start SERVICE_AUTO_START
                    ${NSSM_PATH} start ${SERVICE_NAME}
                    """

                    // Vérification que le service a démarré correctement
                    echo "Vérification de l'état du service après démarrage..."
                    def serviceStarted = bat(script: "sc query ${SERVICE_NAME} | findstr /C:\"RUNNING\"", returnStatus: true) == 0

                    // Si le service n'a pas démarré, restauration de l'ancien JAR et tentative de redémarrage
                    if (!serviceStarted) {
                        echo "Le service ${SERVICE_NAME} n'a pas démarré correctement. Restauration de l'ancien JAR..."

                        // Récupère la liste des fichiers de sauvegarde
                        def backupFiles = bat(script: "dir /B /O-D ${DEPLOY_DIR}\\backup_*.jar", returnStdout: true).trim().split("\n")
                        if (backupFiles.length > 0) {
                            def lastBackup = backupFiles[0].trim()
                            bat "move /Y ${DEPLOY_DIR}\\${lastBackup} ${DEPLOY_DIR}\\${JAR_NAME}"
                            echo "Ancien JAR restauré. Tentative de redémarrage du service..."
                            bat "${NSSM_PATH} start ${SERVICE_NAME}"

                            // Vérification que le service redémarré fonctionne
                            def restartSuccess = bat(script: "sc query ${SERVICE_NAME} | findstr /C:\"RUNNING\"", returnStatus: true) == 0
                            if (!restartSuccess) {
                                error "Impossible de restaurer et redémarrer le service ${SERVICE_NAME}."
                            }
                        } else {
                            error "Aucun backup trouvé pour restaurer l'ancien JAR."
                        }
                    }

                    // Confirmation du démarrage du service
                    echo "Service ${SERVICE_NAME} installé et démarré avec succès."
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
