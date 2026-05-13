import Foundation

enum SkillID: String, CaseIterable, Codable, Identifiable {
    case overtimeBoost
    case cactusBounce
    case spinShot
    case perfectAngle
    case icePatch
    case mirageScreen

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .overtimeBoost: "Turbo Roar"
        case .cactusBounce: "Fiesta Bounce"
        case .spinShot: "Curve Wave"
        case .perfectAngle: "Clean Bounce"
        case .icePatch: "Ice Slide"
        case .mirageScreen: "Sand Shield"
        }
    }

    var shortEffect: String {
        switch self {
        case .overtimeBoost: "Launch and roar force up"
        case .cactusBounce: "Temporary side bumper"
        case .spinShot: "Curved next wave"
        case .perfectAngle: "Stable post rebound"
        case .icePatch: "Low-friction slide zone"
        case .mirageScreen: "Brief goal shield"
        }
    }
}
