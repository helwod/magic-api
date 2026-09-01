<p align="center">
    <img src="https://www.ssssssss.org/images/logo-magic-api.png" width="256">
</p>
<p align="center">
    <a target="_blank" href="https://www.oracle.com/technetwork/java/javase/downloads/index.html"><img src="https://img.shields.io/badge/JDK-1.8+-green.svg" /></a>
    <a href="https://search.maven.org/search?q=g:org.ssssssss%20AND%20a:magic-api">
        <img alt="maven" src="https://img.shields.io/maven-central/v/org.ssssssss/magic-api.svg?style=flat-square">
    </a>
    <a target="_blank" href="https://www.ssssssss.org"><img src="https://img.shields.io/badge/Docs-latest-blue.svg"/></a>
    <a target="_blank" href="https://github.com/ssssssss-team/magic-api/releases"><img src="https://img.shields.io/github/v/tag/ssssssss-team/magic-api?logo=github&label=release"></a>
    <a target="_blank" href="https://gitee.com/ssssssss-team/magic-api"><img src="https://gitee.com/ssssssss-team/magic-api/badge/star.svg?theme=white" /></a>
    <a target="_blank" href="https://github.com/ssssssss-team/magic-api"><img src="https://img.shields.io/github/stars/ssssssss-team/magic-api.svg?style=social"/></a>
    <a target="_blank" href="LICENSE"><img src="https://img.shields.io/:license-MIT-blue.svg"></a>
</p>

[特性](#特性) | [快速开始](#快速开始) | [文档/演示](#文档演示) | [示例项目](#示例项目) | <a target="_blank" href="http://ssssssss.org/changelog.html">更新日志</a> | [项目截图](#项目截图) | [交流群](#交流群)

# 简介

magic-api 是一个基于Java的接口快速开发框架，编写接口将通过magic-api提供的UI界面完成，自动映射为HTTP接口，无需定义Controller、Service、Dao、Mapper、XML、VO等Java对象即可完成常见的HTTP API接口开发


【已有上千家中小型公司使用，上万名开发者用于接口配置开发。上百名开发者参与提交了功能建议，接近20多名贡献者参与。已被gitee长期推荐。从首个版本开始不断优化升级，目前版本稳定，开发者交流群活跃。参与交流QQ群④700818216】

# 特性
- 支持MySQL、MariaDB、Oracle、DB2、PostgreSQL、SQLServer 等支持jdbc规范的数据库
- 支持非关系型数据库Redis、Mongodb
- 支持集群部署、接口自动同步。
- 支持分页查询以及自定义分页查询
- 支持多数据源配置，支持在线配置数据源
- 支持SQL缓存，以及自定义SQL缓存
- 支持自定义JSON结果、自定义分页结果
- 支持对接口权限配置、拦截器等功能
- 支持运行时动态修改数据源
- 支持Swagger接口文档生成
- 基于[magic-script](https://gitee.com/ssssssss-team/magic-script)脚本引擎，动态编译，无需重启，实时发布
- 支持Linq式查询，关联、转换更简单
- 支持数据库事务、SQL支持拼接，占位符，判断等语法
- 支持文件上传、下载、输出图片
- 支持脚本历史版本对比与恢复
- 支持脚本代码自动提示、参数提示、悬浮提示、错误提示
- 支持导入Spring中的Bean、Java中的类
- 支持在线调试
- 支持自定义工具类、自定义模块包、自定义类型扩展、自定义方言、自定义列名转换等自定义操作

# 快速开始

## maven引入
```xml
<!-- 以spring-boot-starter的方式引用 -->
<dependency>
	<groupId>org.ssssssss</groupId>
    <artifactId>magic-api-spring-boot-starter</artifactId>
    <version>2.2.2</version>
</dependency>
```
## 修改application.properties

```properties
server.port=9999
#配置web页面入口
magic-api.web=/magic/web
#配置文件存储位置。当以classpath开头时，为只读模式
magic-api.resource.location=/data/magic-api
```

## 在线编辑
访问`http://localhost:9999/magic/web`进行操作

# Docker 部署

本项目提供开箱即用的 Docker / docker compose 部署方案，支持接口脚本持久化、首启动自动灌入示例数据、以及通过 `.env` 配置变量路径。

## 目录结构
- `docker-compose.yml`：编排 magic-api 与可选 MySQL 服务
- `Dockerfile`：基于 `eclipse-temurin:8-jre` 构建运行镜像
- `docker-entrypoint.sh`：容器启动时初始化数据（空目录灌种子、非空保留）
- `.env`：所有可配置项（端口、资源路径、数据源等）
- `config/application.yml`：外部配置覆盖（优先级高于 jar 内配置）

## 快速开始
```bash
# 构建并启动（首次启动自动灌入示例数据）
docker compose build
docker compose up -d

# 访问 Web 控制台
http://localhost:9999/magic/web
```

## 核心特性
- **变量路径**：接口数据目录由 `.env` 的 `MAGIC_API_RESOURCE_LOCATION` 控制（默认 `/data/magic-api`）。改路径只需 `docker compose up -d`，无需重建镜像（入口脚本在运行时读取该变量）。
- **长久保存**：数据写入命名卷 `magic-api-data`，UI 内新增/修改的接口在重启、升级镜像后均不丢失。
- **初始化示例**：首次启动（或卷为空）时，入口脚本自动从镜像内置种子 `/opt/magic-api-seed` 灌入 `api/ function/ datasource/` 等示例数据；卷内已有数据则保留、绝不覆盖。
- **外部配置**：`config/application.yml` 挂载到 `/app/config`，可强制覆盖 `magic-api.resource.location` 等项。
- **中文路径**：运行时镜像已设 `LANG=C.UTF-8`，容器内中文文件名不乱码。

## 常用变量（.env）
| 变量 | 默认值 | 说明 |
| --- | --- | --- |
| `SERVER_PORT` | 9999 | 容器对外端口 |
| `MAGIC_API_RESOURCE_TYPE` | file | 接口存储类型，file=文件，database=数据库 |
| `MAGIC_API_RESOURCE_LOCATION` | /data/magic-api | 接口数据目录（变量路径） |
| `MAGIC_API_WEB` | /magic/web | Web 入口路径 |
| `MYSQL_ROOT_PASSWORD` | root123 | MySQL root 口令（启用 MySQL 时） |

## 切换到 MySQL 存储
1. 编辑 `.env`：`MAGIC_API_RESOURCE_TYPE=database`，并填写 `SPRING_DATASOURCE_URL` 等连接项；
2. 移除 `DATASOURCE_EXCLUDE` 中的 `mysql`；
3. `docker compose up -d`。

## 重置示例数据
清空数据卷后重新启动即可重新灌入：
```bash
docker compose down -v
docker compose up -d
```

## 注意事项
- 数据在命名卷中，不依赖宿主机目录，无需配置 Docker Desktop File Sharing。
- 若需将数据落宿主机，将 compose 中 `magic-api-data:...` 一行改为绑定挂载 `${MAGIC_API_DATA_DIR:-./data/magic-api}:...`。
- 改 `MAGIC_API_RESOURCE_LOCATION` 后只需 `docker compose up -d`；若改了需要重新烤进镜像的内容（如种子数据包），则需 `docker compose build`。

# 文档/演示

- 文档地址：[https://ssssssss.org](https://ssssssss.org)
- 在线演示：[https://magic-api.ssssssss.org.cn](https://magic-api.ssssssss.org.cn)

# 示例项目

- [magic-api-example](https://gitee.com/ssssssss-team/magic-api-example)

# 项目截图
| ![整体截图](https://images.gitee.com/uploads/images/2021/0711/105714_c1cacf2c_297689.png "整体截图") | ![代码提示](https://images.gitee.com/uploads/images/2021/0711/110448_11b6626b_297689.gif "代码提示") |
|---|---|
| ![DEBUG](https://images.gitee.com/uploads/images/2021/0711/110515_755f178a_297689.gif "DEBUG") | ![参数提示](https://images.gitee.com/uploads/images/2021/0711/110322_9dd6d149_297689.gif "参数提示") |
| ![远程推送](https://images.gitee.com/uploads/images/2021/0711/105803_b53e0d7e_297689.png "远程推送") | ![历史记录](https://images.gitee.com/uploads/images/2021/0711/105910_f2440ea4_297689.png "历史记录") |
| ![数据源](https://images.gitee.com/uploads/images/2021/0711/105846_7ec51a50_297689.png "数据源") | ![全局搜索](https://images.gitee.com/uploads/images/2021/0711/105823_ac18ada7_297689.png "全局搜索") |

# 交流群

| 微信群 | QQ群 |
| ----- | --- |
| <img src="https://www.ssssssss.org/magic-api/images/wxcode.png" alt="作者微信"> | <img src="https://www.ssssssss.org/magic-api/images/qq-group-qrcode.png" alt="QQ群"> |
| 备注：加群，邀您加入群聊| <a href="https://qm.qq.com/cgi-bin/qm/qr?k=38qddUeqrk_x29Xril9a_jxnoCGTmPRF&jump_from=webapi" target="_blank">点击加入QQ群：700818216</a> |

