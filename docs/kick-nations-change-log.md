# Kick Nations 变更日志

## v0.2-draft / 2026-05-13

目标：将旧版“卡通小队撞球”方向重构为“世界杯氛围但非授权”的足球弹珠台玩法。

范围：

- 新增开发 SOP。
- 新增版本映射制度。
- 更新产品文档为 v0.2 迭代目标。
- 后续代码将重构 UI、角色、弹珠球场、观众声浪、看台颜色连线。
- 后续新增自动化验收脚本和 Web 测试报告。

合规方向：

- 保留国家色彩和全球足球节庆氛围。
- 不使用 FIFA、官方赛事 Logo、官方奖杯、真实球衣、真实队徽、真实球员或官方赛事包装。

## v0.2 / 2026-05-13

状态：本地验收通过。

代码版本：

- `MARKETING_VERSION`: 0.2
- `CURRENT_PROJECT_VERSION`: 2

主要变更：

- 建立 SOP、变更日志、版本映射和本地 git 仓库。
- 将核心玩法重构为弹珠台机关、观众声浪、看台颜色连线三系统。
- 新增 `PinballArenaController`、`RoarController`、`CrowdBoardNode`、`ComboController`。
- 重写 `GameScene`，接入弹珠碰撞、声浪推球、颜色连线奖励、combo、原创角色表现和防卡球逻辑。
- 重写首页视觉，改成原创足球节庆和弹珠台风格。
- 更新国家色组、技能命名、球场命名，避免官方赛事 IP 风险。
- 新增自动化单元测试和完整验收脚本。
- 新增原创 App Icon 生成脚本并生成 App Icon 资源。

验收：

- `xcodebuild ... build` 通过。
- `xcodebuild ... test` 通过，5 个测试全部通过。
- `scripts/acceptance.sh` 通过。
- 模拟器安装、首页启动、Quick Match 启动、截图均通过。
- HTML 验收报告生成在 `reports/latest/index.html`。

已知限制：

- GitHub 远端 `loseyourself1978-blip/KickNations` 尚未创建或推送，因为当前机器未安装 GitHub CLI `gh`，需要后续联网安装/登录授权。

## GitHub 上传阻塞 / 2026-05-14

状态：阻塞，等待用户完成 GitHub MFA/授权。

说明：

- 已联网检查 `https://github.com/loseyourself1978-blip/KickNations.git`，返回 `Repository not found`。
- 已尝试通过 GitHub 连接器安装/授权创建仓库，但用户反馈 MFA 验证失败。
- 当前不会绕过认证，也不会上传到其他仓库。
- 本地代码、文档、测试、验收报告已完成；GitHub 创建仓库和推送需要 MFA 成功后继续。
