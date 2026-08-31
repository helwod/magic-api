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
#  - /data/magic-api 的数据包在【构建时直接 COPY 进镜像】，不依赖运行时绑定挂载，
#    规避 Windows Docker Desktop File Sharing 未开启导致挂载为空的问题；build 完成后容器内即含
#    api/ function/ datasource/ 等数据，无需再挂宿主机目录。
#  - /app/config 仍由 docker-compose 绑定挂载，用于注入 application.yml 覆盖（优先级高于 jar 内配置）。
# 如需运行时持久化（UI 内新增/修改落盘到宿主机），改为在 compose 中对 /data/magic-api 启用绑定挂载，
# 并删除下方 COPY data/magic-api 这一行（注意：绑定挂载会覆盖镜像内已 COPY 的数据）。
RUN mkdir -p /data/magic-api /app/config

# 将数据包 COPY 进镜像（构建上下文包含 data/magic-api，.dockerignore 未忽略该目录）
COPY data/magic-api /data/magic-api

COPY --from=build /workspace/magic-api-app/target/app.jar /app/app.jar

EXPOSE 9999
# Spring Boot 会优先读取 /app/config 下的 application.yml，实现容器外配置注入
ENTRYPOINT ["java", "-jar", "/app/app.jar"]
