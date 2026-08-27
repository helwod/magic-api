# syntax=docker/dockerfile:1

# ---------- Build stage ----------
# JDK 17 required: magic-api-servlet-jakarta & magic-api-plugin-springdoc modules target Java 17
FROM maven:3.9-eclipse-temurin-17 AS build
WORKDIR /workspace

# Build the framework modules from source and install them into the local Maven repo
COPY . .
RUN mvn -B -DskipTests install

# Build the runnable Spring Boot host app (depends on the starter above)
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
