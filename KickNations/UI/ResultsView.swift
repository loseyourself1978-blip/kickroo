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

                if !result.configuration.isPractice {
                    cupStatusPanel
                } else if result.configuration.isPractice {
                    practicePanel
                }

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

                if result.configuration.isPractice {
                    Button {
                        router.startMatch(mode: .globalCup, nationID: result.configuration.playerNationID)
                    } label: {
                        Label("Start Official Cup", systemImage: "play.fill")
                            .font(.headline.weight(.bold))
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(Color.knGold)
                    .foregroundStyle(.black)
                } else if let campaign = router.cupCampaign {
                    Button {
                        if campaign.canContinue {
                            router.continueGlobalCup()
                        } else {
                            router.showHome()
                        }
                    } label: {
                        Label(campaign.canContinue ? "Continue Cup" : "Cup Complete", systemImage: campaign.canContinue ? "arrow.right.circle.fill" : "checkmark.seal.fill")
                            .font(.headline.weight(.bold))
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(Color.knMint)
                    .foregroundStyle(.black)
                }

                HStack(spacing: 12) {
                    if result.configuration.isPractice {
                        Button {
                            router.startCupPractice(nationID: result.configuration.playerNationID)
                        } label: {
                            Label("Again", systemImage: "arrow.clockwise")
                                .font(.headline.weight(.bold))
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                        }
                        .buttonStyle(.bordered)
                        .tint(.white.opacity(0.35))
                    }

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
        "Kickroo!: \(playerNation.shortCode) \(result.playerScore)-\(result.opponentScore) \(opponentNation.shortCode). Max combo \(result.maxCombo). \(result.headline)"
    }

    private var cupStatusPanel: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Label(result.configuration.cupContext?.stage.displayName ?? "Global Cup", systemImage: "globe.americas.fill")
                    .font(.headline.weight(.black))
                    .foregroundStyle(Color.knGold)
                Spacer()
                if let campaign = router.cupCampaign {
                    Text(campaign.stage.displayName)
                        .font(.caption.weight(.heavy))
                        .foregroundStyle(.white.opacity(0.62))
                        .textCase(.uppercase)
                }
            }

            Text(router.cupCampaign?.lastSummary ?? result.configuration.cupContext?.standingSummary ?? "Cup table updated")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.white.opacity(0.72))
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(14)
        .background(Color.knPanelAlt, in: RoundedRectangle(cornerRadius: 8))
    }

    private var practicePanel: some View {
        VStack(alignment: .leading, spacing: 6) {
            Label("Practice Complete", systemImage: "graduationcap.fill")
                .font(.headline.weight(.black))
                .foregroundStyle(Color.knGold)
            Text("This match did not change your cup table. Start the official run when the aim, power, roar, and rebounds feel good.")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.white.opacity(0.72))
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(14)
        .background(Color.knPanelAlt, in: RoundedRectangle(cornerRadius: 8))
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
