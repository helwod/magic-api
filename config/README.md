# 外部配置覆盖目录 (./config)
此目录在 docker-compose.yml 中以 `./config:/app/config` 挂载进容器。
Spring Boot 会优先加载 `/app/config/application.yml`（或 `.properties`），
覆盖 jar 内置的默认配置，便于在不重新构建镜像的情况下做环境定制。

用法：
1. 复制本目录示例并去掉 `.example` 后缀：
   `cp config/application.yml.example config/application.yml`
2. 编辑 `config/application.yml`。
3. `docker compose up -d` 生效。

示例 config/application.yml.example：
```yaml
magic-api:
  resource:
    type: database          # 改为数据库存储（需先配置数据源）
    datasource: default
  backup:
    enable: true            # 开启备份，防脚本丢失
    max-history: 30
```
