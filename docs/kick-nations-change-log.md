# Kickroo! 变更日志

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
- 新增弹珠场地、声浪、旧看台连线和 combo 相关控制器。
- 重写 `GameScene`，接入弹珠碰撞、声浪推球、颜色连线奖励、combo、原创角色表现和防卡球逻辑。
- 重写首页视觉，改成原创足球节庆和弹珠台风格。
- 更新国家色组、技能命名、球场命名，避免官方赛事 IP 风险。
- 新增自动化单元测试和完整验收脚本。
- 新增原创 App Icon 生成脚本并生成 App Icon 资源。

验收：

- `xcodebuild ... build` 通过。
- `xcodebuild ... test` 通过，5 个测试全部通过。
- `scripts/acceptance.sh` 通过。
- 模拟器安装、首页启动、旧快速比赛启动、截图均通过。
- HTML 验收报告生成在 `reports/latest/index.html`。

已知限制：

- GitHub 远端 `loseyourself1978-blip/kickroo` 尚未创建或推送，因为当前机器未安装 GitHub CLI `gh`，需要后续联网安装/登录授权。

## GitHub 上传阻塞 / 2026-05-14

状态：阻塞，等待用户完成 GitHub MFA/授权。

说明：

- 已联网检查 `https://github.com/loseyourself1978-blip/kickroo.git`，返回 `Repository not found`。
- 已尝试通过 GitHub 连接器安装/授权创建仓库，但用户反馈 MFA 验证失败。
- 当前不会绕过认证，也不会上传到其他仓库。
- 本地代码、文档、测试、验收报告已完成；GitHub 创建仓库和推送需要 MFA 成功后继续。

## v0.3-draft / 2026-05-14

状态：已按 2026-05-15 试玩反馈重定向为单一 Cup 体验。

代码版本目标：

- `MARKETING_VERSION`: 0.3
- `CURRENT_PROJECT_VERSION`: 3

最终范围：

- 只保留 Global Cup 48 一种核心模式，并与世界杯赛季氛围强绑定。
- 新增 Practice First 练习第一场；练习赛不写入杯赛成绩。
- 新增首次比赛教学动画层，演示从下往上蓄力射门、反弹进上方球门，并覆盖上下攻防、按压瞄准、蓄力释放、幸运反弹和声浪按钮。
- 删除下方彩色方格/看台连线玩法，避免玩家误解无反馈区域。
- 攻防方向改为上下，玩家从下往上进攻。
- 玩家形象改为卡通人物，包含脸、头发、国家色球衣、国家符号和短码。
- 足球改为白底黑色五边形/圆缝图案，增强识别度。
- 球门改成门框加编网，门柱高亮且高弹力反弹。
- 格挡改为不重复的多形状集合：裁判、边裁、守门员、角旗、小门柱、广告板、哨子、摄像机、路锥、弹簧、VAR 牌、幸运星。
- 射击和反弹力度大幅增加，并加入低速防卡强力推回机制。
- 新增 48 队、12 组、小组积分、净胜球排序、淘汰赛必须获胜的 Global Cup 赛程框架。
- 新增原创现场声效：欢呼、嘘声、碰撞、进球。
- 重新生成并应用原创 App Icon，确保 Xcode 工程明确绑定 `AppIcon`。

验收要求：

- 单元测试覆盖 48 队分组、积分/排名、单一 Cup 模式、杯赛推进、强力 Cup 规则和声浪。
- 自动化验收至少截图首页、教学态、Practice First、Official Cup。
- 若任一模拟器构建、测试、安装、启动或截图失败，继续修复直到通过。

## v0.3.1 / 2026-05-16

状态：按试玩反馈进行 P0 可玩性修复，等待完整验收。

代码版本：

- `MARKETING_VERSION`: 0.3.1
- `CURRENT_PROJECT_VERSION`: 4

主要变更：

- 修复 App Icon 资源：生成器改为精确像素 RGB PNG，避免 1024@1x 实际输出 2048px 导致主屏图标不可靠。
- 重写比赛中的球场边界保险：足球穿过球门口才计分，其他出界情况会被弹回场内，避免 practice/official 中按压后足球消失。
- 调整可视化速度：降低极端速度上限，提高低速防卡推回力度，让弹珠反弹速度更接近可观察、可干预的弹子机节奏。
- 改为实时可控：按住/拖动时玩家角色会持续向目标移动，松手再补踢足球；球在运动过程中玩家和对手都能继续碰撞改变轨迹，并允许乌龙球。
- 左上角新增退出按钮，可回到进入比赛前的页面。
- 官方杯赛难度随进度递增：障碍数量、移动障碍数量、反弹强度和对手进攻频率从小组赛逐步增加到决赛。
- 角色外观增加差异：牛仔帽、墨西哥草帽、冬帽、发带、头巾、卷发、帽檐、条纹和格纹球衣等，不再只有近似秃头造型。
- 障碍物集合增加鼓、球鞋、彩带环、队长盾等形状，继续保留裁判和边裁作为可改变足球轨迹的元素。
- 更新单元测试，覆盖练习赛、杯赛开局和决赛难度递进。

## v0.4 / 2026-05-20

状态：按 Apple Store 分发前试玩反馈进行操作和赛场结构更新，等待完整验收。

代码版本：

- `MARKETING_VERSION`: 0.4
- `CURRENT_PROJECT_VERSION`: 5

主要变更：

- 操作方式从按压蓄力改为滑动：玩家从任意己方球员开始滑动，滑动方向决定球员冲刺方向，滑动速度决定冲击力度。
- 场上从单人对抗改为多人阵容：练习赛/小组赛 3v3，淘汰赛 5v5，决赛 6v6，玩家可选择任意己方球员碰撞足球。
- 移除中场随机道具生成；保留场边角旗、边裁标识和门框作为反弹元素。
- 新增高可读性的动态裁判和边裁角色，裁判、边裁、球员服饰和轮廓明显区分。
- 进球反馈增强：玩家进球显示 3 秒 `GOAL!` 与比分高亮，并播放进球声和欢呼；对方进球显示比分高亮并播放嘘声。
- 教学文案更新为滑动操作，不再提示按住蓄力。
- 产品规格、SOP 和版本映射升级到 v0.4 / build 5。

## v0.4.1 / 2026-05-21

状态：按试玩截图反馈修复公平性、反馈表现和 App Icon，构建与单元测试通过。

代码版本：

- `MARKETING_VERSION`: 0.4.1
- `CURRENT_PROJECT_VERSION`: 6

主要变更：

- 退出按钮从游戏区域/记分牌内移到安全区左上角顶端，位于球场左上角旗上方，并改为醒目的金色圆形返回按钮。
- 任意己方球员或对手碰到足球后都会按反作用力弹开，并进入短暂触球冷却；同一球员需要再次滑动才能继续主动撞球。
- 对手 AI 改为开球/重开球先保持阵型，再由单名最近球员压迫足球，其余球员守位并互相分离，降低围球和底线扎堆。
- 进球反馈改为转播风格：无论哪方进球都显示金色大写 `GOAL!`，深色比分条高亮双方比分，播放解说式 `Goal!`；玩家进球叠加欢呼，对方进球叠加嘘声。
- 进球后重新开球会播放裁判鸣哨声。
- 重做 App Icon 生成脚本和全套图标：新版包含卡通射门球员、金色滑动轨迹、标准足球、射门动线和球门。
- 更新产品技术文档、SOP、版本映射、App Store 元数据和素材清单。

验证：

- `swift scripts/generate_app_icon.swift` 通过并生成 9 个 App Icon PNG。
- `xcodebuild -project KickNations.xcodeproj -scheme KickNations -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build` 通过。
- `xcodebuild -project KickNations.xcodeproj -scheme KickNations -destination 'platform=iOS Simulator,name=iPhone 17 Pro' test` 通过，7 个测试全部通过。
- 模拟器实机截图已刷新，`reports/latest/screenshots/v0.4.1-cup-final.png` 确认金色 `GOAL!`、比分高亮和左上角安全区返回按钮可见。
- App Store 前两张截图已刷新，4 张 iPhone 6.5-inch 截图均校验为 `1242 x 2688`。
- 页面资源检查通过：`index.html`、`support.html`、`privacy.html`、`assets/hero-gameplay.png` 本地 HTTP HEAD 均返回 200，hero 图与首张 App Store 截图 hash 一致。

## v0.4.2 / 2026-05-25

状态：按品牌与上架准备反馈，将产品名切换为 Kickroo!，准备推送 GitHub。

代码版本：

- `MARKETING_VERSION`: 0.4.2
- `CURRENT_PROJECT_VERSION`: 7

主要变更：

- 面向用户的 App 名称、首页、分享文案、官网、Support、Privacy、App Store 元数据和上架清单统一改为 `Kickroo!`。
- Bundle ID 改为 `com.loseyourself1978.kickroo`，测试 Bundle ID 改为 `com.loseyourself1978.kickroo.tests`。
- `PRODUCT_NAME` 改为 `Kickroo`，`CFBundleDisplayName` 保持 `Kickroo!`，避免可执行文件路径带感叹号。
- 使用根目录 `icon.png` 作为新版 App Icon 源图，生成 20/29/40/60/1024 全套 RGB PNG。
- App Store subtitle、promotional text、keywords、description 和 What’s New 改为更轻、更北美休闲手游化的 Kickroo! 文案。
- Support/Privacy 页邮箱从 placeholder 改为 `loseyourself1978@gmail.com`。
- GitHub 目标仓库改为 `loseyourself1978-blip/kickroo`。

验证：

- `swift scripts/generate_app_icon.swift` 通过并生成 9 个 Kickroo! App Icon PNG。
- App Icon 尺寸校验通过，1024 图为 RGB。
- `xcodebuild -project KickNations.xcodeproj -scheme KickNations -destination 'platform=iOS Simulator,name=iPhone 17 Pro' test` 通过，7 个测试全部通过。
- 模拟器安装/启动 `com.loseyourself1978.kickroo` 通过，首页截图 `reports/latest/screenshots/v0.4.2-kickroo-home-clean2.png` 已确认显示 `Kickroo!`。
- App Store 第 4 张首页截图已刷新为 Kickroo! 版本，4 张 iPhone 6.5-inch 截图均校验为 `1242 x 2688`。
- 2026-05-25 页面资源复查通过：`index.html`、`support.html`、`privacy.html`、`assets/hero-gameplay.png` 本地 HTTP HEAD 均返回 200。

## v0.4.3 / 2026-05-26

状态：按试玩反馈升级分享传播与公开网页部署，等待完整验收。

代码版本：

- `MARKETING_VERSION`: 0.4.3
- `CURRENT_PROJECT_VERSION`: 8

主要变更：

- 结果页分享从纯文字 `ShareLink` 升级为 Share Poster 面板。
- 玩家可选择 Match 或 Cup 两种分享内容：单场赛果、杯赛进度/小组排名/晋级状态/冠军等。
- 新增 4 种 9:16 海报风格：Stadium、Final、Roar、Bracket，参考大型足球赛事海报的强对比背景、灯光、金色决赛、街头声浪和淘汰赛视觉。
- 海报自动生成比分、双方短码、球队色 token、headline、combo/style/coins、杯赛摘要和二维码。
- 二维码和分享文案指向 `https://loseyourself1978-blip.github.io/kickroo/`，作为北美 App Store 上架前的公开营销/下载落地页，后续可替换为 App Store URL。
- 新增系统分享面板，可分享图片、文案和落地页 URL。
- 准备 GitHub Pages 发布路径，将 `docs/index.html`、`docs/support.html`、`docs/privacy.html` 和页面素材从 `docs/` 发布为公开可访问页面。
- 营销首页新增下载/发布信息区域，明确 App Store 链接将在 release 时添加。

验证：

- `xcodegen generate` 通过。
- `xcodebuild -project KickNations.xcodeproj -scheme KickNations -destination 'platform=iOS Simulator,name=iPhone 17 Pro' -derivedDataPath DerivedData test` 通过，8 个测试全部通过。
- `scripts/acceptance.sh` 通过，新增结果页 Share Poster 截图 `reports/latest/screenshots/result-share.png`。
- 本地 HTTP 资源检查通过：`index.html`、`support.html`、`privacy.html`、`assets/hero-gameplay.png` 均返回 200。
- 主分支已推送到 GitHub commit `3a46664`，`docs/` 已推送到 `gh-pages` 分支 commit `e43e062`。
