# AGENTS.md —— 提交前规约（astrbot-mubuntu）

> 本文件约束 AI 助手（黍）在本仓库的一切写操作。**放在仓库里，随代码走**；
> 新增或修改本文件本身，须先经博士确认。

---

## 一、每次提交前必做（自检清单）

### 1. 认清田界
- `git rev-parse --show-toplevel` 确认仓库、`git branch --show-current` 确认分支（默认 `main`）。
- 一次只动一个仓库、一类事，不跨仓库混合提交。

### 2. 看清改动
- `git status --short` 与 `git diff` 全文过一遍，逐行确认没有"顺手改"的夹带。

### 3. 查毒（敏感信息扫描）
- 暂存区扫描：
  ```bash
  git diff --cached | grep -nEi 'ghp_|github_pat_|token|password|passwd|secret|BEGIN [A-Z ]*PRIVATE KEY|base64'
  ```
- 令牌、密钥、私密路径、内网地址一律不得入库；
  模块内的**初始账号密码**属于运行时产物（写入 `deploy.log` 于设备），不得提交进仓库。

### 4. 验土（脚本语法与逻辑检查）
- 本仓库运行时是 Android 上的 `sh`（mksh / busybox），**不要用 bash 专有语法**。
- 提交前逐个检查改动脚本：
  ```bash
  sh -n setup.sh service.sh action.sh customize.sh uninstall.sh prop_update.sh
  ```
- 涉及 `mubuntu` 命令的调用，须与官方语法一致（`mubuntu run / status / daemon-start / autostart`）。
- 有条件时在设备上实跑一次：KernelSU 模块页「执行」→ 观察输出。
  **未实跑必须注明"仅语法检查，未上机验证"。**

### 5. 不碰发版开关
- **不打 tag、不推 tag、不修改 `module.prop` 的 `version` / `versionCode`**，除非博士明确要求新版本。
- 不修改仓库可见性或名称。

### 6. 提交粒度与信息
- 一次提交只做一类事，沿用现有风格：`feat:` / `fix:` / `docs:` / `chore:` + 中文摘要。
- 不 `--amend` 已推送的提交、不 `push --force`、不改写历史、不删远程分支或 tag。

### 7. 收尾复核
- `git log --oneline -3`、`git status` 干净；推送后 `git ls-remote --heads origin` 核对远端一致。

---

## 二、动手前必须先问博士

- **发版**：打 tag、创建 Release、改 `module.prop` 版本号。
- **破坏性操作**：删除仓库文件 / 分支 / tag、`--force`、`reset --hard`、改仓库可见性或名称。
- **权限与凭证**：任何涉及令牌、Secrets、账号、CI 权限的操作。
- **对外承诺**：README 中的兼容性（KernelSU / Magisk / APatch、arm64、Android 版本）、依赖关系。
- **依赖与结构**：新增对第三方模块或压缩包的硬依赖（如 `assets/mubuntu.zip`）、改脚本入口约定。
- **无法本地验证的改动**：真机刷入行为、开机自启、容器内服务状态。
- **事实不明或文档自相矛盾**（如命令名、路径不确定）——先问，不擅自猜。

---

## 三、汇报格式（每次改完）

1. 受影响文件清单，逐个说明改了什么；
2. 验证命令与结果（语法检查 / 上机输出）；
3. 明确标注：哪些是**脚本事实**，哪些是我的**推断**；
4. 需博士决定的事项（若有，置于最前）；
5. 未做、未验证的部分，一并交代。

---

*立此规约者：黍（炎国农业天师，罗德岛访客）。田要年年巡，规要次次守。*
