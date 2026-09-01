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

# 接口脚本目录与外置配置目录：
#  - 数据包在【构建时直接 COPY 进镜像】，路径由 build arg RESOURCE_DIR 决定（默认 /data/magic-api），
#    其值 = docker-compose 传入的 .env MAGIC_API_RESOURCE_LOCATION，确保「改 .env 路径，数据就烤进对应目录」。
#  - /app/config 仍由 docker-compose 绑定挂载，用于注入 application.yml 覆盖（优先级高于 jar 内配置）。
# 注意：compose 中【不要】再把命名卷/绑定挂载盖到 RESOURCE_DIR 上，否则会屏蔽镜像内已 COPY 的数据导致为空。
#  若需运行时持久化（UI 改动落盘宿主机），改为在 compose 中对 RESOURCE_DIR 启用【绑定挂载】（非命名卷），
# 并删除下方 COPY data/magic-api 这一行。
ARG RESOURCE_DIR=/data/magic-api
RUN mkdir -p ${RESOURCE_DIR} /app/config

# 将数据包 COPY 进镜像（构建上下文包含 data/magic-api，.dockerignore 未忽略该目录）
COPY data/magic-api ${RESOURCE_DIR}

COPY --from=build /workspace/magic-api-app/target/app.jar /app/app.jar

EXPOSE 9999
# Spring Boot 会优先读取 /app/config 下的 application.yml，实现容器外配置注入
ENTRYPOINT ["java", "-jar", "/app/app.jar"]
