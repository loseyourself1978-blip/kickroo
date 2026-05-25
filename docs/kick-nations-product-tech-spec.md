# Kickroo! Product & Technical Spec

Version: 0.4.2  
Date: 2026-05-25  
Market: North America Apple App Store  
Target launch-ready date: 2026-05-28  
World tournament opening date: 2026-06-11  
Positioning: unofficial World Cup season arcade physics soccer cup

## 1. Product Summary

Kickroo! is a portrait iOS arcade game built around one core experience: Global Cup 48. Players choose a country-inspired cartoon character, optionally play a practice match first, then enter a 48-team cup with 12 groups and a 32-team knockout bracket.

The product is not an official tournament app, not a betting product, and not a licensed national-team game. It avoids official event marks, team crests, real players, official trophies, and any wording that implies affiliation.

Core product sentence:

Players attack upward through a pinball football pitch, use lucky rebounds and roar waves, and try to carry their nation through Global Cup 48.

## 2. MVP Scope

Included in v0.4.2:

- iPhone-only portrait gameplay.
- SwiftUI shell with SpriteKit game scene.
- One visible core mode: Global Cup 48.
- Practice First match before official cup play.
- 48 country-inspired teams.
- 12 groups, group standings, goal difference sorting, knockout progression.
- Upward attack direction: player squad starts at the bottom, opponent squad defends from the top.
- Multi-player cartoon squads with face, hair/headwear, national-color kits, short code, and symbol.
- Standard football look: white ball with black patches and circular seam.
- Goal frame with net, highlighted rebound posts, and open goal trigger.
- Sideline props only: corner flags, assistant referee markers, and goal frames remain as rebound elements.
- Dynamic officials on the pitch: a high-visibility referee and assistant referees can redirect the ball.
- Swipe-first controls: flick any teammate; swipe speed controls movement force.
- Contact recoil: any player or opponent who hits the ball is pushed away by reaction force and must be swiped again for another deliberate hit.
- Fair kickoff pressure: opponents hold shape briefly after kickoff/restart, only one opponent presses the ball at a time, and teammates separate instead of surrounding the ball.
- Strong launch power, high rebound, live player collisions, and anti-stuck nudges.
- Ball containment rules: the ball must remain visible in the pitch, score through the goal mouth, or rebound back into play.
- Goal feedback: every scored goal shows a gold broadcast-style `GOAL!`, highlights both scores for 3 seconds, plays an announcer-style "Goal!", then cheers for player goals or boos for opponent goals.
- Restart feedback: after a goal reset, play a referee-style kickoff whistle.
- In-match exit button is visually separated at the safe-area upper-left corner above the field corner flag, returning to the previous operation page.
- Progressive official-cup difficulty: group/practice squads use 3v3, knockout uses 5v5, final uses 6v6, with faster opponent pressure as the cup advances.
- More varied cartoon avatar headwear and kit motifs, including cowboy hat, sombrero, winter beanie, headband, wrap, curls, caps, stripes, and checks.
- Original/procedural audio for crowd, kick, bounce, goal, roar, boo, whistle, and an original system announcer-style goal call.
- Rebuilt App Icon from `icon.png` with North America-inspired red maple energy, blue star speed, green cactus/desert energy, three-way collision, a gold swipe trail, soccer ball, and goal frame.
- Local progression and coins for completed official matches.

Removed from v0.3:

- Separate quick match, daily challenge, replay lab, and rush mode entries.
- Bottom color-grid crowd matching UI.
- Any unlabelled tappable UI that lacks immediate feedback.

## 3. Core Gameplay

Controls:

1. Start the gesture on any teammate.
2. Swipe in the direction that player should move.
3. Swipe faster for a stronger crash into the ball.
4. Use any teammate, not only the central striker, to redirect live play.
5. Use Left, Roar, and Right buttons to push the ball upward with sound waves.
6. Use players, officials, corner flags, assistant referees, and goal frames for lucky multi-bounce goals.

Recommended physics:

| Setting | Target |
|---|---:|
| Cup match duration | 50s |
| Practice duration | 60s |
| Launch power multiplier | 1.95 practice, 2.02-2.55 official progression |
| Rebound multiplier | 1.24 practice, 1.28-1.53 official progression |
| Anti-stuck timeout | ~0.95s |
| Ball damping | 0.14-0.24 |
| Ball visible speed cap | ~380-520 pt/s |
| Post restitution | very high |
| Team count | 3v3 group/practice, 5v5 knockout, 6v6 final |
| Goal banner | 3s score-highlight overlay |
| Actor recoil cooldown | ~0.6s player, ~1.0s opponent after ball contact |
| Opponent kickoff hold | ~1.25s before first pressure |

## 4. Cup Rules

- 48 teams split into 12 groups of 4.
- Group scoring: win 3, draw 1, loss 0.
- Ranking: points, goal difference, goals for, short code.
- Group matches can draw.
- Knockout stages require a winner.
- Knockout path: Round of 32, Round of 16, Quarter Final, Semi Final, Final.
- Difficulty step increases from group match 1 through the final.

## 5. Technical Modules

| Area | File | Responsibility |
|---|---|---|
| App route | `KickNations/App/AppRouter.swift` | Home, nation selection, practice, official cup, results |
| Cup model | `KickNations/Models/GlobalCup.swift` | Groups, standings, rankings, stage advancement |
| Match rules | `KickNations/Models/MatchRules.swift` | Cup-only mode, practice rules, official match rules |
| Nation data | `KickNations/Models/Nation.swift` | 48 teams, stats, colors, symbols |
| Gameplay scene | `KickNations/Game/GameScene.swift` | SpriteKit physics, upward attack, goals, multi-player squads, officials, football, ball containment, swipe control, anti-stuck |
| Sideline props | `KickNations/Game/PinballArenaController.swift` | Corner flags, assistant-referee markers, goal-frame rebound support |
| Roar waves | `KickNations/Game/RoarController.swift` | Energy, heat, wave origins, force |
| Audio | `KickNations/Services/ProceduralAudioService.swift` | Original generated sound effects, kickoff whistle, announcer-style goal call |
| UI | `KickNations/UI/*.swift` | Home, nation select, game HUD, results |
| Tests | `KickNationsTests/GameplayLogicTests.swift` | Cup rules, rankings, single mode, bouncy rules |
| App Icon | `scripts/generate_app_icon.swift` | Reproducible icon generation from root `icon.png`, exported as exact RGB asset-catalog sizes |

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
- Game view shows upward attack, top-left safe-area exit button, swipe tutorial, recognizable football, multi-player cartoon squads, clear referee/assistant-referee roles, frame-and-net goals, and no bottom color grid.
- Ball contacts visibly push players/opponents away; AI does not surround the ball at kickoff or after restarts.
- Goals show gold uppercase `GOAL!`, highlighted score, announcer-style goal call, cheers/boos, and a whistle on restart.
- App icon renders from an RGB, exact-size asset catalog and should appear on the iOS home screen after reinstall.
