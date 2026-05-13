# Kick Nations Product & Technical Spec

Version: 0.1  
Market: North America Apple App Store  
Target launch-ready date: 2026-05-28  
World tournament opening date: 2026-06-11  
Positioning: unofficial country-inspired arcade physics soccer game

## 1. Product Summary

Kick Nations is a lightweight iOS arcade game where players control cute country-inspired mascots in 30-second physics soccer battles. Each nation has a home arena effect and a character skill. The fun comes from quick drag-and-release controls, chaotic ball rebounds, last-second goals, own goals, and shareable replay clips.

The product is not an official tournament app, not a football simulator, not a betting product, and not a team/association-licensed game. It avoids official event marks, team crests, real players, official trophies, and any wording that implies affiliation.

Core product sentence:

Players pick a tiny nation, launch it across a themed mini arena, trigger a signature skill, score chaotic goals, and share the funniest replay.

## 2. Product Principles

- Simple: one-finger drag, release, collide, score.
- Fast: first goal within 30 seconds of opening the app.
- Viral: every match can generate a short funny replay.
- Small-team friendly: no real-time multiplayer in v1.
- Monetizable but fair: cosmetics, ad removal, replay templates, no pay-to-win stats.
- North America first: English UI, short session design, TikTok/Reels/iMessage sharing.

## 3. MVP Scope

### Included in v1

- iPhone-only portrait gameplay.
- SwiftUI shell with SpriteKit game scene.
- 6 nation characters.
- 6 matching home arena effects.
- Quick Kick: player vs AI.
- Daily Clash: fixed daily matchup and arena seed.
- Roast Replay: AI vs AI auto-simulated chaos clip.
- Local unlock economy.
- Rewarded ads for bonus coins/replay export.
- In-app purchases:
  - Remove Ads
  - Starter Nation Pack
  - Replay Studio
  - Tournament Bundle
- Local replay recording using ReplayKit or deterministic replay reconstruction.
- Share sheet export to iMessage, Instagram, TikTok, WhatsApp, Files.
- Game Center leaderboard for Daily Clash score.

### Deferred after launch

- Real-time online PvP.
- Account system.
- Server-side inventory.
- Public chat or UGC comments.
- Official schedule integration.
- Licensed national team marks.
- Deep progression or equipment stats.

## 4. Core Gameplay

### Controls

The player controls one circular mascot.

1. Touch and hold the mascot.
2. Drag backward to aim.
3. Aim arrow shows direction and force.
4. Release to launch.
5. Mascot collides with ball, walls, obstacles, and opponent.
6. After cooldown, player can drag again.
7. Tap skill button when energy reaches 100.

Recommended values:

| Setting | Value |
|---|---:|
| Match duration | 30s |
| Golden goal overtime | 10s |
| Launch cooldown | 0.45s |
| Max charge time | 1.2s |
| Max launch impulse | Tuned per character |
| Ball restitution | 0.82 |
| Wall restitution | 0.90 |
| Character linear damping | 1.8 default |
| Ball linear damping | 0.55 default |

### Win Rules

- Ball fully crosses goal line: +1 goal.
- Highest score after 30s wins.
- Tie triggers 10s golden goal.
- If still tied, sudden penalty flick: each side gets one shot, closest to goal center wins.

No offside, fouls, cards, corners, throw-ins, or substitutions.

## 5. Nation, Arena, and Skill System

Each nation has:

- Character skin: visual identity.
- Home arena: passive field effect.
- Active skill: player-triggered ability.
- AI personality: simple behavior tuning.
- Replay flavor: post-match headline phrases.

### Important Balance Rule

Home arena effects are stronger in theme than in raw advantage. When a player chooses a nation, that nation can appear with its home arena in themed modes. In Quick Kick, arena is selected independently to preserve variety and fairness.

### Skill Energy

| Event | Energy |
|---|---:|
| Touch ball | +25 |
| Bump opponent | +10 |
| Block shot near goal | +15 |
| Score goal | +20 |
| Concede goal | +30 |

One match should usually allow 1-2 skill activations.

## 6. Launch Nations

### USA: Turbo Field + Overtime Boost

Visual:

- Blue rounded body.
- Red/white sporty headband.
- Star-shaped goggles.
- Tiny speed shoes.

Home arena: Turbo Field

- Sidelines contain short boost lanes.
- When any character crosses a boost lane, next launch gets +15% speed.
- Boost lanes have a 4s cooldown after use.

Active skill: Overtime Boost

- Duration: 3s.
- Launch impulse +40%.
- Ball impact power +25%.
- Skill ends with a tiny speed burst trail.

AI personality:

- Aggressive ball chasing.
- More likely to attempt direct shots.

Replay phrases:

- Last-second chaos.
- Full send.
- Overtime arrived early.

### Mexico: Desert Fiesta + Cactus Bounce

Visual:

- Green rounded body with red/white accents.
- Triangular party scarf.
- Toy-like rounded hat silhouette.
- Confetti particles.

Home arena: Desert Fiesta

- Sand patches slow characters by 18%.
- Ball is barely affected, creating funny overrun moments.
- Two cactus bumpers appear near side walls. They bounce the ball at high restitution.

Active skill: Cactus Bounce

- Places one temporary cactus bumper for 4s.
- If the ball hits it, ball gets +35% rebound speed and a curved deflection.
- Max one active cactus per player.

AI personality:

- Tries side-angle shots.
- Uses cactus skill defensively near midfield.

Replay phrases:

- The cactus assisted.
- Desert geometry.
- Nobody saw that bounce coming.

### Brazil: Samba Curve + Spin Shot

Visual:

- Yellow/green body.
- Blue shoes.
- Confident cute expression.
- Curved ball trail effect.

Home arena: Samba Curve

- Center circle adds a light spin modifier to the ball.
- Shots passing through the circle gain subtle curve for 1.5s.

Active skill: Spin Shot

- Duration: 2.5s.
- Character spins.
- Next ball hit applies curve and +20% shot speed.

AI personality:

- Waits for better angle.
- Favors rebounds and curved shots.

Replay phrases:

- That ball had plans.
- Curve did the talking.
- One touch was enough.

### Japan: Precision Grid + Perfect Angle

Visual:

- White/red minimal body.
- Origami-like shoulder panels.
- Calm focused eyes.
- Geometric line effects.

Home arena: Precision Grid

- Brief aiming guide lines appear when charging inside the center grid.
- Ball bounce prediction is shown for the next wall contact only.

Active skill: Perfect Angle

- Next launch displays extended bounce line.
- On contact, ball restitution is normalized for more predictable rebounds.
- Duration: one launch or 4s timeout.

AI personality:

- Less aggressive.
- Better at defensive positioning.

Replay phrases:

- Geometry won this match.
- Calculated.
- The wall was the teammate.

### Canada: Ice Rink + Ice Patch

Visual:

- Red/white rounded body.
- Soft hockey-style helmet.
- Ice streaks under feet.

Home arena: Ice Rink

- Entire field has lower friction.
- Character damping -25%.
- Ball speed decay -20%.
- Own goals are more common and funny.

Active skill: Ice Patch

- Creates a circular ice zone for 4s.
- Characters inside have -45% friction.
- Ball gets +15% speed while crossing the patch.

AI personality:

- Defensive, then counterattacks.
- More likely to use skill around midfield.

Replay phrases:

- Everyone slid. The ball scored.
- Ice did the rest.
- Maximum slip.

### Morocco: Sand Shield + Mirage Screen

Visual:

- Red/green body.
- Small geometric patterned cape.
- Tiny goggles.
- Warm sand swirl.

Home arena: Sand Shield

- Two soft sand whirl zones near defensive corners.
- Ball slows by 12% inside whirl zones.
- Characters get a small sideways drift.

Active skill: Mirage Screen

- Creates a 3s sand swirl around the ball.
- Opponent aim arrow shortens and lightly jitters while ball is inside.
- Does not fully hide gameplay.

AI personality:

- Defensive counterplay.
- Uses skill when opponent is charging a shot.

Replay phrases:

- The goal disappeared.
- Sand saved it.
- Aim optional.

## 7. Match Modes

### Quick Kick

Default play mode.

- Player vs AI.
- 30-second match.
- Random opponent and arena.
- First session forces an easy AI and Mini Stadium variant.
- Rewards coins and XP.

### Daily Clash

Daily fixed matchup.

- Same nations, same arena, same random seed for all players.
- Player attempts best score.
- Game Center leaderboard tracks:
  - Goal difference.
  - Fastest first goal.
  - Chaos score.

Chaos score:

```text
50 last-second goal
+40 own goal
+30 4+ bounce goal
+25 skill goal
+10 bumper-assisted goal
```

### Roast Replay

AI vs AI simulation for social content.

- Player selects two nations.
- Simulation runs for 20s.
- No manual control.
- App generates a 5-7s replay clip with headline.
- Purpose: content generation, not deep gameplay.

### Party Mode

Local pass-and-play.

- Two players on one device.
- Each player alternates one launch.
- Best of 3 goals or 30s timer.
- Great for watch parties and casual group use.

## 8. Replay and Sharing

Replay is the viral loop.

### Highlight Detection Priority

1. Last-second goal under 3s.
2. Own goal.
3. Goal after 4+ bounces.
4. Skill-assisted goal.
5. Cactus/bumper-assisted goal.
6. Fastest goal.
7. Highest ball speed goal.

### Export Format

- 720x1280 vertical MP4.
- 5-7 seconds.
- Includes:
  - Two character portraits.
  - Score.
  - Short headline.
  - Small app watermark: Kick Nations.
- No official tournament wording or marks.

Implementation options:

1. Deterministic replay reconstruction: record input events, random seed, physics snapshots around highlight, then replay in a hidden export scene.
2. ReplayKit screen recording: faster prototype, less deterministic, may require user permission and more UX friction.

Recommended MVP approach:

- Use deterministic event capture for short highlight windows.
- Export with AVAssetWriter from rendered frames if time allows.
- Fallback: share static highlight card using SwiftUI/ImageRenderer.

## 9. Economy and Monetization

### Soft Currency

Coins earned from:

- Completing match: +20.
- Win: +30.
- Daily Clash attempt: +25 once per day.
- Watching rewarded ad: +100.
- Sharing replay: +50 once per day.

Coins spent on:

- Cosmetic trails.
- Goal celebrations.
- Character expressions.
- Replay frames.

### In-App Purchases

| Product | Price | Includes |
|---|---:|---|
| Remove Ads | $4.99 | Removes interstitials, keeps optional rewarded ads |
| Starter Nation Pack | $2.99 | Extra skins, trails, expressions for launch nations |
| Replay Studio | $2.99 | Premium replay templates and headlines |
| Tournament Bundle | $9.99 | Remove Ads + Starter Pack + Replay Studio |

### Ads

Use ads lightly.

- Rewarded ad: bonus coins, extra daily attempt, premium replay export.
- Interstitial: after every 4-5 matches max, never after first match.
- No banner ads during gameplay.

## 10. Technical Stack

### Recommended Native Stack

- Language: Swift 5.9+
- UI: SwiftUI
- Game engine: SpriteKit
- Physics: SpriteKit physics bodies
- Audio: AVFoundation / SKAudioNode
- Replay export: AVFoundation + SpriteKit frame rendering; fallback to ReplayKit or static share cards
- Purchases: StoreKit 2
- Ads: Google AdMob or Unity LevelPlay
- Leaderboards: Game Center
- Analytics: Firebase Analytics or PostHog
- Crash reporting: Firebase Crashlytics
- Remote config: Firebase Remote Config, optional
- Backend: none for v1

Why this stack:

- Fastest route to App Store.
- No dependency-heavy engine setup.
- SpriteKit is enough for 2D physics arcade gameplay.
- StoreKit, Game Center, sharing, and haptics integrate cleanly.
- Solo/small team can debug and ship quickly.

### Alternative Stack

Unity is viable if the team already has Unity experience, but for a 17-day launch window native SpriteKit is simpler for App Store plumbing and smaller binary size.

## 11. Suggested Code Architecture

```text
KickNations/
  App/
    KickNationsApp.swift
    AppRouter.swift
  UI/
    HomeView.swift
    NationSelectView.swift
    ModeSelectView.swift
    ResultsView.swift
    StoreView.swift
  Game/
    GameView.swift
    GameScene.swift
    PhysicsCategories.swift
    MatchController.swift
    AIController.swift
    SkillController.swift
    ArenaController.swift
    ReplayRecorder.swift
  Models/
    Nation.swift
    Arena.swift
    Skill.swift
    MatchRules.swift
    PlayerProgress.swift
    DailyChallenge.swift
  Services/
    PurchaseService.swift
    AdService.swift
    GameCenterService.swift
    AnalyticsService.swift
    HapticsService.swift
    ShareService.swift
    PersistenceService.swift
  Assets/
    Sprites.xcassets
    Audio/
```

## 12. Core Data Models

```swift
enum NationID: String, CaseIterable, Codable {
    case usa, mexico, brazil, japan, canada, morocco
}

struct Nation: Identifiable, Codable {
    let id: NationID
    let displayName: String
    let baseStats: NationStats
    let homeArena: ArenaID
    let skill: SkillID
    let aiProfile: AIProfile
}

struct NationStats: Codable {
    let speed: Double
    let power: Double
    let control: Double
    let chaos: Double
}

enum ArenaID: String, Codable {
    case turboField
    case desertFiesta
    case sambaCurve
    case precisionGrid
    case iceRink
    case sandShield
}

enum SkillID: String, Codable {
    case overtimeBoost
    case cactusBounce
    case spinShot
    case perfectAngle
    case icePatch
    case mirageScreen
}

struct MatchRules: Codable {
    let duration: TimeInterval
    let goldenGoalDuration: TimeInterval
    let maxGoals: Int?
    let arenaID: ArenaID
}
```

## 13. SpriteKit Implementation Notes

### Scene Objects

- `playerNode`: SKSpriteNode with circular physics body.
- `opponentNode`: SKSpriteNode with circular physics body.
- `ballNode`: SKSpriteNode with circular physics body.
- `goalLeftNode`, `goalRightNode`: sensor bodies.
- `arenaEffectNodes`: sand patches, ice patches, cactus bumpers, boost lanes.
- `aimArrowNode`: SKShapeNode or SKSpriteNode.
- `skillButton`: SwiftUI overlay, not SpriteKit, for easier UI.

### Physics Categories

```swift
struct PhysicsCategory {
    static let player: UInt32 = 1 << 0
    static let opponent: UInt32 = 1 << 1
    static let ball: UInt32 = 1 << 2
    static let wall: UInt32 = 1 << 3
    static let goal: UInt32 = 1 << 4
    static let arenaEffect: UInt32 = 1 << 5
}
```

### Input Flow

- `touchesBegan`: validate touch near player and cooldown is ready.
- `touchesMoved`: calculate drag vector, clamp force, update aim arrow.
- `touchesEnded`: apply impulse to player body, start cooldown, record input event.

### Arena Effect Interface

```swift
protocol ArenaEffect {
    var id: ArenaID { get }
    func setup(in scene: GameScene)
    func update(deltaTime: TimeInterval, context: MatchContext)
    func handleContact(_ contact: SKPhysicsContact, context: MatchContext)
}
```

### Skill Interface

```swift
protocol SkillBehavior {
    var id: SkillID { get }
    func canActivate(context: MatchContext) -> Bool
    func activate(context: MatchContext)
    func update(deltaTime: TimeInterval, context: MatchContext)
}
```

Keep each skill in its own small file once the prototype works.

## 14. AI Design

Use simple heuristic AI, not machine learning.

AI loop every 0.5-0.8s:

1. If ball is near own goal, defend.
2. If clear shot exists, shoot.
3. If skill ready and ball is contested, activate.
4. Otherwise chase ball.

Difficulty parameters:

| Difficulty | Aim error | Reaction delay | Skill use |
|---|---:|---:|---:|
| Easy | 25 deg | 0.9s | Rare |
| Normal | 14 deg | 0.65s | Sometimes |
| Hard | 7 deg | 0.45s | Often |

First user match must use Easy.

## 15. Art and Audio Direction

### Art

- Toy-like rounded characters.
- Bright color blocks.
- No exact national federation crests.
- No official tournament marks.
- Readable silhouettes at small size.
- Vertical mobile-first UI.

### Audio

- Short launch pop.
- Ball impact thump.
- Wall bounce ping.
- Goal cheer burst.
- Skill-specific sounds:
  - Ice crackle.
  - Sand whoosh.
  - Confetti pop.
  - Turbo zip.

### Haptics

- Light impact on launch.
- Medium impact on ball hit.
- Success haptic on goal.
- Warning haptic in last 3 seconds.

## 16. App Store Compliance

App metadata should avoid:

- FIFA.
- World Cup.
- Official.
- 2026 tournament marks.
- Real team crests.
- Real player names/images.
- Betting language.

Suggested App Store copy:

Title: Kick Nations  
Subtitle: Tiny teams. Big chaos.  
Description phrase: A fast country-inspired arcade soccer battle game. Pick a tiny nation, master its arena, score wild physics goals, and share chaotic replays.

Required disclaimer in app settings and App Store description:

This app is an unofficial arcade game and is not affiliated with, endorsed by, or sponsored by any football federation, tournament organizer, team, or player.

## 17. Analytics Events

Track only what supports iteration.

```text
app_first_open
tutorial_first_launch
first_goal_scored
match_started
match_completed
skill_used
highlight_generated
highlight_shared
daily_clash_started
roast_replay_generated
iap_viewed
iap_purchased
rewarded_ad_started
rewarded_ad_completed
```

North-star metric:

- Highlights shared per 100 installs.

Secondary metrics:

- First match completion rate.
- First goal within 60s.
- D1 retention.
- IAP conversion.
- Rewarded ad completion rate.

## 18. Development Timeline

Assumption: today is 2026-05-11. Tournament starts 2026-06-11. Target live date is 2026-05-28, two weeks before kickoff.

Because App Review can take time, submit no later than 2026-05-24. Use 2026-05-25 to 2026-05-27 for review fixes.

### Phase 1: Prototype Core, 2026-05-11 to 2026-05-13

- Create iOS project.
- Build SpriteKit scene.
- Add player, opponent, ball, walls, goals.
- Implement drag-release launch.
- Implement scoring and 30s timer.
- Add basic AI.
- Add first-pass USA and Canada.

Exit criteria:

- One complete match can be played repeatedly.
- First goal is fun.
- No crash after 20 matches.

### Phase 2: Nation/Arena/Skill MVP, 2026-05-14 to 2026-05-17

- Add all 6 nations.
- Add all 6 arena effects.
- Add skill energy and skill button.
- Implement 6 active skills.
- Add simple character select.
- Add haptics and placeholder sound.

Exit criteria:

- Every nation feels different within 10 seconds.
- Each arena creates visible gameplay variation.

### Phase 3: Modes and Progression, 2026-05-18 to 2026-05-20

- Add Quick Kick.
- Add Daily Clash.
- Add Roast Replay.
- Add Party Mode if time allows; otherwise defer to 1.1.
- Add coins and local unlocks.
- Add results screen and highlight detection.

Exit criteria:

- Full app loop works from launch to match to reward to replay.

### Phase 4: Monetization and Sharing, 2026-05-21 to 2026-05-22

- Add StoreKit 2 products.
- Add rewarded ads.
- Add remove ads entitlement.
- Add static highlight card sharing.
- Add MP4 replay export only if stable; otherwise ship static cards and update after launch.

Exit criteria:

- Purchases work in sandbox.
- Share sheet works.
- No monetization blocker.

### Phase 5: Polish and App Store Build, 2026-05-23 to 2026-05-24

- App icon.
- Launch screen.
- App Store screenshots.
- Privacy labels.
- Disclaimer.
- Crash pass.
- Performance pass on older device.
- Submit to App Review by 2026-05-24.

Exit criteria:

- TestFlight build approved internally.
- App Store submission complete.

### Phase 6: Review Buffer and Launch Prep, 2026-05-25 to 2026-05-28

- Fix App Review issues if any.
- Prepare short videos for TikTok/Reels.
- Create App Store custom product pages if time allows.
- Publish when approved.

## 19. Post-Launch Iteration Plan

### Version 1.1, 2026-05-29 to 2026-06-05

- Improve replay export.
- Add more replay headlines.
- Add 2-4 new nations based on interest.
- Tune AI and arena balance.
- Add limited-time daily challenges.

### Version 1.2, 2026-06-06 to 2026-06-11

- Add tournament-themed countdown events without official marks.
- Improve share templates.
- Add local party rules.
- Add more cosmetics.

### During Tournament

- Daily challenge calendar.
- Hotfix balance twice per week.
- Add topical but non-infringing nation matchups.
- Promote Roast Replay clips.

## 20. Build Priorities

If time gets tight, cut in this order:

1. MP4 replay export; keep static share card.
2. Party Mode.
3. Game Center.
4. Replay Studio IAP.
5. Some premium cosmetics.

Never cut:

- Drag-release gameplay.
- 6 nations with distinct arena/skill identity.
- Quick Kick.
- Highlight share card.
- IAP remove ads.
- App Store compliance disclaimer.

## 21. Implementation Checklist

- [x] Create project and app shell.
- [x] Implement physics match scene.
- [x] Implement drag-release controls.
- [x] Implement goals, timer, reset.
- [x] Implement AI.
- [x] Implement nation model.
- [x] Implement arena effects.
- [x] Implement active skills.
- [x] Implement Quick Kick.
- [x] Implement Daily Clash.
- [x] Implement Roast Replay.
- [x] Implement reward economy.
- [ ] Implement StoreKit 2.
- [ ] Implement ads.
- [x] Implement highlight detection.
- [ ] Implement share card/export.
- [ ] Add sounds and haptics.
- [ ] Add analytics/crash reporting.
- [ ] Add App Store copy, screenshots, privacy labels.
- [ ] Submit by 2026-05-24.
