FROM eclipse-temurin:8-jre

WORKDIR /opt/webgoat
COPY target/WebGoat-6.0.1-war-exec.jar /opt/webgoat/webgoat.jar

EXPOSE 8080
ENTRYPOINT ["java", "-jar", "/opt/webgoat/webgoat.jar"]
