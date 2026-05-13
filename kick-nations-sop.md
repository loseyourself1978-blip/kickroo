# Kick Nations 开发 SOP

版本：SOP-0.1  
生效日期：2026-05-13  
适用项目：Kick Nations iOS  
目标远端仓库：`loseyourself1978-blip/KickNations`

## 1. 工作原则

- 文档和代码必须同步演进。每次功能、UI、玩法、审核策略或测试策略变化，都要更新产品文档或变更日志。
- 产品版本和代码版本一一对应。每个可回滚节点都必须有版本号、变更说明、测试记录。
- 优先保证可上架闭环。玩法丰满度低于稳定性、审核安全和可验收性。
- 所有素材必须原创或可授权。允许参考世界杯氛围，不允许使用官方赛事 IP、真实队徽、真实球衣、真实球员、官方奖杯或官方标识。
- 所有脚本、构建、测试、模拟器运行由 Codex 执行。中高风险命令、联网推送、登录授权、破坏性操作需先征得用户同意。

## 2. 版本管理规则

### 2.1 文档版本

- 产品技术文档使用 `Product Spec vX.Y`。
- SOP 使用 `SOP-X.Y`。
- 变更日志记录所有版本变化。

### 2.2 代码版本

- `MARKETING_VERSION` 与产品文档主版本保持一致。
- `CURRENT_PROJECT_VERSION` 递增。
- 每次完成一个可运行验收节点，必须创建本地 git commit。
- commit message 格式：`vX.Y: concise change summary`。

### 2.3 版本映射

每次迭代必须更新 [kick-nations-version-map.md](/Users/hj/Downloads/KickNations/docs/kick-nations-version-map.md)，包含：

- 产品文档版本。
- 代码版本。
- commit hash。
- 主要变更。
- 验收报告路径。
- 是否已推送 GitHub。

## 3. 文档同步流程

每次代码改动前：

1. 确认改动属于哪个版本。
2. 在产品文档或变更日志中记录目标和范围。
3. 明确 P0/P1/P2 优先级。

每次代码改动后：

1. 更新变更日志。
2. 若玩法或 UI 行为发生变化，同步更新产品技术文档。
3. 更新测试用例和验收报告。

## 4. 自动化测试流程

每次代码更新后必须执行：

1. 静态检查：确认文档、脚本、项目文件存在。
2. 构建检查：`xcodebuild -project KickNations.xcodeproj -scheme KickNations -destination ... build`。
3. 模拟器检查：启动 iPhone 模拟器、安装 App、运行 App。
4. 运行效果检查：获取模拟器截图，确认首页/游戏页非空、主要 UI 可见。
5. 可视化报告：生成 `reports/latest/index.html`，并用浏览器预览。

失败处理：

- 若任一检查失败，必须修复代码或脚本。
- 修复后重新执行完整测试。
- 直到全部通过，才允许标记验收完成。

## 5. GitHub 流程

目标仓库：`loseyourself1978-blip/KickNations`。

当前约束：

- 本机尚未安装 GitHub CLI `gh`。
- GitHub 远端创建和推送需要联网与账号授权。

流程：

1. 本地先初始化 git 仓库。
2. 每个验收节点创建本地 commit。
3. 当需要创建远端仓库或推送时，Codex 请求用户授权联网/安装工具/登录。
4. 优先使用 GitHub 官方 CLI 或可用 GitHub 连接器。
5. 推送后更新版本映射中的远端状态。

## 6. 高风险操作定义

执行前必须询问用户：

- 删除大量源代码或资源。
- `rm -rf`、`git reset --hard`、强制 push。
- 安装软件、联网下载依赖、创建远端仓库。
- 修改签名证书、App Store Connect、Apple Developer 账号设置。
- 上传代码到 GitHub。

## 7. 当前 P0 验收门槛

- App 可编译。
- 模拟器可启动并进入 App。
- 首页呈现新的原创足球节庆 UI。
- 游戏页呈现弹珠球场、门柱机关、看台颜色区、声浪 UI。
- 玩法无官方 IP 风险。
- 自动化报告生成并可在浏览器打开。
- 文档、代码、测试三者版本一致。

