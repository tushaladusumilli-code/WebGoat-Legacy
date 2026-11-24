pipeline {
  agent { label 'webgoat-builder' }
  options { timestamps(); disableConcurrentBuilds() }
  parameters {
    string(name:'NEXUS_DOCKER_REGISTRY',defaultValue:'host.docker.internal:18080')
    string(name:'NEXUS_MAVEN_REPOSITORY_URL',defaultValue:'http://nexus:8081/repository/webgoat-maven/')
    string(name:'NEXUS_CREDENTIALS_ID',defaultValue:'f032fbb2-a308-407d-a28d-5940b0cc70ed')
    string(name:'WEBGOAT_HOST_PORT',defaultValue:'8082')
  }
  environment { IMAGE_NAME='webgoat-legacy'; APP_CONTAINER_NAME='webgoat-legacy' }
  stages {
    stage('Build and publish Maven artifact') {
      steps {
        withCredentials([usernamePassword(credentialsId:params.NEXUS_CREDENTIALS_ID,usernameVariable:'NEXUS_USER',passwordVariable:'NEXUS_PASSWORD')]) {
          script {
            def xmlEscape = { v -> (v ?: '').replace('&','&amp;').replace('<','&lt;').replace('>','&gt;').replace('"','&quot;').replace("'",'&apos;') }
            writeFile file:'.mvn-settings.xml', text:"""<settings xmlns="http://maven.apache.org/SETTINGS/1.2.0"><mirrors><mirror><id>nexus-public</id><url>http://nexus:8081/repository/maven-public/</url><mirrorOf>*</mirrorOf></mirror></mirrors><servers><server><id>nexus-public</id><username>${xmlEscape(env.NEXUS_USER)}</username><password>${xmlEscape(env.NEXUS_PASSWORD)}</password></server><server><id>nexus-hosted</id><username>${xmlEscape(env.NEXUS_USER)}</username><password>${xmlEscape(env.NEXUS_PASSWORD)}</password></server></servers></settings>"""
          }
          withEnv(["JAVA_HOME=${env.JAVA8_HOME}","PATH+JAVA8=${env.JAVA8_HOME}/bin"]) {
            sh 'mvn -B -s .mvn-settings.xml -DskipTests clean package'
            sh 'test -f target/WebGoat-6.0.1-war-exec.jar'
            sh '''set +x; mvn -B -s .mvn-settings.xml org.apache.maven.plugins:maven-deploy-plugin:3.1.3:deploy-file -Dfile=target/WebGoat-6.0.1-war-exec.jar -DgroupId=org.owasp.webgoat -DartifactId=webgoat-legacy -Dversion=6.0.1-$BUILD_NUMBER -Dpackaging=jar -DrepositoryId=nexus-hosted -Durl="$NEXUS_MAVEN_REPOSITORY_URL"'''
          }
        }
      }
      post { always { sh 'rm -f "$WORKSPACE/.mvn-settings.xml"' } }
    }
    stage('Build and publish Docker image') {
      steps {
        sh 'docker build -t $IMAGE_NAME:$BUILD_NUMBER .'
        withCredentials([usernamePassword(credentialsId:params.NEXUS_CREDENTIALS_ID,usernameVariable:'NEXUS_USER',passwordVariable:'NEXUS_PASSWORD')]) {
          sh '''set +x; printf '%s' "$NEXUS_PASSWORD" | docker login "$NEXUS_DOCKER_REGISTRY" -u "$NEXUS_USER" --password-stdin; docker tag "$IMAGE_NAME:$BUILD_NUMBER" "$NEXUS_DOCKER_REGISTRY/$IMAGE_NAME:$BUILD_NUMBER"; docker push "$NEXUS_DOCKER_REGISTRY/$IMAGE_NAME:$BUILD_NUMBER"; docker logout "$NEXUS_DOCKER_REGISTRY"'''
        }
      }
    }
    stage('Deploy locally') {
      steps {
        sh '''case "$WEBGOAT_HOST_PORT" in ''|*[!0-9]*) echo 'WEBGOAT_HOST_PORT must be numeric' >&2; exit 2 ;; esac; docker rm -f "$APP_CONTAINER_NAME" 2>/dev/null || true; docker run -d --name "$APP_CONTAINER_NAME" --restart unless-stopped -p "127.0.0.1:$WEBGOAT_HOST_PORT:8080" "$IMAGE_NAME:$BUILD_NUMBER"'''
      }
    }
  }
  post { always { sh 'rm -f "$WORKSPACE/.mvn-settings.xml"'; archiveArtifacts artifacts:'target/*.war,target/*-war-exec.jar',fingerprint:true,allowEmptyArchive:true } }
}
pipeline {
    agent { label 'webgoat-builder' }
    options { timestamps(); disableConcurrentBuilds() }
    parameters {
        string(name: 'NEXUS_DOCKER_REGISTRY', defaultValue: 'host.docker.internal:18080')
        string(name: 'NEXUS_MAVEN_REPOSITORY_URL', defaultValue: 'http://nexus:8081/repository/webgoat-maven/')
        string(name: 'NEXUS_CREDENTIALS_ID', defaultValue: 'nexus-credentials')
        string(name: 'WEBGOAT_HOST_PORT', defaultValue: '8082')
    }
    environment { IMAGE_NAME = 'webgoat-legacy'; APP_CONTAINER_NAME = 'webgoat-legacy' }
    stages {
        stage('Build and publish Maven artifact') {
            steps {
                withCredentials([usernamePassword(credentialsId: params.NEXUS_CREDENTIALS_ID, usernameVariable: 'NEXUS_USER', passwordVariable: 'NEXUS_PASSWORD')]) {
                    script {
                        def xmlEscape = { value -> (value ?: '').replace('&', '&amp;').replace('<', '&lt;').replace('>', '&gt;').replace('"', '&quot;').replace("'", '&apos;') }
                        writeFile file: '.mvn-settings.xml', text: """<settings xmlns="http://maven.apache.org/SETTINGS/1.2.0"><mirrors><mirror><id>nexus-public</id><url>http://nexus:8081/repository/maven-public/</url><mirrorOf>*</mirrorOf></mirror></mirrors><servers><server><id>nexus-public</id><username>${xmlEscape(env.NEXUS_USER)}</username><password>${xmlEscape(env.NEXUS_PASSWORD)}</password></server><server><id>nexus-hosted</id><username>${xmlEscape(env.NEXUS_USER)}</username><password>${xmlEscape(env.NEXUS_PASSWORD)}</password></server></servers></settings>"""
                    }
                    sh 'mvn -B -s .mvn-settings.xml -DskipTests clean package'
                    sh 'test -f target/WebGoat-6.0.1-war-exec.jar'
                    sh '''mvn -B -s .mvn-settings.xml org.apache.maven.plugins:maven-deploy-plugin:3.1.3:deploy-file -Dfile=target/WebGoat-6.0.1-war-exec.jar -DgroupId=org.owasp.webgoat -DartifactId=webgoat-legacy -Dversion=6.0.1-$BUILD_NUMBER -Dpackaging=jar -DrepositoryId=nexus-hosted -Durl="$NEXUS_MAVEN_REPOSITORY_URL"'''
                }
            }
            post { always { sh 'rm -f "$WORKSPACE/.mvn-settings.xml"' } }
        }
        stage('Build and publish Docker image') {
            steps {
                sh 'docker build -t $IMAGE_NAME:$BUILD_NUMBER .'
                withCredentials([usernamePassword(credentialsId: params.NEXUS_CREDENTIALS_ID, usernameVariable: 'NEXUS_USER', passwordVariable: 'NEXUS_PASSWORD')]) {
                    sh '''set +x; printf '%s' "$NEXUS_PASSWORD" | docker login "$NEXUS_DOCKER_REGISTRY" -u "$NEXUS_USER" --password-stdin; docker tag "$IMAGE_NAME:$BUILD_NUMBER" "$NEXUS_DOCKER_REGISTRY/$IMAGE_NAME:$BUILD_NUMBER"; docker push "$NEXUS_DOCKER_REGISTRY/$IMAGE_NAME:$BUILD_NUMBER"; docker logout "$NEXUS_DOCKER_REGISTRY"'''
                }
            }
        }
        stage('Deploy locally') {
            steps {
                sh '''case "$WEBGOAT_HOST_PORT" in ''|*[!0-9]*) echo 'WEBGOAT_HOST_PORT must be numeric' >&2; exit 2 ;; esac; docker rm -f "$APP_CONTAINER_NAME" 2>/dev/null || true; docker run -d --name "$APP_CONTAINER_NAME" --restart unless-stopped -p "127.0.0.1:$WEBGOAT_HOST_PORT:8080" "$IMAGE_NAME:$BUILD_NUMBER"'''
            }
        }
    }
    post { always { sh 'rm -f "$WORKSPACE/.mvn-settings.xml"'; archiveArtifacts artifacts: 'target/*.war,target/*-war-exec.jar', fingerprint: true, allowEmptyArchive: true } }
}
pipeline {
  agent { label 'webgoat-builder' }
  options { timestamps(); disableConcurrentBuilds() }
  parameters {
    string(name:'NEXUS_DOCKER_REGISTRY',defaultValue:'host.docker.internal:18080')
    string(name:'NEXUS_MAVEN_REPOSITORY_URL',defaultValue:'http://nexus:8081/repository/webgoat-maven/')
    string(name:'NEXUS_CREDENTIALS_ID',defaultValue:'nexus-credentials')
    string(name:'WEBGOAT_HOST_PORT',defaultValue:'8082')
  }
  environment { IMAGE_NAME='webgoat-legacy'; APP_CONTAINER_NAME='webgoat-legacy' }
  stages {
    stage('Build') {
      steps {
        withCredentials([usernamePassword(credentialsId:params.NEXUS_CREDENTIALS_ID,usernameVariable:'NEXUS_USER',passwordVariable:'NEXUS_PASSWORD')]) {
          script {
            def xmlEscape = { v -> (v ?: '').replace('&','&amp;').replace('<','&lt;').replace('>','&gt;').replace('"','&quot;').replace("'",'&apos;') }
            writeFile file:'.mvn-settings.xml', text:"""<settings xmlns="http://maven.apache.org/SETTINGS/1.2.0"><mirrors><mirror><id>nexus-public</id><url>http://nexus:8081/repository/maven-public/</url><mirrorOf>*</mirrorOf></mirror></mirrors><servers><server><id>nexus-public</id><username>\${xmlEscape(env.NEXUS_USER)}</username><password>\${xmlEscape(env.NEXUS_PASSWORD)}</password></server><server><id>nexus-hosted</id><username>\${xmlEscape(env.NEXUS_USER)}</username><password>\${xmlEscape(env.NEXUS_PASSWORD)}</password></server></servers></settings>"""
          }
          withEnv(["JAVA_HOME=\${env.JAVA8_HOME}","PATH+JAVA8=\${env.JAVA8_HOME}/bin"]) {
            sh 'mvn -B -s .mvn-settings.xml -DskipTests clean package'
            sh 'test -f target/WebGoat-6.0.1-war-exec.jar'
            sh '''mvn -B -s .mvn-settings.xml org.apache.maven.plugins:maven-deploy-plugin:3.1.3:deploy-file -Dfile=target/WebGoat-6.0.1-war-exec.jar -DgroupId=org.owasp.webgoat -DartifactId=webgoat-legacy -Dversion=6.0.1-$BUILD_NUMBER -Dpackaging=jar -DrepositoryId=nexus-hosted -Durl="$NEXUS_MAVEN_REPOSITORY_URL"'''
          }
        }
      }
    }
    stage('Build and publish Docker image') {
      steps {
        sh 'docker build -t $IMAGE_NAME:$BUILD_NUMBER .'
        withCredentials([usernamePassword(credentialsId:params.NEXUS_CREDENTIALS_ID,usernameVariable:'NEXUS_USER',passwordVariable:'NEXUS_PASSWORD')]) {
          sh '''set +x; printf '%s' "$NEXUS_PASSWORD" | docker login "$NEXUS_DOCKER_REGISTRY" -u "$NEXUS_USER" --password-stdin; docker tag "$IMAGE_NAME:$BUILD_NUMBER" "$NEXUS_DOCKER_REGISTRY/$IMAGE_NAME:$BUILD_NUMBER"; docker push "$NEXUS_DOCKER_REGISTRY/$IMAGE_NAME:$BUILD_NUMBER"; docker logout "$NEXUS_DOCKER_REGISTRY"'''
        }
      }
    }
    stage('Deploy locally') {
      steps {
        sh '''case "$WEBGOAT_HOST_PORT" in ''|*[!0-9]*) exit 2 ;; esac; docker rm -f "$APP_CONTAINER_NAME" 2>/dev/null || true; docker run -d --name "$APP_CONTAINER_NAME" --restart unless-stopped -p "127.0.0.1:$WEBGOAT_HOST_PORT:8080" "$IMAGE_NAME:$BUILD_NUMBER"'''
      }
    }
  }
  post { always { sh 'rm -f "$WORKSPACE/.mvn-settings.xml"'; archiveArtifacts artifacts:'target/*.war,target/*-war-exec.jar',fingerprint:true,allowEmptyArchive:true } }
}
