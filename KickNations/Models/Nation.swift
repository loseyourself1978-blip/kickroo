import SwiftUI

enum NationID: String, CaseIterable, Codable, Identifiable {
    case usa
    case mexico
    case brazil
    case japan
    case canada
    case morocco

    var id: String { rawValue }
}

struct Nation: Identifiable, Codable, Equatable {
    let id: NationID
    let displayName: String
    let shortCode: String
    let baseStats: NationStats
    let homeArena: ArenaID
    let skill: SkillID
    let aiProfile: AIProfile
    let palette: TeamPalette
    let replayPhrases: [String]
}

struct NationStats: Codable, Equatable {
    let speed: Double
    let power: Double
    let control: Double
    let chaos: Double
}

struct AIProfile: Codable, Equatable {
    let aggression: Double
    let defense: Double
    let curveBias: Double
    let skillUse: Double
}

struct TeamPalette: Codable, Equatable {
    let primaryHex: String
    let secondaryHex: String
    let accentHex: String
}

enum NationLibrary {
    static let all: [Nation] = [
        Nation(
            id: .usa,
            displayName: "USA Starwave",
            shortCode: "USA",
            baseStats: NationStats(speed: 0.90, power: 0.88, control: 0.70, chaos: 0.78),
            homeArena: .turboField,
            skill: .overtimeBoost,
            aiProfile: AIProfile(aggression: 0.82, defense: 0.46, curveBias: 0.25, skillUse: 0.55),
            palette: TeamPalette(primaryHex: "#2458E6", secondaryHex: "#F04C4C", accentHex: "#FFFFFF"),
            replayPhrases: ["The crowd hit full volume", "Full send off the post", "A red-blue blur found the goal"]
        ),
        Nation(
            id: .mexico,
            displayName: "Mexico Fiesta",
            shortCode: "MEX",
            baseStats: NationStats(speed: 0.76, power: 0.74, control: 0.72, chaos: 0.92),
            homeArena: .desertFiesta,
            skill: .cactusBounce,
            aiProfile: AIProfile(aggression: 0.60, defense: 0.62, curveBias: 0.45, skillUse: 0.68),
            palette: TeamPalette(primaryHex: "#128A56", secondaryHex: "#F0524F", accentHex: "#FFF4D6"),
            replayPhrases: ["The boards joined the chant", "Fiesta geometry", "Nobody called that bounce"]
        ),
        Nation(
            id: .brazil,
            displayName: "Brazil Curve",
            shortCode: "BRA",
            baseStats: NationStats(speed: 0.84, power: 0.76, control: 0.92, chaos: 0.86),
            homeArena: .sambaCurve,
            skill: .spinShot,
            aiProfile: AIProfile(aggression: 0.62, defense: 0.48, curveBias: 0.90, skillUse: 0.64),
            palette: TeamPalette(primaryHex: "#F5D64E", secondaryHex: "#159A5B", accentHex: "#2556D8"),
            replayPhrases: ["That ball had plans", "Curve did the talking", "The wave bent it home"]
        ),
        Nation(
            id: .japan,
            displayName: "Japan Grid",
            shortCode: "JPN",
            baseStats: NationStats(speed: 0.78, power: 0.66, control: 0.96, chaos: 0.54),
            homeArena: .precisionGrid,
            skill: .perfectAngle,
            aiProfile: AIProfile(aggression: 0.38, defense: 0.78, curveBias: 0.30, skillUse: 0.58),
            palette: TeamPalette(primaryHex: "#F5F5F7", secondaryHex: "#D7424B", accentHex: "#1D2433"),
            replayPhrases: ["Geometry won this match", "Calculated noise", "The wall was the teammate"]
        ),
        Nation(
            id: .canada,
            displayName: "Canada Ice",
            shortCode: "CAN",
            baseStats: NationStats(speed: 0.72, power: 0.78, control: 0.62, chaos: 0.88),
            homeArena: .iceRink,
            skill: .icePatch,
            aiProfile: AIProfile(aggression: 0.42, defense: 0.84, curveBias: 0.18, skillUse: 0.60),
            palette: TeamPalette(primaryHex: "#E33D3D", secondaryHex: "#FFFFFF", accentHex: "#9DE7FF"),
            replayPhrases: ["Everyone slid. The ball scored", "Ice did the rest", "Maximum slip, maximum cheer"]
        ),
        Nation(
            id: .morocco,
            displayName: "Morocco Shield",
            shortCode: "MAR",
            baseStats: NationStats(speed: 0.70, power: 0.80, control: 0.74, chaos: 0.70),
            homeArena: .sandShield,
            skill: .mirageScreen,
            aiProfile: AIProfile(aggression: 0.48, defense: 0.90, curveBias: 0.34, skillUse: 0.72),
            palette: TeamPalette(primaryHex: "#C83A3C", secondaryHex: "#0F8A5F", accentHex: "#E2B85E"),
            replayPhrases: ["The goal disappeared", "Sand saved it", "Aim optional, rebound mandatory"]
        )
    ]

    static func nation(for id: NationID) -> Nation {
        all.first { $0.id == id } ?? all[0]
    }
}
