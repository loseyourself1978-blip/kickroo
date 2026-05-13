import UIKit

struct HapticsService {
    func launch() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    func impact() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }

    func goal() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
}

