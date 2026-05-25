# Kickroo!

Kickroo! is a portrait iOS arcade soccer game built around swipe controls, cartoon collisions, and a 48-team Global Cup run.

Players swipe any teammate into the ball, watch the player rebound after contact, and use lucky ricochets off officials, sideline props, and goal frames to create big gold `GOAL!` moments.

## Current Build

- App Store name: `Kickroo!`
- Bundle ID: `com.loseyourself1978.kickroo`
- Version: `0.4.2`
- Build: `7`
- Platform: iPhone-only portrait iOS
- Core mode: Global Cup 48

## Key Folders

- `KickNations/` - SwiftUI and SpriteKit app source.
- `KickNationsTests/` - gameplay and cup logic tests.
- `docs/` - product spec, SOP, competitor research, support, privacy, and marketing pages.
- `app-store/` - App Store metadata, screenshot plan, and submission checklist.
- `scripts/` - icon generation and acceptance automation.

## Local Checks

```bash
swift scripts/generate_app_icon.swift
xcodebuild -project KickNations.xcodeproj -scheme KickNations -destination 'platform=iOS Simulator,name=iPhone 17 Pro' test
```

## App Store Notes

Kickroo! is an unofficial arcade soccer game. It does not use official event marks, licensed teams, real players, betting, or real-money prizes.
