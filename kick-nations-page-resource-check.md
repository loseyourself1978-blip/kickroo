# Kickroo! 页面资源检查

日期：2026-05-25  
范围：`docs/index.html`、`docs/support.html`、`docs/privacy.html`、`docs/assets/hero-gameplay.png`  
用途：App Store Marketing URL、Support URL、Privacy 页面上线前检查

## 1. 结论

页面资源闭环基本完成：

- `index.html`、`support.html`、`privacy.html` 均存在。
- 主页 hero 图 `docs/assets/hero-gameplay.png` 已同步最新首张玩法截图，尺寸为 `1242 x 2688`。
- 页面无外部 CSS、JS 或字体依赖，降低 GitHub Pages 首发风险。
- 2026-05-25 本地 HTTP 服务复查返回 200：`index.html`、`support.html`、`privacy.html`、`assets/hero-gameplay.png`。

支持邮箱已替换为 `loseyourself1978@gmail.com`，不再使用 placeholder。

## 2. 文件清单

| 文件 | 状态 | 说明 |
|---|---|---|
| `docs/index.html` | 通过 | Marketing URL 首页；展示 Kickroo!、触球弹开卖点、hero 截图、Support/Privacy 链接 |
| `docs/support.html` | 通过 | Support URL；包含玩法帮助、触球后需再次滑动、合规说明、真实联系邮箱、返回首页链接 |
| `docs/privacy.html` | 通过 | Privacy 页面；说明当前本地进度存储、无投注、无现金奖品、真实联系邮箱 |
| `docs/assets/hero-gameplay.png` | 通过 | 主页截图资源，`1242 x 2688`，RGBA，已与 `01-swipe-any-player-3v3.png` 同步 |

## 3. 链接与资源引用

| 页面 | 引用 | 检查 |
|---|---|---|
| `index.html` | `#features` | 页面内锚点存在 |
| `index.html` | `support.html` | 文件存在，HTTP 200 |
| `index.html` | `privacy.html` | 文件存在，HTTP 200 |
| `index.html` | `assets/hero-gameplay.png` | 文件存在，HTTP 200，图片尺寸正确 |
| `support.html` | `mailto:loseyourself1978@gmail.com` | 邮箱存在 |
| `support.html` | `index.html` | 文件存在，HTTP 200 |
| `privacy.html` | `mailto:loseyourself1978@gmail.com` | 邮箱存在 |
| `privacy.html` | `index.html` | 文件存在，HTTP 200 |

## 4. 本地检查记录

执行过的检查：

- `find docs -maxdepth 2 -type f -print`
- `rg -n "href=|src=" docs/index.html docs/support.html docs/privacy.html`
- `file docs/index.html docs/support.html docs/privacy.html docs/assets/hero-gameplay.png`
- `sips -g pixelWidth -g pixelHeight docs/assets/hero-gameplay.png`
- `shasum -a 256 docs/assets/hero-gameplay.png app-store/screenshots/en-US/iphone-6.5/01-swipe-any-player-3v3.png`
- `python3 -m http.server 8765 --bind 127.0.0.1 --directory docs`
- `curl -I http://127.0.0.1:8765/index.html`
- `curl -I http://127.0.0.1:8765/support.html`
- `curl -I http://127.0.0.1:8765/privacy.html`
- `curl -I http://127.0.0.1:8765/assets/hero-gameplay.png`

HTTP 结果：

| URL | 状态 |
|---|---|
| `http://127.0.0.1:8765/index.html` | 200 OK |
| `http://127.0.0.1:8765/support.html` | 200 OK |
| `http://127.0.0.1:8765/privacy.html` | 200 OK |
| `http://127.0.0.1:8765/assets/hero-gameplay.png` | 200 OK |

说明：Codex in-app browser 拒绝直接访问本地 `file://` 页面，所以本轮未做浏览器截图；已用本地 HTTP HEAD 与静态资源检查替代。

## 5. 内容一致性检查

| 项目 | 状态 | 说明 |
|---|---|---|
| 品牌名 | 通过 | 页面标题与 App Store name 均为 Kickroo! |
| 副标题 | 通过 | 页面 title 使用 `Swipe. Crash. Goal!`，与 App Store subtitle 对齐 |
| 核心玩法 | 通过 | 首页写明 swipe、bounce away、Global Cup 48 |
| v0.4.2 品牌/试玩反馈 | 通过 | 首页和 Support 页已使用 Kickroo! 品牌，并写明触球后球员弹开，需要再次滑动同一球员 |
| 非官方声明 | 通过 | 首页 footer 和 Support 页均声明非官方、未获赛事/联盟/球队/球员/转播背书 |
| 隐私口径 | 基本通过 | 当前写明本地进度；若启用 analytics、ads、purchases、Game Center 或 crash reporting，需更新 |
| 联系方式 | 通过 | Support 和 Privacy 页使用 `loseyourself1978@gmail.com` |

## 6. 提交前动作

1. 若 GitHub Pages 路径改变，同步更新 `app-store/metadata/en-US/app-store-connect.md` 的 Support URL 和 Marketing URL。
2. 发布到 GitHub Pages 后，用线上 URL 再做一次 200 状态和图片加载检查。
