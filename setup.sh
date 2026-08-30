#!/system/bin/sh
# setup.sh —— AstrBot 安装（由 webui deploy 后台执行；输出到 deploy.log 实时供面板读取）
HERE=${0%/*}
. "$HERE/config.conf"
echo "！脚本执行过程大约需要10分钟，期间请勿退出本页面！"
echo "！脚本执行过程大约需要10分钟，期间请勿退出本页面！"
echo "！脚本执行过程大约需要10分钟，期间请勿退出本页面！"
LOG="$HERE/deploy.log"; : > "$LOG"
info(){ echo "• $1" | tee -a "$LOG"; }
echo "=== AstrBot 安装开始 $(date) ===" | tee -a "$LOG"
echo "模块目录: $HERE" | tee -a "$LOG"

# 定位 muntu 入口
M=/system/bin/mubuntu
[ -x "$M" ] || M=/data/adb/mubuntu/bin/mubuntu
[ -x "$M" ] || M=/data/adb/modules/mubuntu/system/bin/mubuntu
[ -x "$M" ] || { echo "! 未找到 muntu，请先刷官方 Mubuntu 并重启" | tee -a "$LOG"; exit 1; }
echo "muntu 入口: $M" | tee -a "$LOG"

# 提权，保持 root 连续执行
if [ "$(id -u)" != "0" ]; then
    exec su -c "sh '$0'"
fi

info "[1/4] 启动 muntu 守护（不挂载内部存储）"
"$M" autostart on 2>&1 | tee -a "$LOG"
"$M" daemon-start 2>&1 | tee -a "$LOG"
sleep 2

info "[2/4] 安装依赖 (python3/git/uv)"
"$M" run "sh -c 'export DEBIAN_FRONTEND=noninteractive; apt-get update -y; apt-get install -y python3 python3-pip python3-venv git curl ca-certificates; command -v uv >/dev/null 2>&1 || (curl -LsSf https://astral.sh/uv/install.sh | sh || true)'" 2>&1 | tee -a "$LOG"

info "[3/4] 克隆并安装 AstrBot (/opt/astrbot)"
"$M" run "sh -c 'export PATH=\$HOME/.local/bin:\$PATH; mkdir -p /opt; rm -rf /opt/astrbot; git clone --depth=1 https://github.com/AstrBotDevs/AstrBot /opt/astrbot; cd /opt/astrbot; if command -v uv >/dev/null 2>&1; then uv sync; else python3 -m venv .venv && .venv/bin/pip install -r requirements.txt -i https://mirrors.tuna.tsinghua.edu.cn/pypi/web/simple; fi'" 2>&1 | tee -a "$LOG"

info "[4/4] 后台启动 AstrBot 并写入 pid"
"$M" run "sh -c 'cd /opt/astrbot && export PATH=\$HOME/.local/bin:\$PATH; if command -v uv >/dev/null 2>&1; then nohup uv run --no-sync main.py > /var/log/astrbot.log 2>&1 & else nohup .venv/bin/python main.py > /var/log/astrbot.log 2>&1 & fi; echo \$! > /var/run/astrbot.pid; sleep 8; echo \"pid=\$(cat /var/run/astrbot.pid)\"'" 2>&1 | tee -a "$LOG"

# 抓初始密码/用户名 到容器内 cred 文件
# 抓取初始密码：最多重试 3 次（每次等 10 秒日志写入），3 次仍空才失败
"$M" run "sh -c 'i=0; while [ \$i -lt 3 ]; do sleep 10; grep -iE \"Initial password|Initial username\" /var/log/astrbot.log > /opt/astrbot/.astrbot_cred 2>/dev/null; [ -s /opt/astrbot/.astrbot_cred ] && break; i=\$((i+1)); done; if [ -s /opt/astrbot/.astrbot_cred ]; then echo \"[密码抓取成功]\"; else echo \"[密码抓取失败(已重试3次)]\"; fi; cat /opt/astrbot/.astrbot_cred 2>/dev/null'" 2>&1 | tee -a "$LOG"
touch "$HERE/.astrbot_deployed"

echo "" | tee -a "$LOG"
echo "✔ 部署完成" | tee -a "$LOG"
if [ -s "$MUBUNTU_RFS/opt/astrbot/.astrbot_cred" ]; then
    echo "🎉 初始登录信息：" | tee -a "$LOG"
    cat "$MUBUNTU_RFS/opt/astrbot/.astrbot_cred" | tee -a "$LOG"
else
    echo "（未抓到初始密码——请打开 127.0.0.1:6185 面板，或查看容器 /var/log/astrbot.log）" | tee -a "$LOG"
fi

# 更新 module.prop 安装状态（✓ 已安装）
sh "$HERE/prop_update.sh" 2>/dev/null
echo "已更新安装状态标记。" | tee -a "$LOG"
