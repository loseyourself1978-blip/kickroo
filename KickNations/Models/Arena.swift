import Foundation

enum ArenaID: String, CaseIterable, Codable, Identifiable {
    case turboField
    case desertFiesta
    case sambaCurve
    case precisionGrid
    case iceRink
    case sandShield

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .turboField: "Neon Posts"
        case .desertFiesta: "Fiesta Boards"
        case .sambaCurve: "Curve Carnival"
        case .precisionGrid: "Precision Grid"
        case .iceRink: "Ice Corners"
        case .sandShield: "Sand Shield"
        }
    }

    var shortEffect: String {
        switch self {
        case .turboField: "Post bumpers and boost rails"
        case .desertFiesta: "Flip boards and corner springs"
        case .sambaCurve: "Curved roar waves"
        case .precisionGrid: "Clean bounce guides"
        case .iceRink: "Sliding ball physics"
        case .sandShield: "Goal shield zones"
        }
    }
}
