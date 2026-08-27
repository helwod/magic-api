# syntax=docker/dockerfile:1

# ---------- Build stage ----------
# Java 8 + Spring Boot 2.4.5. Only the host app is compiled here; the framework is
# pulled from the published magic-api-spring-boot-starter on Maven Central, so the
# Jakarta modules (which require JDK 17) are never compiled.
FROM maven:3.9-eclipse-temurin-8 AS build
WORKDIR /workspace

# Build the runnable Spring Boot host app (pulls magic-api-spring-boot-starter:2.2.2 from Central)
COPY magic-api-app ./magic-api-app
RUN cd magic-api-app && mvn -B -DskipTests package

# ---------- Runtime stage ----------
FROM eclipse-temurin:8-jre
WORKDIR /app

# Persisted interface scripts live here (mounted as a volume)
RUN mkdir -p /data/magic-api

COPY --from=build /workspace/magic-api-app/target/app.jar /app/app.jar

EXPOSE 9999
VOLUME ["/data/magic-api"]
ENTRYPOINT ["java", "-jar", "/app/app.jar"]
