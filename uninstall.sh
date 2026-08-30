#!/bin/sh
# uninstall.sh —— 清理 mubuntu 容器内的 AstrBot（mubuntu 环境保留）
HERE=${0%/*}
. "$HERE/config.conf"
if [ -d "$MUBUNTU_RFS/opt/astrbot" ]; then
    [ -x "$MUBUNTU" ] && "$MUBUNTU" run "sh -c '/opt/astrbot/stop.sh 2>/dev/null'" 2>/dev/null
    rm -rf "$MUBUNTU_RFS/opt/astrbot"
    echo "已删除 mubuntu 容器内的 AstrBot"
fi
echo "mubuntu 环境保持不变。"
