pipeline {
    triggers {
  pollSCM('* * * * *')
    }
   agent any
    tools {
  maven 'M2_HOME'
  }

   environment {
        NEXUS_VERSION = "nexus3"
        NEXUS_PROTOCOL = "http"
        NEXUS_URL = "139.177.192.139:8081"
        NEXUS_REPOSITORY = "utrains-nexus-pipeline"
        NEXUS_CREDENTIAL_ID = "nexus-user-credentials"

        imageName = "fastfood"
        registryCredentials = "nexus-user-credentials"
        registry = "139.177.192.139:8085/repository/utrains-nexus-registry/"
        dockerImage = ''
    }

    stages {

        stage("build & SonarQube analysis") {          
            steps {
                dir('./fastfood_BackEnd/'){
                    withSonarQubeEnv('SonarServer') {
                        sh 'mvn verify org.sonarsource.scanner.maven:sonar-maven-plugin:sonar -Dsonar.projectKey=Hermann90_fastfoodtest'
                    }
                }
            }
        }

        stage('Check Quality Gate') {
            steps {
                echo 'Checking quality gate...'
                dir('./fastfood_BackEnd/'){ 
                    script {
                    timeout(time: 20, unit: 'MINUTES') {
                        def qg = waitForQualityGate()
                        if (qg.status != 'OK') {
                            error "Pipeline stopped because of quality gate status: ${qg.status}"
                            } 
                        }
                    }
                }
            }
        }

         stage("Maven Build Back-End") {
            steps {
                echo 'Build Back-End Project...'
                dir('./fastfood_BackEnd/'){
                    script {
                    sh "mvn package -DskipTests=true"
                    }
                }
            }
        }

         stage("Publish to Nexus Repository Manager") {
            steps {
                echo 'Publish to Nexus Repository Manager...'
                dir('./fastfood_BackEnd/'){
                    script {
                    pom = readMavenPom file: "pom.xml";
                    filesByGlob = findFiles(glob: "target/*.${pom.packaging}");
                    echo "${filesByGlob[0].name} ${filesByGlob[0].path} ${filesByGlob[0].directory} ${filesByGlob[0].length} ${filesByGlob[0].lastModified}"
                    artifactPath = filesByGlob[0].path;
                    artifactExists = fileExists artifactPath;
                    if(artifactExists) {
                        echo "*** File: ${artifactPath}, group: ${pom.groupId}, packaging: ${pom.packaging}, version ${pom.version}";
                        nexusArtifactUploader(
                            nexusVersion: NEXUS_VERSION,
                            protocol: NEXUS_PROTOCOL,
                            nexusUrl: NEXUS_URL,
                            groupId: pom.groupId,
                            version: pom.version,
                            repository: NEXUS_REPOSITORY,
                            credentialsId: NEXUS_CREDENTIAL_ID,
                            artifacts: [
                                [artifactId: pom.artifactId,
                                classifier: '',
                                file: artifactPath,
                                type: pom.packaging],
                                [artifactId: pom.artifactId,
                                classifier: '',
                                file: "pom.xml",
                                type: "pom"]
                            ]
                        );
                        } else {
                        error "*** File: ${artifactPath}, could not be found";
                        }
                    }
                }
            }
        }
        
        // Building Docker images
        stage("Build Docker Image"){
            steps{
                echo 'Build Docker Image'
                dir('./fastfood_BackEnd/'){
                    script{
                        dockerImage = docker.build imageName
                    }
                }
            }
        }

        // Push Docker images to Nexus Registry
        stage("Uploading to Nexus Registry"){
            steps{
                echo 'Uploading Docker image to Nexus ...'
                dir('./fastfood_BackEnd/'){
                    script{
                        docker.withRegistry( 'http://'+registry, registryCredentials ) {
                        dockerImage.push('latest')
                        }
                    }
                }
            }
        }   
    }
}
