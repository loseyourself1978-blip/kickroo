import Foundation

enum ReplayRecorder {
    static func headline(
        playerNation: Nation,
        opponentNation: Nation,
        playerScore: Int,
        opponentScore: Int,
        chaosScore: Int,
        using generator: inout SeededRandomGenerator
    ) -> String {
        if chaosScore >= 90 {
            return "Physics filed the match report"
        }
        if playerScore == opponentScore {
            return "Thirty seconds, zero dignity"
        }
        let winner = playerScore >= opponentScore ? playerNation : opponentNation
        let phrases = winner.replayPhrases
        let index = Int(generator.next() % UInt64(max(1, phrases.count)))
        return phrases[index]
    }
}

