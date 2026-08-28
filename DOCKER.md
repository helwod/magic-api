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

## 数据库配置（接口脚本 / 备份入库存储）
默认 `magic-api.resource.type=file`，接口脚本存于挂载卷 `/data/magic-api`，无需数据库即可运行。
若希望把接口脚本与备份写入数据库（便于多实例共享、集中备份），按以下步骤：

1. **提供 JDBC 连接**：在 `.env` 中填写
   - `SPRING_DATASOURCE_URL`（如 `jdbc:mysql://mysql:3306/magic_api?...`）
   - `SPRING_DATASOURCE_USERNAME` / `SPRING_DATASOURCE_PASSWORD`
   - `SPRING_DATASOURCE_DRIVER_CLASS_NAME`（`com.mysql.cj.jdbc.Driver` 或 `org.postgresql.Driver`）
   - 并把 `DATASOURCE_EXCLUDE` **置空**（启用 DataSource 自动配置，建立主数据源）
2. **切换存储类型**：`MAGIC_API_RESOURCE_TYPE=database`，并把
   `MAGIC_API_RESOURCE_DATASOURCE`、`MAGIC_API_BACKUP_DATASOURCE` 设为同一个**具名数据源**名称（如 `default`）。
3. **在 Web UI 注册具名数据源**：启动后进入 `/magic/web` →「数据源」→ 新增，名称填 `default`，
   连接信息与上面 JDBC 一致。magic-api 会持久化该数据源；之后 `resource.datasource=default` 即可解析。
   > 说明：magic-api 没有「配置即注册」的命名数据源，`resource.datasource` 必须指向 Web UI 中建立的具名数据源。
   > 主 `spring.datasource` 仅作为 db 模块 / SQL 接口的默认连接，不直接用于脚本存储解析。

| .env 变量 | 映射到配置项 | 说明 |
|---|---|---|
| `SPRING_DATASOURCE_URL` | `spring.datasource.url` | JDBC 连接串 |
| `SPRING_DATASOURCE_USERNAME` | `spring.datasource.username` | 数据库账号 |
| `SPRING_DATASOURCE_PASSWORD` | `spring.datasource.password` | 数据库口令 |
| `SPRING_DATASOURCE_DRIVER_CLASS_NAME` | `spring.datasource.driver-class-name` | JDBC 驱动类 |
| `DATASOURCE_EXCLUDE` | `spring.autoconfigure.exclude` | 留空=启用主数据源；填类名=排除（file 模式） |
| `MAGIC_API_RESOURCE_TYPE` | `magic-api.resource.type` | `file` / `database` |
| `MAGIC_API_RESOURCE_DATASOURCE` | `magic-api.resource.datasource` | database 模式引用的具名数据源 |
| `MAGIC_API_BACKUP_DATASOURCE` | `magic-api.backup.datasource` | 备份引用的具名数据源 |

**完整示例**（含 MySQL / PostgreSQL）：
- `config/database-mysql.yml.example`
- `config/database-postgres.yml.example`

**随容器启动数据库**：`docker-compose.yml` 末尾附了一段注释掉的 `mysql` 服务，取消注释并在
`magic-api` 服务下打开 `depends_on: [mysql]` 即可一键拉起「magic-api + MySQL」。

## 说明
- 环境要求 **Java 8 + Spring Boot 2.4.5**：构建与运行阶段均使用 JDK/JRE 8。
- Dockerfile 只编译宿主应用 `magic-api-app`，框架依赖从 Maven Central 拉取已发布的 `magic-api-spring-boot-starter:2.2.2`，因此不会编译需要 JDK 17 的 `magic-api-servlet-jakarta` / `magic-api-plugin-springdoc` 模块（这正是之前全量 `mvn install` 报 `invalid target release: 17` 的原因）。
- 应用默认不依赖 JDBC 数据源即可启动（`DATASOURCE_EXCLUDE` 默认排除 `DataSourceAutoConfiguration`）。`magic-api-app` 已内置 MySQL(`mysql-connector-java`)、PostgreSQL(`postgresql`) 驱动，配置 `spring.datasource.*` 并清空 `DATASOURCE_EXCLUDE` 即可连库；SQL 接口用的具名数据源在 Web UI 中配置。
