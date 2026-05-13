import Foundation
import UIKit

struct ShareService {
    func text(for result: MatchResult) -> String {
        let player = NationLibrary.nation(for: result.configuration.playerNationID)
        let opponent = NationLibrary.nation(for: result.configuration.opponentNationID)
        return "Kick Nations: \(player.shortCode) \(result.playerScore)-\(result.opponentScore) \(opponent.shortCode). \(result.headline)"
    }

    func makePlaceholderHighlightCard(for result: MatchResult) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 720, height: 1280))
        return renderer.image { context in
            UIColor(hex: "#10131A").setFill()
            context.fill(CGRect(x: 0, y: 0, width: 720, height: 1280))
            UIColor(hex: "#105B42").setFill()
            UIBezierPath(roundedRect: CGRect(x: 60, y: 260, width: 600, height: 760), cornerRadius: 24).fill()
        }
    }
}

