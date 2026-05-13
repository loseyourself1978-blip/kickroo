import Combine
import Foundation

@MainActor
final class PersistenceService: ObservableObject {
    @Published private(set) var progress: PlayerProgress

    private let key = "kickNations.playerProgress.v1"

    init() {
        if let data = UserDefaults.standard.data(forKey: key),
           let decoded = try? JSONDecoder().decode(PlayerProgress.self, from: data) {
            progress = decoded
        } else {
            progress = .fresh
        }
    }

    func selectNation(_ nationID: NationID) {
        progress.selectedNationID = nationID
        save()
    }

    func apply(_ result: MatchResult) {
        progress.coins += result.coinsEarned
        progress.matchesCompleted += 1
        save()
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(progress) else { return }
        UserDefaults.standard.set(data, forKey: key)
    }
}

