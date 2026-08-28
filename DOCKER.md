# 使用 Docker 运行 magic-api

magic-api 本身是一个接口快速开发框架（需以 `magic-api-spring-boot-starter` 嵌入 Spring Boot 应用）。
本目录在源码基础上新增了一个最小可运行宿主应用 `magic-api-app`，并配套 `Dockerfile` / `docker-compose.yml`，
使其可直接以容器方式启动，开箱即用访问 Web 配置界面。

## 目录说明
- `magic-api-app/`：最小 Spring Boot 宿主应用（仅依赖 starter），不在父工程 reactor 内，可独立构建。
- `Dockerfile`：多阶段构建，在 `maven:3.9-eclipse-temurin-8` 中仅构建宿主应用 `magic-api-app`（框架从 Maven Central 拉取已发布的 starter），再在 `eclipse-temurin:8-jre` 中运行；运行时挂载 `/app/config` 支持外部配置覆盖。
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

## 配置（env 文件映射）
配置采用「`application.yml` + `.env`」两层：
- `magic-api-app/src/main/resources/application.yml`：内置默认配置，所有可配置项均用
  `${ENV:默认值}` 占位符暴露，并带中文注释。
- 根目录 `.env`：运行环境实际取值（端口、存储路径、后台账号等），由
  `docker-compose.yml` 的 `env_file: .env` 注入容器。Spring Boot 宽松绑定(relaxed
  binding)把环境变量映射为配置项，例如：

  | .env 变量 | 映射到配置项 |
  |---|---|
  | `SERVER_PORT` | `server.port` |
  | `MAGIC_API_WEB` | `magic-api.web` |
  | `MAGIC_API_RESOURCE_LOCATION` | `magic-api.resource.location` |
  | `MAGIC_API_SECURITY_USERNAME` / `MAGIC_API_SECURITY_PASSWORD` | `magic-api.security.username` / `.password` |
  | `MAGIC_API_RESOURCE_TYPE` | `magic-api.resource.type`（`file` / `database`） |
  | 其余 `MAGIC_API_*` | 依次类推（点号转下划线、全小写） |

修改 `.env` 后执行 `docker compose up -d` 即生效，无需重新构建镜像。

### 常见可调整项
- `SERVER_PORT` / `HOST_PORT`：容器内 / 宿主机端口（默认均 9999）
- `MAGIC_API_WEB`：Web 界面入口（默认 `/magic/web`）
- `MAGIC_API_RESOURCE_LOCATION`：接口脚本存储路径（容器内 `/data/magic-api`，已挂载为卷）
- `MAGIC_API_RESOURCE_TYPE`：`file`（默认，配卷持久化）/ `database`（入库，需配置数据源）
- `MAGIC_API_SECURITY_*`：后台 / 编辑器登录账号（生产务必改强密码）

### 外部配置覆盖（可选）
把覆盖配置放到仓库 `config/application.yml`（参考 `config/application.yml.example`），
docker-compose 已将其挂载为 `/app/config`，优先级高于 jar 内置 `application.yml`，
适合在不重新构建镜像时做环境定制。

> 安全提示：`.env` 中后台口令为明文，生产环境请改为强密码，避免提交真实口令到公开仓库。

## 说明
- 环境要求 **Java 8 + Spring Boot 2.4.5**：构建与运行阶段均使用 JDK/JRE 8。
- Dockerfile 只编译宿主应用 `magic-api-app`，框架依赖从 Maven Central 拉取已发布的 `magic-api-spring-boot-starter:2.2.2`，因此不会编译需要 JDK 17 的 `magic-api-servlet-jakarta` / `magic-api-plugin-springdoc` 模块（这正是之前全量 `mvn install` 报 `invalid target release: 17` 的原因）。
- 应用默认不依赖 JDBC 数据源即可启动（配置中已排除 `DataSourceAutoConfiguration`）。如需使用 SQL 接口，请添加 `spring-boot-starter-jdbc` + 数据库驱动，并在 Web UI 中在线配置数据源。
