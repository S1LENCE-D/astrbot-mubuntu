#!/bin/sh
# customize.sh —— 安装时自动"刷入" mubuntu 环境 + 设置脚本权限
# 注意: customize.sh 是被 source 执行的，模块目录必须用 $MODPATH（不能用 $0/%0）
MODPATH="${MODPATH:-${0%/*}}"

# 1) 自动安装 mubuntu（若已装则跳过）
MUB_DIR=/data/adb/modules/mubuntu
if [ -d "$MUB_DIR" ] && [ -f "$MUB_DIR/module.prop" ]; then
    ui_print "- 检测到已安装的 mubuntu，跳过"
else
    if [ -f "$MODPATH/assets/mubuntu.zip" ]; then
        ui_print "- 自动刷入 mubuntu 环境…"
        mkdir -p "$MUB_DIR"
        (unzip -o "$MODPATH/assets/mubuntu.zip" -d "$MUB_DIR" >/dev/null 2>&1) || \
        (tar -xf "$MODPATH/assets/mubuntu.zip" -C "$MUB_DIR" 2>/dev/null) || \
        ui_print "? 解压 mubuntu 失败，请手动刷入 Mubuntu_1.0.13.zip"
        chmod 755 "$MUB_DIR/system/bin/mubuntu" "$MUB_DIR/bin/tar" "$MUB_DIR/service.sh" "$MUB_DIR/post-fs-data.sh" 2>/dev/null
        chmod 755 -R "$MUB_DIR/bin" 2>/dev/null
        # 刷入时自动开启：挂载内部存储 + 后台进程守护（写入 mubuntu 的 config）
        mkdir -p /data/adb/mubuntu
        if [ -f /data/adb/mubuntu/config ]; then
            sed -i 's/^SDCARD_MOUNT=.*/SDCARD_MOUNT=0/; s/^AUTOSTART=.*/AUTOSTART=1/' /data/adb/mubuntu/config 2>/dev/null
            grep -q '^SDCARD_MOUNT=' /data/adb/mubuntu/config || echo 'SDCARD_MOUNT=0' >> /data/adb/mubuntu/config
            grep -q '^AUTOSTART=' /data/adb/mubuntu/config || echo 'AUTOSTART=1' >> /data/adb/mubuntu/config
        else
            printf 'AUTOSTART=1
SDCARD_MOUNT=0
' > /data/adb/mubuntu/config
        fi
        ui_print "- 已自动开启：后台进程守护（默认不挂载内部存储，需用时在面板手动开）"
        ui_print "- mubuntu 已就绪，重启后生效（部署前请先 mubuntu status 确认）"
    else
        ui_print "? 未找到内置 mubuntu 包，请手动刷入 Mubuntu_1.0.13.zip"
    fi
fi

# 2) 本模块脚本权限
for f in service.sh action.sh uninstall.sh setup.sh prop_update.sh; do
    [ -f "$MODPATH/$f" ] && chmod 755 "$MODPATH/$f"
done
chmod 755 "$MODPATH/container/start.sh" "$MODPATH/container/stop.sh" 2>/dev/null
chmod 644 "$MODPATH/config.conf" "$MODPATH/module.prop" 2>/dev/null
ui_print "- astrbot-mubuntu: 脚本权限已设置"
