#!/system/bin/sh
# service.sh —— late_start：开机唤起 muntu 守护 + 已部署则自启 AstrBot
HERE=${0%/*}
. "$HERE/config.conf"

if [ "$(id -u)" != "0" ]; then
    exec su -c "sh '$0'"
fi
[ "$AUTO_START" = "true" ] || exit 0

# 定位 muntu
M=/system/bin/mubuntu
[ -x "$M" ] || M=/data/adb/mubuntu/bin/mubuntu
[ -x "$M" ] || M=/data/adb/modules/mubuntu/system/bin/mubuntu
[ -x "$M" ] || exit 0

LOG="$HERE/service.log"
echo "== service $(date) ==" >> "$LOG"

# 0) 刷新 module.prop 安装状态（✓/×）
sh "$HERE/prop_update.sh" >/dev/null 2>&1 || true

# 1) 唤起 muntu 守护（保容器 + 开机自启开关）
"$M" daemon-start >> "$LOG" 2>&1 || true
"$M" autostart on >> "$LOG" 2>&1 || true
sleep 4

# 2) 已部署 AstrBot 则启动
if [ -f "$HERE/.astrbot_deployed" ]; then
    sh "$HERE/action.sh" start >> "$LOG" 2>&1
fi
