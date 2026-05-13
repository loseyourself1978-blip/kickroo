import Foundation

struct DailyChallenge: Codable, Equatable {
    let playerNationID: NationID
    let opponentNationID: NationID
    let arenaID: ArenaID
    let seed: UInt64

    static func today(now: Date = Date(), calendar: Calendar = .current) -> DailyChallenge {
        let dayOrdinal = calendar.ordinality(of: .day, in: .era, for: now) ?? 1
        let nations = NationID.allCases
        let arenas = ArenaID.allCases
        let player = nations[dayOrdinal % nations.count]
        let opponent = nations[(dayOrdinal + 3) % nations.count]
        let arena = arenas[(dayOrdinal + 1) % arenas.count]
        let seed = UInt64(dayOrdinal) &* 1_103_515_245 &+ 12_345

        return DailyChallenge(
            playerNationID: player,
            opponentNationID: opponent == player ? .mexico : opponent,
            arenaID: arena,
            seed: seed
        )
    }
}

