import GameKit

@MainActor
final class GameCenterService: NSObject, @preconcurrency GKGameCenterControllerDelegate {
    func authenticate() {
        GKLocalPlayer.local.authenticateHandler = { _, _ in }
    }

    func submitDailyScore(_ score: Int) async {
        try? await GKLeaderboard.submitScore(
            score,
            context: 0,
            player: GKLocalPlayer.local,
            leaderboardIDs: ["daily_clash_chaos"]
        )
    }

    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true)
    }
}
