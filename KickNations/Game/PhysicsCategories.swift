import Foundation

enum PhysicsCategory {
    static let striker: UInt32 = 1 << 0
    static let opponent: UInt32 = 1 << 1
    static let ball: UInt32 = 1 << 2
    static let wall: UInt32 = 1 << 3
    static let goal: UInt32 = 1 << 4
    static let arenaEffect: UInt32 = 1 << 5
    static let shield: UInt32 = 1 << 6

    static let player = striker
}
