import SwiftUI

struct RootView: View {
    @EnvironmentObject private var router: AppRouter

    var body: some View {
        Group {
            switch router.screen {
            case .home:
                HomeView()
            case .nationSelect(let mode):
                NationSelectView(mode: mode)
            case .game(let configuration):
                GameView(configuration: configuration)
            case .results(let result):
                ResultsView(result: result)
            case .store:
                StoreView()
            }
        }
    }
}

