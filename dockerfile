FROM openjdk:11.0.7
ADD target/fastfood-0.0.1-SNAPSHOT.jar fastfood-0.0.1-SNAPSHOT.jar
EXPOSE 80
ENTRYPOINT ["java","-jar","fastfood-0.0.1-SNAPSHOT.jar"]
