# Kickroo! App Store 素材清单

日期：2026-05-26  
版本：0.4.3 build 8  
Locale：en-US  
目标：美国 Apple App Store 首次提交准备

## 1. 当前状态

| 项目 | 状态 | 文件/说明 |
|---|---|---|
| App name | 就绪 | `Kickroo!`，短于 30 字符 |
| Subtitle | 就绪 | `app-store/metadata/en-US/subtitle.txt`，`wc -m` 为 20 |
| Promotional text | 就绪 | `app-store/metadata/en-US/promotional-text.txt`，低于 170 字符 |
| Keywords | 就绪 | `app-store/metadata/en-US/keywords.txt`，低于 100 字符 |
| Description | 就绪 | `app-store/metadata/en-US/description.txt`，低于 App Store 描述上限 |
| What’s New | 就绪 | 记录在 `app-store/metadata/en-US/app-store-connect.md`，已更新到 v0.4.3 |
| Support URL | 待 GitHub Pages 首次部署确认 | `https://loseyourself1978-blip.github.io/kickroo/support.html` |
| Marketing URL | 待 GitHub Pages 首次部署确认 | `https://loseyourself1978-blip.github.io/kickroo/` |
| Privacy page | 待 GitHub Pages 首次部署确认 | `docs/privacy.html`，随 `docs/` 发布到 Pages |
| Screenshots | 就绪 | 4 张 iPhone 6.5-inch 竖屏 PNG 均为 `1242 x 2688`；前两张展示最新玩法反馈，第 4 张首页图已刷新为 Kickroo! 品牌 |
| App previews | 暂不提交 | 有计划文档，无视频素材；本版本建议先不上传 |
| App icon | 就绪 | 使用根目录 `icon.png` 生成 Kickroo! 新版三主办地灵感碰撞射门图标；Asset catalog 含 20/29/40/60/1024 尺寸，1024 图为 RGB |

## 2. 元数据文件

| 文件 | 用途 | 检查结果 |
|---|---|---|
| `app-store/metadata/en-US/app-store-connect.md` | 提交总表 | 包含版本、分类、年龄评级说明、URL、截图顺序 |
| `app-store/metadata/en-US/description.txt` | Description | 已包含玩法、杯赛、免责声明 |
| `app-store/metadata/en-US/promotional-text.txt` | Promotional Text | 低于 170 字符限制 |
| `app-store/metadata/en-US/keywords.txt` | Keywords | 低于 100 字符限制，未含官方赛事或竞品品牌词 |
| `app-store/metadata/en-US/subtitle.txt` | Subtitle | 低于 30 字符限制 |

建议 App Store Connect 填写值：

- Primary Category：Games
- Secondary Category：Sports
- Age Rating：Cartoon sports action；无投注、无真实现金奖励、无官方体育授权内容
- Copyright：使用最终开发者/公司名填写

## 3. 截图素材

目标槽位：iPhone 6.5-inch / compatible iPhone screenshots  
准备尺寸：`1242 x 2688` PNG  
本地校验：`sips -g pixelWidth -g pixelHeight` 全部通过。

| 顺序 | 文件 | 状态 | 用途 |
|---|---|---|---|
| 1 | `app-store/screenshots/en-US/iphone-6.5/01-swipe-any-player-3v3.png` | 已刷新 | 第一眼展示核心玩法：滑动任意球员、触球弹开、防扎堆、足球、裁判/边裁 |
| 2 | `app-store/screenshots/en-US/iphone-6.5/02-global-cup-match.png` | 已刷新 | 展示官方杯赛语境、顶部安全区返回按钮、金色 `GOAL!` 和比分高亮 |
| 3 | `app-store/screenshots/en-US/iphone-6.5/03-kickoff-drill.png` | 可沿用 | 展示教学/Practice First，降低理解成本 |
| 4 | `app-store/screenshots/en-US/iphone-6.5/04-global-cup-home.png` | 已刷新 | 展示 Kickroo! 首页、单一 Global Cup 48 定位 |

## 4. App Preview

当前建议：首发不上传 App Preview。

原因：

- Apple 允许上传最多 3 个 app previews，但视频需要按设备规格准备，且前 30 秒必须足够稳定。
- 当前已有四张静态截图可以完成首发素材闭环。
- 若后续录制视频，应先按 `app-store/previews/app-preview-plan.md` 的 3 段结构制作：Swipe Any Player、Global Cup 48、Goal Moment。

## 5. App Icon

新版图标设计要点：参考 `icon.png`，包含红色枫叶能量、蓝色星条速度感、绿色仙人掌/沙漠灵感、金色滑动轨迹、三方碰撞、标准足球和球门爆发，强化 Kickroo! 的北美休闲手游气质。

| 文件 | 校验 |
|---|---|
| `KickNations/Assets.xcassets/AppIcon.appiconset/icon-20@2x.png` | 40 x 40 |
| `KickNations/Assets.xcassets/AppIcon.appiconset/icon-20@3x.png` | 60 x 60 |
| `KickNations/Assets.xcassets/AppIcon.appiconset/icon-29@2x.png` | 58 x 58 |
| `KickNations/Assets.xcassets/AppIcon.appiconset/icon-29@3x.png` | 87 x 87 |
| `KickNations/Assets.xcassets/AppIcon.appiconset/icon-40@2x.png` | 80 x 80 |
| `KickNations/Assets.xcassets/AppIcon.appiconset/icon-40@3x.png` | 120 x 120 |
| `KickNations/Assets.xcassets/AppIcon.appiconset/icon-60@2x.png` | 120 x 120 |
| `KickNations/Assets.xcassets/AppIcon.appiconset/icon-60@3x.png` | 180 x 180 |
| `KickNations/Assets.xcassets/AppIcon.appiconset/icon-1024@1x.png` | 1024 x 1024，RGB |

`jq empty` 校验 `Contents.json` 通过。

## 6. 提交前必须处理

| 优先级 | 项目 | 当前发现 | 动作 |
|---|---|---|---|
| 已解决 | Support 邮箱 | `docs/support.html` 和 `docs/privacy.html` 使用 `loseyourself1978@gmail.com` | 提交 App Store Connect 时填同一邮箱 |
| 已解决 | 设备族 | `project.yml` 与 app/test target 均为 iPhone-only `TARGETED_DEVICE_FAMILY = 1` | 当前只需提交 iPhone 截图；若未来支持 iPad 再补 iPad 截图 |
| P0 | 隐私表单 | 本地隐私页写明当前构建仅本地存储 | App Store Connect 隐私问卷需与最终启用的 analytics/ads/purchases/Game Center 一致 |
| P1 | App Preview | 无视频 | 本版本可跳过；后续再录制 |
| P1 | Copyright | 本地文档未指定 | 在 App Store Connect 使用最终主体填写 |

## 7. 来源

- Apple App Store Connect screenshot specifications - https://developer.apple.com/help/app-store-connect/reference/screenshot-specifications
- Apple App Store Connect app preview specifications - https://developer.apple.com/help/app-store-connect/reference/app-preview-specifications
- Apple App Store Connect app information reference - https://developer.apple.com/help/app-store-connect/reference/app-information
- Apple product page guidance - https://developer.apple.com/app-store/product-page/
