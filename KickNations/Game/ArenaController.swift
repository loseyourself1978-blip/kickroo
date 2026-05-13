import Foundation

struct ArenaController {
    let arenaID: ArenaID

    var displayName: String {
        arenaID.displayName
    }

    var summary: String {
        arenaID.shortEffect
    }
}

