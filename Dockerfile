# Example of custom Java runtime using jlink in a multi-stage container build
FROM eclipse-temurin:17 as jre-build

# Create a custom Java runtime
RUN $JAVA_HOME/bin/jlink \
         --add-modules ALL-MODULE-PATH \
         --strip-debug \
         --no-man-pages \
         --no-header-files \
         --compress=2 \
         --output /javaruntime

FROM ubuntu:22.04

#Prepare RocksDB state directory
RUN mkdir -p /spring/state

ENV JAVA_HOME=/opt/java/openjdk
ENV PATH "${JAVA_HOME}/bin:${PATH}"
COPY --from=jre-build /javaruntime $JAVA_HOME

RUN  apt-get update \
  && apt-get install -y wget \
  && rm -rf /var/lib/apt/lists/*

## Get Splunk Open Telemetry javaagent for application tracing (remember to check for latest version)
RUN wget https://github.com/signalfx/splunk-otel-java/releases/download/v1.6.0/splunk-otel-javaagent-all.jar

# Run as non-root user to mitigate security risks
RUN addgroup --system --gid 10001 spring && adduser --system --uid 10001 --group spring
USER spring:spring

ARG JAR_FILE=target/*.jar
COPY ${JAR_FILE} app.jar

ENTRYPOINT ["java", "-javaagent:splunk-otel-javaagent-all.jar", "-jar", "/app.jar"]

EXPOSE 8080