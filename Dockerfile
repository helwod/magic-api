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

# 中文支持：eclipse-temurin 基础镜像默认 locale 为 POSIX/C，Java 8 的 file.encoding /
# sun.jnu.encoding 会退化为 ASCII，导致容器内读取中文文件名（接口脚本、分组目录）乱码。
# 设 LANG=C.UTF-8（glibc 内置、无需 locale-gen）使 JVM 以 UTF-8 解码文件名与内容；
# 再用 JAVA_TOOL_OPTIONS 强制 file.encoding=UTF-8 作为双保险。
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8
ENV JAVA_TOOL_OPTIONS="-Dfile.encoding=UTF-8"

# 接口脚本目录与外置配置目录：运行时由 docker-compose 绑定挂载（./data/magic-api -> /data/magic-api、
# ./config -> /app/config）。这里仅 mkdir 保证目录存在（无挂载时也不报错），不再用 VOLUME 声明——
# VOLUME 会让部分 docker-compose 版本在运行时改挂匿名卷、顶掉绑定挂载，导致目录变空。
RUN mkdir -p /data/magic-api /app/config

COPY --from=build /workspace/magic-api-app/target/app.jar /app/app.jar

EXPOSE 9999
# Spring Boot 会优先读取 /app/config 下的 application.yml，实现容器外配置注入
ENTRYPOINT ["java", "-jar", "/app/app.jar"]
