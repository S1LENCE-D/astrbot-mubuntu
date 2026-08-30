# AstrBot on Mubuntu (astrbot-mubuntu)

在 Android 的 [Mubuntu for KernelSU](https://gitee.com/ytngtaoaaa/magisk_ubuntu)（Ubuntu 24.04 chroot 环境）上一键部署并运行 [AstrBot](https://github.com/AstrBotDevs/AstrBot) 的 KernelSU / Magisk / APatch 模块。

## 引用的模块与项目

| 项目 | 来源 | 作用 |
|---|---|---|
| Mubuntu for KernelSU（magisk_ubuntu） | https://gitee.com/ytngtaoaaa/magisk_ubuntu | 基于 chroot 在 Android 运行 Ubuntu 24.04 的模块，作为 AstrBot 的运行环境 |
| AstrBot | https://github.com/AstrBotDevs/AstrBot | AI Agent 聊天机器人框架，本模块的部署目标 |

> 本模块不重复携带 Ubuntu rootfs：环境由 Mubuntu 提供，部署与自启逻辑由本模块通过 `mubuntu` 命令完成。

## 主要功能

- 🚀 **一键部署 AstrBot**：KernelSU 模块页点「执行」，自动完成 启动 Mubuntu 守护 → 安装依赖 → 克隆 AstrBot → 同步依赖 → 后台启动
- 🔑 **输出初始登录信息**：部署完成后自动抓取并显示初始用户名/密码（最多重试 3 次）
- 🔄 **开机自启**：开机自动唤起 Mubuntu 守护，已部署则自动启动 AstrBot
- ✅ **安装状态标记**：实时检测并写入模块描述（`✓ 已安装` / `× 未安装`）
- 🔒 **默认不挂载内部存储**：避免存储视图异常，需要时手动开启

## 安装使用

1. 刷入本模块（KernelSU / Magisk / APatch，arm64 设备）并重启
2. KernelSU → 模块 → `astrbot-mubuntu` → 点「执行」（首次约需 10 分钟）
3. 部署完成后浏览器访问 `http://127.0.0.1:6185`（用户名 `astrbot`，密码见执行输出）

## 说明

- 依赖 Mubuntu 环境：可先安装 [magisk_ubuntu](https://gitee.com/ytngtaoaaa/magisk_ubuntu)，或将官方 release 包放入 `assets/mubuntu.zip` 后重新打包，即可实现刷入时自动安装环境
- 仅支持 arm64（aarch64）
- 所有 muntu 操作遵循 Mubuntu 官方语法（`muntu run / status / daemon-start / autostart`）
