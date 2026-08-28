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

# 默认时区（可被 .env 中的 TZ 覆盖）
ENV TZ=Asia/Shanghai

# 持久化接口脚本目录（挂载为卷）+ 外部配置覆盖目录（挂载 ./config 后可覆盖 jar 内配置）
RUN mkdir -p /data/magic-api /app/config

COPY --from=build /workspace/magic-api-app/target/app.jar /app/app.jar

EXPOSE 9999
VOLUME ["/data/magic-api"]
# Spring Boot 会优先读取 /app/config 下的 application.yml，实现容器外配置注入
ENTRYPOINT ["java", "-jar", "/app/app.jar"]
