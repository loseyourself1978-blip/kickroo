# Kick Nations Product & Technical Spec

Version: 0.3  
Date: 2026-05-15  
Market: North America Apple App Store  
Target launch-ready date: 2026-05-28  
World tournament opening date: 2026-06-11  
Positioning: unofficial World Cup season arcade physics soccer cup

## 1. Product Summary

Kick Nations is a portrait iOS arcade game built around one core experience: Global Cup 48. Players choose a country-inspired cartoon character, optionally play a practice match first, then enter a 48-team cup with 12 groups and a 32-team knockout bracket.

The product is not an official tournament app, not a betting product, and not a licensed national-team game. It avoids official event marks, team crests, real players, official trophies, and any wording that implies affiliation.

Core product sentence:

Players attack upward through a pinball football pitch, use lucky rebounds and roar waves, and try to carry their nation through Global Cup 48.

## 2. MVP Scope

Included in v0.3:

- iPhone-only portrait gameplay.
- SwiftUI shell with SpriteKit game scene.
- One visible core mode: Global Cup 48.
- Practice First match before official cup play.
- 48 country-inspired teams.
- 12 groups, group standings, goal difference sorting, knockout progression.
- Upward attack direction: player starts at the bottom, opponent defends at the top.
- Cartoon player avatars with face, hair, national-color kit, short code, and symbol.
- Standard football look: white ball with black patches and circular seam.
- Goal frame with net, highlighted rebound posts, and open goal trigger.
- Distinct random blockers with varied silhouettes.
- Strong launch power, high rebound, lucky deflections, and anti-stuck nudges.
- Original procedural audio for crowd, kick, bounce, goal, roar, and boo.
- Local progression and coins for completed official matches.

Removed from v0.3:

- Separate quick match, daily challenge, replay lab, and rush mode entries.
- Bottom color-grid crowd matching UI.
- Any unlabelled tappable UI that lacks immediate feedback.

## 3. Core Gameplay

Controls:

1. Press anywhere on the field.
2. Aim the arrow toward the top goal.
3. Hold to fill the gold power meter.
4. Release to launch the player and boost the ball.
5. Use Left, Roar, and Right buttons to push the ball upward with sound waves.
6. Use posts, springs, referee signs, keeper signs, and other blockers for lucky multi-bounce goals.

Recommended physics:

| Setting | Target |
|---|---:|
| Cup match duration | 50s |
| Practice duration | 60s |
| Launch power multiplier | 2.35-2.65 |
| Rebound multiplier | 1.38-1.50 |
| Anti-stuck timeout | ~0.82s |
| Ball damping | 0.10-0.16 |
| Post restitution | very high |

## 4. Cup Rules

- 48 teams split into 12 groups of 4.
- Group scoring: win 3, draw 1, loss 0.
- Ranking: points, goal difference, goals for, short code.
- Group matches can draw.
- Knockout stages require a winner.
- Knockout path: Round of 32, Round of 16, Quarter Final, Semi Final, Final.

## 5. Technical Modules

| Area | File | Responsibility |
|---|---|---|
| App route | `KickNations/App/AppRouter.swift` | Home, nation selection, practice, official cup, results |
| Cup model | `KickNations/Models/GlobalCup.swift` | Groups, standings, rankings, stage advancement |
| Match rules | `KickNations/Models/MatchRules.swift` | Cup-only mode, practice rules, official match rules |
| Nation data | `KickNations/Models/Nation.swift` | 48 teams, stats, colors, symbols |
| Gameplay scene | `KickNations/Game/GameScene.swift` | SpriteKit physics, upward attack, goals, avatars, football, anti-stuck |
| Arena blockers | `KickNations/Game/PinballArenaController.swift` | Distinct random blockers and movement |
| Roar waves | `KickNations/Game/RoarController.swift` | Energy, heat, wave origins, force |
| Audio | `KickNations/Services/ProceduralAudioService.swift` | Original generated sound effects |
| UI | `KickNations/UI/*.swift` | Home, nation select, game HUD, results |
| Tests | `KickNationsTests/GameplayLogicTests.swift` | Cup rules, rankings, single mode, bouncy rules |

## 6. Acceptance

Required automated screenshots:

- Home.
- First-match animated tutorial.
- Practice First gameplay.
- Official Cup gameplay.

Required checks:

- Build succeeds.
- Unit tests pass.
- Simulator install and launch succeed.
- Screenshots show no blank or stale UI.
- Home exposes only Global Cup 48 related flow.
- Game view shows upward attack, animated tutorial, recognizable football, cartoon characters, frame-and-net goals, varied blockers, and no bottom color grid.
