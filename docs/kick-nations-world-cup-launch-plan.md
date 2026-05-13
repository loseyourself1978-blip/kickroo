# Kick Nations 世界杯前上线版产品技术文档

版本：Product Spec v0.2-draft  
日期：2026-05-13  
目标市场：北美 Apple App Store  
目标上架日：2026-05-28 PT  
赛事时间锚点：2026-06-11 开赛，2026-05-28 为开赛前两周  
产品定位：非授权、国家氛围感、足球弹珠物理爽游

## 0. 版本迭代记录

| 版本 | 代码版本 | 日期 | 状态 | 说明 |
|---|---|---|---|---|
| Product Spec v0.1 | 0.1 build 1 | 2026-05-13 | 已归档 | 旧版国家小角色撞球玩法，作为参考保留 |
| Product Spec v0.2-draft | 0.2 build 2 | 2026-05-13 | 开发中 | 重构为足球弹珠台、观众声浪、球衣颜色连线三玩法融合 |
| Product Spec v0.2 | 0.2 build 2 | 2026-05-13 | 本地验收通过 | 完成 P0 核心玩法、原创 UI、App Icon、自动化测试和模拟器截图报告 |

### 0.1 到 0.2 迁移决策

- 保留：SwiftUI + SpriteKit 技术框架、已有国家色组数据结构、已有物理场景经验、旧 App Icon/卡通角色的“圆润玩具感”参考。
- 重写：Home、Nation Select、Match HUD、Results 的视觉语言，改为全球足球节庆和弹珠球场方向。
- 重写：核心玩法从“角色撞球对抗”转为“弹珠台机关 + 声浪控球 + 看台连线”。
- 删除或降级：Roast Replay、Party Mode 在 v0.2 P0 中不再作为主入口，避免上线前范围失控。
- 合规：任何世界杯氛围只通过原创色彩、观众、足球、球场灯光、节庆声浪表达，不使用官方 IP。

## 1. 产品一句话

Kick Nations 是一款把球场做成弹珠台、把看台做成能量盘的轻量足球街机游戏。玩家通过弹珠式发射制造连锁碰撞进球，同时用观众声浪和同色球迷连线增强技能，体验“不是精准踢球，而是点燃全场然后撞出神奇进球”的爽感。

用户可见文案必须避免暗示官方授权。App 内推荐使用：

- Global Cup Season
- Nations Clash
- Football Carnival
- Summer Football Fest
- Kick Nations

避免使用：

- FIFA
- World Cup 官方标识化表达
- 官方赛事徽标、奖杯、球衣、队徽、真实球员、真实赛事转播包装

## 2. 设计目标

- 10 秒内让玩家理解：拉动、发射、碰撞、进球。
- 30-45 秒一局，适合北美用户在碎片时间重复游玩。
- 核心爽感来自 SpriteKit 物理碰撞、连续反弹、进球瞬间、看台爆发。
- 世界杯氛围来自国家色彩、球迷声浪、看台人群、赛季倒计时，而不是官方 IP。
- 技术上优先复用当前 SwiftUI + SpriteKit 项目骨架，尽量少引入新依赖。
- 上架优先级高于玩法丰满度。先做可审核、可玩、可解释的 1.0，再在 1.1 增加内容。

## 3. 核心玩家体验

### 3.1 第一局体验

1. 玩家进入首页，看到“Quick Match”按钮和国家色块角色。
2. 点击开始，进入竖屏球场。
3. 球场不是传统足球场，而是一张足球弹珠台：门柱是高弹机关，广告牌是翻板，角旗是弹簧。
4. 玩家按住足球或己方小球员，向后拖动，看到力度箭头。
5. 松手后球冲进球场机关，连续撞击门柱、广告牌、角旗，产生 combo。
6. 下方看台出现混合球衣颜色的人群，玩家划线连接同色球迷，形成助威区。
7. 助威区转化为 Roar Energy，玩家点燃声浪，让声波推球、干扰守门员或点亮机关。
8. 球反弹进门，触发慢镜头、震动、观众爆发、分数结算。
9. 结束页展示本局最佳连锁：“7-hit Post Combo Goal”，并引导再来一局。

### 3.2 情绪曲线

- 开局：清楚、轻松、无压力。
- 中段：物理混乱变多，玩家发现“我可以利用混乱”。
- 高潮：声浪和机关叠加，产生意外进球。
- 结尾：用一句短 headline 总结这次进球，制造分享欲。

### 3.3 失败体验

失败不能让玩家觉得自己踢得差，而要像“差一点就成了神仙球”。

失败反馈：

- “Hit the post 5 times. Painful. Beautiful.”
- “Crowd almost carried it in.”
- “One more bounce and it was history.”

失败后奖励：

- 少量 coins。
- 本局最高 combo 被保留。
- 推荐一个更容易上手的国家色组或机关球场。

## 4. 三个玩法展开

## 4.1 门柱弹珠台

### 核心玩法

球场是一张竖屏弹珠台。玩家的主要操作是拉动发射，目标不是精确射门，而是让足球在机关之间形成连锁碰撞，最终弹进球门。

### 主要机关

| 机关 | 场景表现 | 玩法作用 | 技术实现 |
|---|---|---|---|
| 门柱弹珠柱 | 球门两侧发光圆柱 | 高回弹、combo 核心来源 | `SKPhysicsBody(circleOfRadius:)`，高 `restitution` |
| 广告牌翻板 | 边线短广告牌被撞后翻起 | 改变球路、增加倍率 | 静态/动态 body 切换，碰撞后 `SKAction.rotate` |
| 角旗弹簧 | 四角小旗子弯曲回弹 | 把球从死角弹回场内 | 圆形/胶囊碰撞体，命中后施加 impulse |
| 球门磁吸区 | 门前短暂吸引球 | 防止新手一直差一点 | 低强度向量吸引，冷却控制 |
| 连锁倍率灯 | 场地两侧灯带 | 强化“连续命中”的反馈 | contact delegate 计数，UI 灯逐格点亮 |

### 亮点

- 和现有 SpriteKit 物理框架天然匹配。
- 每次发射都可能产生不同球路，可重玩性强。
- 视觉反馈直接：撞击、震动、闪光、慢镜头都能支撑爽感。
- 对美术资源依赖低，几何图形和粒子就能先做出核心体验。

### MVP 规则

- 一局 45 秒。
- 进球 +1。
- 每次连续命中机关增加 combo。
- combo 不直接决定胜负，但决定 coins、headline 和排行榜分。
- 球卡住超过 2 秒，自动轻推或重置到发射区。

## 4.2 观众声浪控球

### 核心玩法

玩家不直接操控 11 名球员，而是操控看台的声浪。声浪会以波纹形式进入球场，对球、守门员、机关产生轻微影响。

### 操作方式

P0 推荐采用简单三段式：

- 左看台声浪：向右推球，点亮左侧机关。
- 中央声浪：短暂增强球速，打开球门磁吸区。
- 右看台声浪：向左推球，点亮右侧机关。

P1 再考虑节奏点击：

- 连续命中节奏，声浪更强。
- 乱点导致 Heat 上升，声浪短暂失效。

### 声浪资源

声浪不能无限使用，否则会变成无脑点屏。

| 指标 | 作用 | 推荐值 |
|---|---|---:|
| Roar Energy | 使用声浪的能量 | 0-100 |
| Roar Cost | 每次声浪消耗 | 25 |
| Roar Heat | 过度点击惩罚 | 0-100 |
| Heat Decay | 热量自然下降 | 每秒 18 |
| Overheat | 声浪失效时间 | 1.5 秒 |

### 亮点

- 世界大赛氛围强，但不需要官方赛事授权。
- 玩家感觉自己操控的是“整座球场的情绪”。
- 声波可视化非常适合移动端：圆环扩散、看台亮起、手机震动。
- 可以和颜色连线自然融合：连得越好，声浪越强。

### 技术实现

- `RoarController` 管理 energy、heat、cooldown。
- 每次声浪生成一个 `SoundWave` 数据结构：origin、radius、force、duration、teamColor。
- `GameScene.update` 中检测 ballNode 与 wave radius 的距离，按距离衰减施加 impulse。
- 视觉层使用 `SKShapeNode` 扩散圆环，配合 alpha fade。
- 声音层使用短 crowd sample 分层播放，P0 可先用系统音效和震动占位。

## 4.3 球衣颜色大战

### 核心玩法

看台里混杂不同颜色球衣的球迷。玩家快速把同色球迷连起来形成助威区。助威区越大，场上获得的技能越强。

### 操作规则

- 看台区域放在屏幕底部 28%-32%。
- 使用 6 x 4 或 7 x 4 网格。
- 玩家按住一个球迷色块开始，拖动经过相邻同色球迷。
- 连线长度 >= 3 即可结算。
- 连线越长，获得越多 Roar Energy。
- 连线长度 >= 6 时，额外触发对应颜色技能。

### 颜色技能

| 颜色 | 技能 | 场上效果 |
|---|---|---|
| 红色 | Power Shot | 下一次撞球速度 +20% |
| 蓝色 | Goal Shield | 己方球门前生成短暂缓冲 |
| 黄色 | Spark Crowd | Roar Energy 额外 +20 |
| 绿色 | Curve Wind | 下一次声浪带轻微弧线 |
| 白色 | Clean Bounce | 下一次门柱回弹更稳定 |

### 亮点

- 看台不只是背景，而是可玩的第二战场。
- 颜色连线易懂，适合休闲用户。
- 和球场结果即时绑定，避免变成独立消除小游戏。
- 可以支撑后续成长：解锁新球迷皮肤、新助威动作、新球场主题。

### 技术实现

- P0 用 SpriteKit 节点实现，避免 SwiftUI 与 SpriteKit 抢触摸事件。
- `CrowdBoardNode` 负责布局、命中测试、路径合法性、刷新。
- 数据结构：
  - `FanTile`: id、gridPosition、colorID、state。
  - `FanPath`: selectedTileIDs、colorID、startTime。
  - `CrowdReward`: roarEnergy、skillModifier、comboBonus。
- 拖动结束后，移除已连 tile，上方 tile 下落，新 tile 从顶部补齐。
- P0 不做复杂消除动画，优先保证触摸顺滑和反馈清楚。

## 5. 核心模式规划

### 5.1 Quick Match

目标：最快进入爽点。  
时长：45 秒。  
结构：单局弹珠进球 + 看台连线 + 声浪技能。  
胜负：进球数优先，combo 分用于奖励。  
用途：主入口、广告素材、留存核心。

### 5.2 Daily Rally

目标：提供每日回访理由。  
时长：45 秒。  
结构：每天固定 arena seed、固定颜色分布、固定挑战词条。  
排行榜：用 `goals * 1000 + maxCombo * 100 + styleScore`。  
技术：本地日期 seed + Game Center Leaderboard。若 Game Center 审核或配置未就绪，P0 先本地榜。

### 5.3 Pinball Puzzle

目标：给不喜欢对抗的玩家一个轻目标。  
时长：20-30 秒。  
结构：固定球位，要求用有限次数发射进球。  
上线建议：P1，1.0 可不做。

### 5.4 Replay Moment

目标：分享传播。  
时长：自动截取 6-8 秒。  
P0 方案：用确定性 replay 数据重播，并截屏保存最后一帧。  
P1 方案：接入 ReplayKit 或 AVAssetWriter 生成短视频。

## 6. 场景与界面

### 6.1 Home

内容：

- Quick Match 主按钮。
- Daily Rally 次按钮。
- 当前国家色组。
- 赛季倒计时：“Global Football Season starts soon”。
- coins、设置、商店入口。

技术：

- SwiftUI `HomeView`。
- 不放大段文字介绍，首页必须像游戏入口，不像落地页。

### 6.2 Nation Select

内容：

- 6 个国家氛围色组：USA、Mexico、Brazil、Japan、Canada、Morocco。
- 使用抽象吉祥物和颜色，不使用官方队徽/球衣。
- 每个色组展示一个主动特性。

技术：

- 复用现有 `NationLibrary`、`NationSelectView`。
- 当前 `NationID` 可保留，视觉描述改成原创角色。

### 6.3 Match Scene

屏幕分区：

- 顶部 10%：比分、时间、combo。
- 中部 58%-62%：弹珠球场。
- 底部 28%-32%：看台颜色连线。
- 右侧/底部浮动：三段声浪按钮，或在看台结算后显示 Roar button。

技术：

- `SpriteView(scene:)` 承载整个可交互玩法。
- SwiftUI HUD 只负责比分、时间、暂停、技能按钮。
- 触摸逻辑优先放在 `GameScene`，按 y 坐标路由到 field 或 crowd。

### 6.4 Results

内容：

- 比分。
- 最高 combo。
- 最佳 headline。
- coins。
- 再来一局。
- 分享按钮。

headline 示例：

- “Post-post-board-goal. Totally intended.”
- “The crowd pushed that one in.”
- “Seven bounces, zero shame.”

## 7. 技术框架

当前项目已经具备 SwiftUI + SpriteKit 基础结构，应在此基础上演进。

### 7.1 技术栈

| 层 | 方案 |
|---|---|
| App Shell | SwiftUI |
| 核心玩法 | SpriteKit |
| 物理 | SpriteKit Physics |
| 状态管理 | `ObservableObject` + `@Published` |
| 本地存档 | `Codable` + UserDefaults/File |
| 触觉 | `UIImpactFeedbackGenerator` |
| 分享 | `UIActivityViewController` |
| 排行榜 | Game Center，若风险高则 P1 |
| 广告/IAP | StoreKit/Ad SDK，若审核风险高则 P1 |
| 分析 | 现有 `AnalyticsService` 抽象层 |

### 7.2 模块拆分

建议新增或调整：

| 模块 | 文件建议 | 职责 |
|---|---|---|
| 弹珠球场 | `KickNations/Game/PinballArenaController.swift` | 构建门柱、广告牌、角旗、磁吸区 |
| 声浪系统 | `KickNations/Game/RoarController.swift` | energy、heat、声波效果、力场 |
| 看台连线 | `KickNations/Game/CrowdBoardNode.swift` | 球迷网格、连线、刷新、奖励 |
| combo 结算 | `KickNations/Game/ComboController.swift` | 碰撞计数、倍率、headline 输入 |
| 比赛状态 | `KickNations/Game/MatchViewModel.swift` | 快照、结果、技能入口 |
| 数据定义 | `KickNations/Models/MatchRules.swift` | 模式、时长、计分规则 |
| 国家色组 | `KickNations/Models/Nation.swift` | 色彩、技能、AI 参数 |

### 7.3 状态机

`MatchPhase` 建议定义：

- `ready`
- `launching`
- `inPlay`
- `goalCelebration`
- `resetting`
- `overtime`
- `finished`

关键规则：

- `goalCelebration` 期间冻结输入 0.8 秒。
- `resetting` 期间清理临时声波与磁吸。
- `finished` 后只允许结果页读取快照，不再接受触摸。

### 7.4 物理参数

初始调参：

| 对象 | restitution | friction | linearDamping | 备注 |
|---|---:|---:|---:|---|
| Ball | 0.86 | 0.10 | 0.35 | 保持爽快滚动 |
| Goal Post Bumper | 1.18 | 0.05 | 0 | 允许夸张反弹 |
| Ad Board | 0.95 | 0.10 | 0 | 稳定改变方向 |
| Corner Flag | 1.30 | 0.04 | 0 | 弹簧感来源 |
| Player/Mascot | 0.55 | 0.40 | 1.4 | 不抢球的主角感 |
| Wall | 0.88 | 0.08 | 0 | 防止死球 |

防卡球策略：

- 球速低于阈值且离最近目标超过 1.2 秒，施加轻微随机 impulse。
- 球停在角落超过 2 秒，角旗自动弹出。
- 球出界或物理异常，重置到最近发射点并保留当前 combo 的一半。

### 7.5 输入路由

`GameScene` 统一接收触摸：

- 如果触摸点在 fieldRect：进入拉动发射逻辑。
- 如果触摸点在 crowdRect：进入颜色连线逻辑。
- 如果点击 roarButtonRect：触发声浪。

这样可以避免 SwiftUI overlay 和 SpriteKit 同时争夺 gesture，减少上线前 bug。

### 7.6 AI

P0 不需要复杂 AI。对手只需要让场上有压力：

- 每 0.8-1.4 秒选择一次目标。
- 如果球在对手半场，偏向防守推球。
- 如果球在我方半场，偏向射门方向。
- 对手不操作看台，只通过固定 Roar cooldown 获得少量声浪，避免玩家感觉不公平。

### 7.7 Replay

P0 推荐确定性重放：

- 记录 seed。
- 记录玩家输入事件：time、type、position、force、crowdPath、roarType。
- 记录关键物理事件：goal、maxCombo、headline。
- 结果页可重播同一局，先不生成视频。

P1 再做视频导出：

- ReplayKit 或 AVAssetWriter。
- 6-8 秒竖屏短视频模板。
- 分享到系统 share sheet。

### 7.8 性能目标

- iPhone 12 及以上：稳定 60fps。
- 同屏 SpriteKit 节点 P0 控制在 180 个以内。
- 粒子效果限制同时 3 组以内。
- 声波视觉最多同时存在 3 个。
- 看台 grid 维持 24-28 个 tile，不做大规模粒子人群。

## 8. 内容规划

### 8.1 首发国家色组

| 色组 | 技能 | 场地特色 | 体验关键词 |
|---|---|---|---|
| USA | Turbo Roar | 边线加速带 | 快、直接、冲刺 |
| Mexico | Fiesta Bounce | 角旗弹簧更强 | 热闹、反弹、惊喜 |
| Brazil | Curve Carnival | 中圈弧线风 | 花式、旋转、神仙球 |
| Japan | Precision Wave | 短暂预判线 | 干净、几何、计算 |
| Canada | Ice Slide | 低摩擦冰区 | 滑行、失控、反杀 |
| Morocco | Sand Shield | 门前缓冲区 | 防守、反弹、耐心 |

### 8.2 首发球场

P0 首发 3 个足够：

- Neon Stadium：标准弹珠球场，最适合新手。
- Fiesta Boards：广告牌翻板多，combo 高。
- Ice Corners：角旗弹簧和低摩擦区，容易出混乱进球。

P1 再补：

- Precision Grid。
- Sand Shield。
- Turbo Lanes。

### 8.3 美术方向

- 几何、明亮、玩具感。
- 国家色彩可以明显，但不复刻真实球衣。
- 看台球迷用圆点、围巾、色块表达，不画真实队徽。
- 球场广告牌使用虚构品牌：KICK、ROAR、BOUNCE、GOAL。
- App Icon 用原创足球 + 声波/门柱，不使用真实奖杯轮廓。

## 9. 商业化

上线优先级：先可审，再商业化。

P0 推荐：

- 免费下载。
- coins 只解锁皮肤，不影响胜负。
- 不做强制广告。

可选 P0：

- Rewarded Ad：看广告获得双倍 coins。
- Remove Ads：若广告已接入再提供。

P1：

- 皮肤包。
- Replay 模板包。
- 球场主题包。

审核降级策略：

- 若 IAP 配置、广告 SDK、隐私披露拖慢审核，1.0 直接移除广告/IAP，作为免费无广告版本上线。
- 1.1 在赛事热度期间补商业化，比 1.0 错过窗口更可接受。

## 10. 审核与合规

### 10.1 IP 风险

必须做到：

- 不使用 FIFA、官方赛事 Logo、官方奖杯、官方吉祥物。
- 不使用真实国家队队徽、真实球衣模板、球员姓名、肖像。
- 不使用官方赛程数据作为 App 内功能核心。
- 不写“official”“licensed”“World Cup 2026 game”等误导性 metadata。
- App Review Notes 说明：Kick Nations is an original arcade soccer game with fictional art and no official tournament affiliation.

### 10.2 Apple 审核高风险点

| 风险 | 对应策略 |
|---|---|
| 2.1 App Completeness | 不提交半成品、占位图、崩溃、坏链接 |
| 2.3 Misleading Users | metadata 不承诺官方赛事、真实球队、实时赛程 |
| 4.2 Lasting Value | P0 必须有完整可玩循环、每日挑战、解锁 |
| 5.1 Privacy | 隐私政策、数据收集说明、SDK 清单完整 |
| 5.2 Intellectual Property | 所有素材原创或有授权 |
| IAP 未审核 | 先砍 IAP，避免阻断 1.0 |
| 广告 SDK 隐私 | 不确定就先不上广告 |

### 10.3 App Store 提交材料

必须在 2026-05-19 前准备：

- App 名称：Kick Nations。
- Subtitle：Arcade Soccer Pinball。
- Keywords：soccer, football, arcade, pinball, nations, sports, casual。
- 隐私政策 URL。
- Support URL。
- 5.5/6.7 英寸 iPhone 截图。
- App Icon 1024。
- Review Notes。
- 年龄分级问卷。
- 若使用广告/分析 SDK：Privacy Manifest 与 Nutrition Label。

Review Notes 建议文案：

```text
Kick Nations is an original arcade soccer pinball game. It does not use official tournament branding, team logos, player likenesses, real match data, betting, user-generated content, or social chat. All nation-inspired characters, stadiums, signs, and crowd visuals are fictional/original.
```

## 11. 倒排上线计划

当前日期：2026-05-13。  
北美上架目标：2026-05-28 PT。  
可用时间：15 天。  
策略：2026-05-20 提交首审，预留至少 2 次拒审/修复/重提窗口。

| 日期 | 目标 | 交付物 | 备注 |
|---|---|---|---|
| 05-13 | 范围冻结 | 本文档、P0/P1 决策 | 今天必须定玩法骨架 |
| 05-14 | 弹珠台 P0 | 门柱、广告牌、角旗、combo、进球 | 先把物理爽感跑起来 |
| 05-15 | 看台颜色 P0 | 6x4 grid、同色连线、Roar Energy | 先 SpriteKit 内实现 |
| 05-16 | 声浪控球 P0 | 三段声浪、heat、波纹、球体 impulse | 与颜色连线打通 |
| 05-17 | 模式闭环 | Quick Match、Results、coins、headline | 第一版可完整游玩 |
| 05-18 | 内容与教程 | 3 球场、6 色组、首局引导 | 不追求全量美术 |
| 05-19 | 上架资产 | icon、截图、metadata、隐私政策、Review Notes | 同步真机 QA |
| 05-20 | 首审提交 | App Store Connect build 1.0.0 | 目标当天 PT 晚前提交 |
| 05-21 | 审核响应 | 若通过，设为 Pending Developer Release | 若拒审，当天修 |
| 05-22 | 第一次重提窗口 | build 1.0.1 | 优先修 2.1、5.1、5.2 |
| 05-23 | 稳定性回归 | 真机、低电量、冷启动、无网 | 不再加新功能 |
| 05-24 | 第二次重提窗口 | build 1.0.2 | 必要时砍广告/IAP/Game Center |
| 05-25 | 最终风险处理 | 审核沟通、必要降级 | 不依赖 expedited review |
| 05-26 | 锁版 | 已批准版本、产品页最终检查 | 只修阻断问题 |
| 05-27 | 发布准备 | 定价、地区、可用性、监控 | 北美 release checklist |
| 05-28 | 上架 | Ready for Sale | 开赛前两周上线 |

### 11.1 拒审应对顺序

1. 崩溃/性能/占位内容：当天修复，立即重提。
2. 隐私/链接/metadata：当天修文案和 App Store Connect 信息。
3. IP 误导：立刻移除争议词、截图、描述。
4. IAP/广告：直接从 1.0 移除，不争论。
5. Game Center 配置：移到 1.1，本地榜替代。

### 11.2 不做事项

上线前不做：

- 实时多人。
- 复杂账号。
- 聊天/UGC。
- 官方赛程/比分。
- 真实球员、真实队徽、真实球衣。
- 深度养成数值。
- 需要服务器兜底的活动系统。

## 12. P0 开发清单

### 12.1 Gameplay

- [ ] 新建 `PinballArenaController`，生成 P0 机关。
- [ ] 调整 `GameScene` 输入区域：field/crowd/roar。
- [ ] 增加 combo 计数和 headline。
- [ ] 增加球卡住保护。
- [ ] 增加 45 秒比赛规则。
- [ ] 增加 3 个球场配置。

### 12.2 Crowd

- [ ] 新建 `CrowdBoardNode`。
- [ ] 实现 6x4 tile 布局。
- [ ] 实现同色路径选择。
- [ ] 实现 tile 消除和补齐。
- [ ] 输出 `CrowdReward`。

### 12.3 Roar

- [ ] 新建 `RoarController`。
- [ ] 实现 energy/cost/heat。
- [ ] 实现左/中/右声浪。
- [ ] 实现视觉波纹。
- [ ] 接入 haptics。

### 12.4 UI/UX

- [ ] 更新 `HomeView` 主入口。
- [ ] 更新 `GameView` HUD：score、time、combo、roar。
- [ ] 更新 `ResultsView`：headline、maxCombo、coins。
- [ ] 加首局三步引导。
- [ ] 更新截图所需稳定画面。

### 12.5 App Store

- [ ] App Icon。
- [ ] 截图。
- [ ] 隐私政策。
- [ ] Support URL。
- [ ] Review Notes。
- [ ] 年龄分级。
- [ ] 北美地区可用性。

## 13. 验收标准

提交首审前必须满足：

- 冷启动到第一局开始 < 5 秒。
- 第一局 10 秒内能产生至少一次明显机关碰撞。
- 45 秒内大概率能进 1 球。
- 看台连线成功率高，手指不容易误触。
- 连线、声浪、碰撞、进球之间有明确因果反馈。
- 连续游玩 10 局无崩溃。
- 无网络状态下 Quick Match 可玩。
- 隐私、支持链接可打开。
- 所有截图与实际 UI 一致。
- App 内无官方授权暗示。

## 14. 参考依据

- FIFA 官方赛程页显示赛事首日为 2026-06-11，决赛为 2026-07-19。
  https://www.fifa.com/en/tournaments/mens/worldcup/canadamexicousa2026/articles/match-schedule-fixtures-results-teams-stadiums
- Apple App Review 页面说明，平均 90% 的提交会在 24 小时内审核，但不完整提交会延迟或不通过。
  https://developer.apple.com/app-store/review/
- Apple App Review 页面列出常见拒审问题，包括 App Completeness、坏链接、占位内容、误导用户、隐私政策、第三方商标/版权授权等。
  https://developer.apple.com/app-store/review/
- Apple App Review Guidelines 5.2 要求仅使用自有或已授权内容，避免受保护第三方材料和误导性 metadata。
  https://developer.apple.com/app-store/review/guidelines/
