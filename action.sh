#!/system/bin/sh
# action.sh —— webui 动作入口
# 动作: deploy|start|stop|restart|status|update|deploylog|updatelog|cred|mstatus
HERE=${0%/*}
. "$HERE/config.conf"

ACTION="${1:-${ACTION:-run}}"
ACTION="${ACTION##*/}"

# 提权到 root（mubuntu need_root）
if [ "$(id -u)" != "0" ]; then
    exec su -c "sh '$0' '$ACTION'"
fi

# 定位 muntu
M=/system/bin/mubuntu
[ -x "$M" ] || M=/data/adb/mubuntu/bin/mubuntu
[ -x "$M" ] || M=/data/adb/modules/mubuntu/system/bin/mubuntu

run_in(){ [ -x "$M" ] && "$M" run "sh -c '$*'" || echo "mubuntu 不可用"; }

case "$ACTION" in
    run|deploy)
        # 同步执行安装脚本：KernelSU「执行」界面直接显示全部输出（含最终密码）
        # 日志同时落盘 deploy.log 供回溯
        sh "$HERE/setup.sh"
        ;;
    start)    run_in "/opt/astrbot/start.sh 2>/dev/null || (cd /opt/astrbot && export PATH=\$HOME/.local/bin:\$PATH; if command -v uv >/dev/null 2>&1; then nohup uv run --no-sync main.py > /var/log/astrbot.log 2>&1 & else nohup .venv/bin/python main.py > /var/log/astrbot.log 2>&1 & fi; echo \$! > /var/run/astrbot.pid)" ;;
    stop)     run_in "pkill -f /opt/astrbot/main.py 2>/dev/null; echo stopped" ;;
    restart)  run_in "pkill -f /opt/astrbot/main.py 2>/dev/null; sleep 1; cd /opt/astrbot && export PATH=\$HOME/.local/bin:\$PATH; if command -v uv >/dev/null 2>&1; then nohup uv run --no-sync main.py > /var/log/astrbot.log 2>&1 & else nohup .venv/bin/python main.py > /var/log/astrbot.log 2>&1 & fi; echo \$! > /var/run/astrbot.pid" ;;
    status)
        # 以容器内真实安装产物为准（而非仅模块标记，避免旧标记导致误判"已部署"）
        DEPLOYED=no
        if [ -f "$MUBUNTU_RFS/opt/astrbot/main.py" ] || [ -d "$MUBUNTU_RFS/opt/astrbot/.git" ]; then DEPLOYED=yes; fi
        if [ "$DEPLOYED" = "yes" ]; then touch "$HERE/.astrbot_deployed" 2>/dev/null; else rm -f "$HERE/.astrbot_deployed" 2>/dev/null; fi
        if [ "$DEPLOYED" = "yes" ]; then
            PID=$(cat "$MUBUNTU_RFS/var/run/astrbot.pid" 2>/dev/null)
            if [ -n "$PID" ] && [ -d "/proc/$PID" ]; then STATE=RUNNING; else STATE=STOPPED; fi
        else
            STATE=NOT_DEPLOYED; PID=""
        fi
        echo "STATE=$STATE"
        echo "PID=${PID:-}"
        if [ -f "$MUBUNTU_RFS/opt/astrbot/.astrbot_cred" ]; then echo "---CRED---"; cat "$MUBUNTU_RFS/opt/astrbot/.astrbot_cred"; fi
        ;;
    update)   nohup sh "$HERE/action.sh" update_run > "$HERE/update.log" 2>&1 & echo "update started" ;;
    update_run)
        run_in "cd /opt/astrbot 2>/dev/null && echo '== git pull ==' && git pull --ff-only && echo '== 更新依赖 ==' && export PATH=\$HOME/.local/bin:\$PATH && if command -v uv >/dev/null 2>&1; then uv sync; else .venv/bin/pip install -r requirements.txt; fi && echo '== 清理旧 WebUI(dist) ==' && rm -rf /opt/astrbot/data/dist && echo '更新完成，请重启生效。'"
        ;;
    deploylog) [ -f "$HERE/deploy.log" ] && tail -n 200 "$HERE/deploy.log" || echo "（暂无）" ;;
    updatelog) [ -f "$HERE/update.log" ] && tail -n 100 "$HERE/update.log" || echo "（暂无）" ;;
    cred)
        echo "panel_port=$PANEL_PORT"; echo "user=astrbot"
        echo "---CRED---"
        if [ -f "$MUBUNTU_RFS/opt/astrbot/.astrbot_cred" ]; then cat "$MUBUNTU_RFS/opt/astrbot/.astrbot_cred"; else echo "（尚未抓到——请先安装并启动）"; fi
        ;;
    mstatus)  [ -x "$M" ] && "$M" status || echo "mubuntu 不可用" ;;
    *) echo "usage: deploy|start|stop|restart|status|update|deploylog|updatelog|cred|mstatus"; exit 1 ;;
esac
