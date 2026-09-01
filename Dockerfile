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

# 接口脚本目录：
#  - 示例/种子数据包在构建时烤进镜像【固定目录 /opt/magic-api-seed】（不参与路径变量、运行时不被挂载覆盖）。
#  - 运行时数据目录 = MAGIC_API_RESOURCE_LOCATION（由 .env 注入），由 docker-compose 以持久卷
#    （命名卷或绑定挂载）承载，实现「变量路径 + 长久保存」；入口脚本 docker-entrypoint.sh 在目录为空时
#    把 /opt/magic-api-seed 灌入该目录（首次带示例数据，之后保留用户改动）。
#  - /app/config 仍由 docker-compose 绑定挂载，用于注入 application.yml 覆盖（优先级高于 jar 内配置）。
COPY data/magic-api /opt/magic-api-seed

# 入口初始化脚本：空目录灌种子、非空保留，再启动 java
COPY docker-entrypoint.sh /app/docker-entrypoint.sh
# 防御 Windows CRLF：确保脚本为 LF 且可执行
RUN sed -i 's/\r$//' /app/docker-entrypoint.sh 2>/dev/null || true \
 && chmod +x /app/docker-entrypoint.sh

RUN mkdir -p /app/config

COPY --from=build /workspace/magic-api-app/target/app.jar /app/app.jar

EXPOSE 9999
# Spring Boot 会优先读取 /app/config 下的 application.yml，实现容器外配置注入；
# 数据目录初始化与启动交由入口脚本完成。
ENTRYPOINT ["/app/docker-entrypoint.sh"]
