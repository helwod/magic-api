# 使用 Docker 运行 magic-api

magic-api 本身是一个接口快速开发框架（需以 `magic-api-spring-boot-starter` 嵌入 Spring Boot 应用）。
本目录在源码基础上新增了一个最小可运行宿主应用 `magic-api-app`，并配套 `Dockerfile` / `docker-compose.yml`，
使其可直接以容器方式启动，开箱即用访问 Web 配置界面。

## 目录说明
- `magic-api-app/`：最小 Spring Boot 宿主应用（仅依赖 starter），不在父工程 reactor 内，可独立构建。
- `Dockerfile`：多阶段构建，先在 `maven:3.9-eclipse-temurin-8` 中从源码 `mvn install` 框架模块并打包 app，再在 `eclipse-temurin:8-jre` 运行。
- `docker-compose.yml`：映射 9999 端口，并把接口脚本目录 `/data/magic-api` 持久化为卷。

## 构建镜像
```bash
docker build -t helwod/magic-api:2.2.2 .
```
> 构建阶段需要联网，从 Maven 仓库拉取 Spring Boot 等依赖。

## 运行（docker compose，推荐）
```bash
docker compose up -d
```
访问：http://localhost:9999/magic/web

## 运行（仅 docker）
```bash
docker run -d --name magic-api -p 9999:9999 -v magic-api-data:/data/magic-api helwod/magic-api:2.2.2
```

## 配置
编辑 `magic-api-app/src/main/resources/application.properties` 可调整：
- `server.port`：HTTP 端口（默认 9999）
- `magic-api.web`：Web 界面入口（默认 `/magic/web`）
- `magic-api.resource.location`：接口脚本存储路径（容器内 `/data/magic-api`，已挂载为卷）

## 说明
- 环境要求 **Java 8 + Spring Boot 2.4.5**：构建与运行阶段均使用 JDK/JRE 8。
- Dockerfile 只编译宿主应用 `magic-api-app`，框架依赖从 Maven Central 拉取已发布的 `magic-api-spring-boot-starter:2.2.2`，因此不会编译需要 JDK 17 的 `magic-api-servlet-jakarta` / `magic-api-plugin-springdoc` 模块（这正是之前全量 `mvn install` 报 `invalid target release: 17` 的原因）。
- 应用默认不依赖 JDBC 数据源即可启动（配置中已排除 `DataSourceAutoConfiguration`）。如需使用 SQL 接口，请添加 `spring-boot-starter-jdbc` + 数据库驱动，并在 Web UI 中在线配置数据源。
