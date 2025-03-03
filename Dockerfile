# Étape 1 : Compilation du projet avec Maven
FROM maven:3.9.9-eclipse-temurin-17 AS build

WORKDIR /app
COPY . .

# Compilation du projet et génération du fichier JAR
RUN mvn clean package -DskipTests

# Étape 2 : Création de l’image finale avec OpenJDK 17
FROM openjdk:17-jdk-alpine

WORKDIR /app

# Création d’un utilisateur non-root pour la sécurité
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
USER appuser

# Copie du fichier JAR généré
COPY --from=build /app/target/projettest.jar projettest.jar

# Copie des fichiers de configuration
COPY src/main/resources/application.properties /app/application.properties
COPY src/main/resources/application-dev.properties /app/application-dev.properties

# Exposition du port
ENV PORT=5000
EXPOSE ${PORT}

# Activation du profil dev et chargement des fichiers de config
ENV SPRING_CONFIG_LOCATION=file:/app/application.properties,file:/app/application-dev.properties
ENV SPRING_PROFILES_ACTIVE=dev

# Commande pour exécuter l’application
ENTRYPOINT ["java", "-jar", "-Djava.security.egd=file:/dev/./urandom", "-Dserver.port=5000", "projettest.jar"]
