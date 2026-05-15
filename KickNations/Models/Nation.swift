import SwiftUI

enum NationID: String, CaseIterable, Codable, Identifiable {
    case usa
    case mexico
    case brazil
    case japan
    case canada
    case morocco
    case argentina
    case france
    case germany
    case spain
    case england
    case portugal
    case netherlands
    case italy
    case uruguay
    case colombia
    case chile
    case ecuador
    case peru
    case costaRica
    case jamaica
    case panama
    case ghana
    case senegal
    case nigeria
    case egypt
    case cameroon
    case southAfrica
    case tunisia
    case algeria
    case southKorea
    case australia
    case iran
    case saudiArabia
    case qatar
    case newZealand
    case china
    case india
    case croatia
    case belgium
    case switzerland
    case denmark
    case sweden
    case norway
    case poland
    case turkey
    case ukraine
    case ireland

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
    static let all: [Nation] = NationID.allCases.enumerated().map { index, id in
        makeNation(for: id, index: index)
    }

    static func nation(for id: NationID) -> Nation {
        all.first { $0.id == id } ?? all[0]
    }

    private static func makeNation(for id: NationID, index: Int) -> Nation {
        let identity = identity(for: id)
        return Nation(
            id: id,
            displayName: identity.displayName,
            shortCode: identity.shortCode,
            baseStats: stats(for: id, index: index),
            homeArena: ArenaID.allCases[index % ArenaID.allCases.count],
            skill: SkillID.allCases[index % SkillID.allCases.count],
            aiProfile: aiProfile(index: index),
            palette: palette(index: index),
            replayPhrases: phrases(shortCode: identity.shortCode)
        )
    }

    private static func identity(for id: NationID) -> (displayName: String, shortCode: String) {
        switch id {
        case .usa: ("USA Starwave", "USA")
        case .mexico: ("Mexico Fiesta", "MEX")
        case .brazil: ("Brazil Curve", "BRA")
        case .japan: ("Japan Grid", "JPN")
        case .canada: ("Canada Ice", "CAN")
        case .morocco: ("Morocco Shield", "MAR")
        case .argentina: ("Argentina Pulse", "ARG")
        case .france: ("France Flash", "FRA")
        case .germany: ("Germany Engine", "GER")
        case .spain: ("Spain Tempo", "ESP")
        case .england: ("England Roar", "ENG")
        case .portugal: ("Portugal Drift", "POR")
        case .netherlands: ("Netherlands Tilt", "NED")
        case .italy: ("Italy Wall", "ITA")
        case .uruguay: ("Uruguay Bite", "URU")
        case .colombia: ("Colombia Beat", "COL")
        case .chile: ("Chile Spark", "CHI")
        case .ecuador: ("Ecuador Lift", "ECU")
        case .peru: ("Peru Glide", "PER")
        case .costaRica: ("Costa Rica Spring", "CRC")
        case .jamaica: ("Jamaica Sprint", "JAM")
        case .panama: ("Panama Switch", "PAN")
        case .ghana: ("Ghana Gold", "GHA")
        case .senegal: ("Senegal Surge", "SEN")
        case .nigeria: ("Nigeria Green", "NGA")
        case .egypt: ("Egypt Echo", "EGY")
        case .cameroon: ("Cameroon Charge", "CMR")
        case .southAfrica: ("South Africa Spin", "RSA")
        case .tunisia: ("Tunisia Redline", "TUN")
        case .algeria: ("Algeria Wave", "ALG")
        case .southKorea: ("Korea Signal", "KOR")
        case .australia: ("Australia Bounce", "AUS")
        case .iran: ("Iran Comet", "IRN")
        case .saudiArabia: ("Saudi Arabia Rush", "KSA")
        case .qatar: ("Qatar Mirage", "QAT")
        case .newZealand: ("New Zealand Dash", "NZL")
        case .china: ("China Lantern", "CHN")
        case .india: ("India Rhythm", "IND")
        case .croatia: ("Croatia Check", "CRO")
        case .belgium: ("Belgium Voltage", "BEL")
        case .switzerland: ("Swiss Lock", "SUI")
        case .denmark: ("Denmark Flare", "DEN")
        case .sweden: ("Sweden Ice", "SWE")
        case .norway: ("Norway Fjord", "NOR")
        case .poland: ("Poland Drive", "POL")
        case .turkey: ("Turkey Crescent", "TUR")
        case .ukraine: ("Ukraine Spark", "UKR")
        case .ireland: ("Ireland Clover", "IRL")
        }
    }

    private static func stats(for id: NationID, index: Int) -> NationStats {
        switch id {
        case .usa:
            return NationStats(speed: 0.90, power: 0.88, control: 0.70, chaos: 0.78)
        case .mexico:
            return NationStats(speed: 0.76, power: 0.74, control: 0.72, chaos: 0.92)
        case .brazil:
            return NationStats(speed: 0.84, power: 0.76, control: 0.92, chaos: 0.86)
        case .japan:
            return NationStats(speed: 0.78, power: 0.66, control: 0.96, chaos: 0.54)
        case .canada:
            return NationStats(speed: 0.72, power: 0.78, control: 0.62, chaos: 0.88)
        case .morocco:
            return NationStats(speed: 0.70, power: 0.80, control: 0.74, chaos: 0.70)
        default:
            let speed = 0.62 + Double((index * 17) % 34) / 100
            let power = 0.64 + Double((index * 23) % 32) / 100
            let control = 0.60 + Double((index * 19) % 36) / 100
            let chaos = 0.58 + Double((index * 29) % 38) / 100
            return NationStats(speed: speed, power: power, control: control, chaos: chaos)
        }
    }

    private static func aiProfile(index: Int) -> AIProfile {
        AIProfile(
            aggression: 0.42 + Double((index * 11) % 45) / 100,
            defense: 0.40 + Double((index * 13) % 46) / 100,
            curveBias: 0.18 + Double((index * 17) % 58) / 100,
            skillUse: 0.48 + Double((index * 7) % 38) / 100
        )
    }

    private static func palette(index: Int) -> TeamPalette {
        let palettes = [
            TeamPalette(primaryHex: "#2458E6", secondaryHex: "#F04C4C", accentHex: "#FFFFFF"),
            TeamPalette(primaryHex: "#128A56", secondaryHex: "#F0524F", accentHex: "#FFF4D6"),
            TeamPalette(primaryHex: "#F5D64E", secondaryHex: "#159A5B", accentHex: "#2556D8"),
            TeamPalette(primaryHex: "#F5F5F7", secondaryHex: "#D7424B", accentHex: "#1D2433"),
            TeamPalette(primaryHex: "#E33D3D", secondaryHex: "#FFFFFF", accentHex: "#9DE7FF"),
            TeamPalette(primaryHex: "#C83A3C", secondaryHex: "#0F8A5F", accentHex: "#E2B85E"),
            TeamPalette(primaryHex: "#3A7D44", secondaryHex: "#F2C14E", accentHex: "#101622"),
            TeamPalette(primaryHex: "#1F7A8C", secondaryHex: "#F8F5E8", accentHex: "#F0524F"),
            TeamPalette(primaryHex: "#6C4AB6", secondaryHex: "#17B978", accentHex: "#F8F5E8"),
            TeamPalette(primaryHex: "#DA4167", secondaryHex: "#2B59C3", accentHex: "#F2C14E"),
            TeamPalette(primaryHex: "#0B6E4F", secondaryHex: "#F9C846", accentHex: "#FFFFFF"),
            TeamPalette(primaryHex: "#E4572E", secondaryHex: "#29335C", accentHex: "#F8F5E8")
        ]
        return palettes[index % palettes.count]
    }

    private static func phrases(shortCode: String) -> [String] {
        [
            "\(shortCode) bent the noise into the net",
            "\(shortCode) found the lucky rail",
            "\(shortCode) turned one bounce into a riot"
        ]
    }
}
