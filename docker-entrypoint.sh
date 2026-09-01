#!/bin/sh
# docker-entrypoint.sh —— magic-api 启动前的数据目录初始化
# 目标：
#  1) 数据目录路径跟随 MAGIC_API_RESOURCE_LOCATION（.env 注入），实现「变量路径」；
#  2) 数据目录由持久卷（命名卷/绑定挂载）承载，UI 内改动落盘、重启不丢（长久保存）；
#  3) 首次启动时若目录为空，从镜像内固定种子 /opt/magic-api-seed 灌入示例数据；
#     目录非空则保留现有数据（不覆盖用户改动）。
set -e

# 数据目录：优先取 .env 的 MAGIC_API_RESOURCE_LOCATION，兜底 /data/magic-api
DATA_DIR="${MAGIC_API_RESOURCE_LOCATION:-/data/magic-api}"
mkdir -p "$DATA_DIR"

SEED_DIR="/opt/magic-api-seed"

if [ -z "$(ls -A "$DATA_DIR" 2>/dev/null)" ]; then
  if [ -d "$SEED_DIR" ] && [ -n "$(ls -A "$SEED_DIR" 2>/dev/null)" ]; then
    echo "[init] $DATA_DIR 为空，灌入示例数据（来自 $SEED_DIR）..."
    # 保留原目录权限，复制种子内容（含中文名 .ms / group.json / datasource/*）
    cp -r "$SEED_DIR/." "$DATA_DIR"/
    echo "[init] 示例数据已写入 $DATA_DIR"
  else
    echo "[init] 警告：$SEED_DIR 不存在或为空，跳过灌入；magic-api 将以空数据启动"
  fi
else
  echo "[init] $DATA_DIR 已有数据，跳过灌入（保留现有数据，含 UI 改动）"
fi

# 启动 magic-api
exec java -jar /app/app.jar
