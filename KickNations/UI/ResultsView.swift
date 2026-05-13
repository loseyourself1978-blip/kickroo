import SwiftUI

struct ResultsView: View {
    @EnvironmentObject private var router: AppRouter
    @EnvironmentObject private var persistence: PersistenceService

    let result: MatchResult

    var body: some View {
        ZStack {
            Color.knBackground.ignoresSafeArea()

            VStack(spacing: 22) {
                Spacer(minLength: 12)

                Text(result.outcome.title)
                    .font(.system(size: 42, weight: .black, design: .rounded))
                    .foregroundStyle(result.outcome == .win ? Color.knGold : Color.white)

                HStack(spacing: 18) {
                    ResultNation(nation: playerNation, score: result.playerScore)
                    Text("-")
                        .font(.system(size: 36, weight: .black, design: .rounded))
                        .foregroundStyle(.white.opacity(0.42))
                    ResultNation(nation: opponentNation, score: result.opponentScore)
                }

                VStack(spacing: 10) {
                    Text(result.headline)
                        .font(.title2.weight(.black))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)

                    HStack(spacing: 12) {
                        ResultMetric(title: "Combo", value: "\(result.maxCombo)")
                        ResultMetric(title: "Style", value: "\(result.chaosScore)")
                        ResultMetric(title: "Coins", value: "+\(result.coinsEarned)")
                    }
                }
                .padding(16)
                .background(Color.knPanel, in: RoundedRectangle(cornerRadius: 8))

                Spacer()

                ShareLink(item: shareText) {
                    Label("Share", systemImage: "square.and.arrow.up")
                        .font(.headline.weight(.bold))
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                }
                .buttonStyle(.borderedProminent)
                .tint(Color.knGold)
                .foregroundStyle(.black)

                HStack(spacing: 12) {
                    Button {
                        router.startMatch(mode: result.configuration.mode, nationID: result.configuration.playerNationID)
                    } label: {
                        Label("Again", systemImage: "arrow.clockwise")
                            .font(.headline.weight(.bold))
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                    }
                    .buttonStyle(.bordered)
                    .tint(.white.opacity(0.35))

                    Button {
                        router.showHome()
                    } label: {
                        Label("Home", systemImage: "house.fill")
                            .font(.headline.weight(.bold))
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                    }
                    .buttonStyle(.bordered)
                    .tint(.white.opacity(0.35))
                }
            }
            .padding(20)
        }
    }

    private var playerNation: Nation {
        NationLibrary.nation(for: result.configuration.playerNationID)
    }

    private var opponentNation: Nation {
        NationLibrary.nation(for: result.configuration.opponentNationID)
    }

    private var shareText: String {
        "Kick Nations: \(playerNation.shortCode) \(result.playerScore)-\(result.opponentScore) \(opponentNation.shortCode). Max combo \(result.maxCombo). \(result.headline)"
    }
}

private struct ResultNation: View {
    let nation: Nation
    let score: Int

    var body: some View {
        VStack(spacing: 10) {
            NationToken(nation: nation, size: 72)
            Text(nation.shortCode)
                .font(.headline.weight(.black))
                .foregroundStyle(.white.opacity(0.72))
            Text("\(score)")
                .font(.system(size: 46, weight: .black, design: .rounded))
                .foregroundStyle(.white)
                .monospacedDigit()
        }
        .frame(maxWidth: .infinity)
    }
}

private struct ResultMetric: View {
    let title: String
    let value: String

    var body: some View {
        VStack(spacing: 3) {
            Text(title)
                .font(.caption.weight(.heavy))
                .foregroundStyle(.white.opacity(0.52))
            Text(value)
                .font(.title3.weight(.black))
                .foregroundStyle(.white)
                .monospacedDigit()
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(Color.knPanelAlt, in: RoundedRectangle(cornerRadius: 8))
    }
}

private extension MatchOutcome {
    var title: String {
        switch self {
        case .win: "Victory"
        case .loss: "Close One"
        case .draw: "Draw"
        }
    }
}
