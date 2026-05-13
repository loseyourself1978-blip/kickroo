import Combine
import SpriteKit

@MainActor
final class MatchViewModel: ObservableObject {
    let configuration: MatchConfiguration
    let scene: GameScene

    @Published var snapshot: MatchSnapshot = .empty
    @Published var result: MatchResult?

    init(configuration: MatchConfiguration) {
        self.configuration = configuration
        let scene = GameScene(size: CGSize(width: 390, height: 844), configuration: configuration)
        scene.scaleMode = .resizeFill
        self.scene = scene

        scene.onSnapshot = { [weak self] snapshot in
            Task { @MainActor in
                self?.snapshot = snapshot
            }
        }

        scene.onMatchEnd = { [weak self] result in
            Task { @MainActor in
                guard self?.result == nil else { return }
                self?.result = result
            }
        }
    }

    func activateSkill() {
        scene.activatePlayerSkill()
    }
}

