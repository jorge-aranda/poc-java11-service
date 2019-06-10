
# Gradle Build
FROM openjdk:11-jdk-stretch as builder
RUN useradd -u 1234 gradle

COPY --chown=gradle:gradle . /home/gradle/poc-java11-service
WORKDIR /home/gradle/poc-java11-service
RUN ./gradlew build

# Run application
FROM openjdk:11-stretch

RUN useradd -u 1234 app

EXPOSE 8080
EXPOSE 9090
COPY --from=builder --chown=app:app /home/gradle/poc-java11-service/build/libs/poc-java11-service-0.1.0-SNAPSHOT.jar /home/app/
WORKDIR /home/app

USER app
CMD java $ARGS -XX:+PrintFlagsFinal -Dspring.profiles.active=from-docker \
         -Dcom.sun.management.jmxremote.rmi.port=9090 \
         -Dcom.sun.management.jmxremote=true \
         -Dcom.sun.management.jmxremote.port=9090 \
         -Dcom.sun.management.jmxremote.ssl=false \
         -Dcom.sun.management.jmxremote.authenticate=false \
         -Dcom.sun.management.jmxremote.local.only=false \
         -Djava.rmi.server.hostname=localhost \
         -jar poc-java11-service-0.1.0-SNAPSHOT.jar
