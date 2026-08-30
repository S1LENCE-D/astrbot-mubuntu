#!/system/bin/sh
# prop_update.sh —— 检测 AstrBot 安装情况，实时更新 module.prop 的 description
HERE=${0%/*}
. "$HERE/config.conf"
MP="$HERE/module.prop"

if [ -d "$MUBUNTU_RFS/opt/astrbot" ] && \
   { [ -f "$MUBUNTU_RFS/opt/astrbot/main.py" ] || [ -d "$MUBUNTU_RFS/opt/astrbot/.git" ]; }; then
    ST="✓ 已安装"
else
    ST="× 未安装"
fi

BASE="依赖 Mubuntu 环境一键部署运行 AstrBot：KernelSU「执行」触发安装，开机自启 · ${ST}"
sed -i "s|^description=.*|description=${BASE}|" "$MP" 2>/dev/null
