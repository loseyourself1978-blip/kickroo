import Combine
import SpriteKit
import SwiftUI

struct GameView: View {
    @EnvironmentObject private var router: AppRouter
    @EnvironmentObject private var persistence: PersistenceService
    @StateObject private var viewModel: MatchViewModel

    init(configuration: MatchConfiguration) {
        _viewModel = StateObject(wrappedValue: MatchViewModel(configuration: configuration))
    }

    var body: some View {
        ZStack {
            SpriteView(scene: viewModel.scene, options: [.ignoresSiblingOrder])
                .ignoresSafeArea()

            VStack(spacing: 0) {
                topHUD
                Spacer()
                skillDock
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 188)
        }
        .onReceive(viewModel.$result.compactMap { $0 }) { result in
            persistence.apply(result)
            router.showResults(result)
        }
    }

    private var topHUD: some View {
        HStack(spacing: 12) {
            ScoreBadge(
                nation: NationLibrary.nation(for: viewModel.configuration.playerNationID),
                score: viewModel.snapshot.playerScore
            )

            VStack(spacing: 3) {
                Text(timeText)
                    .font(.system(size: 28, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                    .monospacedDigit()
                Text("\(viewModel.snapshot.phaseName)  C\(viewModel.snapshot.combo)")
                    .font(.caption.weight(.heavy))
                    .foregroundStyle(viewModel.snapshot.isOvertime ? Color.knGold : Color.white.opacity(0.62))
                    .textCase(.uppercase)
                    .lineLimit(1)
                    .minimumScaleFactor(0.65)
            }
            .frame(width: 92)
            .padding(.vertical, 8)
            .background(.black.opacity(0.24), in: RoundedRectangle(cornerRadius: 8))

            ScoreBadge(
                nation: NationLibrary.nation(for: viewModel.configuration.opponentNationID),
                score: viewModel.snapshot.opponentScore
            )
        }
    }

    private var skillDock: some View {
        VStack(spacing: 8) {
            HStack(spacing: 8) {
                MeterPill(title: "Roar", value: Int(viewModel.snapshot.roarEnergy), color: Color.knGold)
                MeterPill(title: "Heat", value: Int(viewModel.snapshot.roarHeat), color: Color.knRed)
                MeterPill(title: "Max", value: viewModel.snapshot.maxCombo, color: Color.knMint)
            }

            Button {
                viewModel.activateSkill()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "sparkles")
                    Text(playerNation.skill.displayName)
                        .font(.subheadline.weight(.black))
                        .lineLimit(1)
                    Text("\(Int(viewModel.snapshot.skillEnergy))%")
                        .font(.caption.weight(.heavy))
                        .monospacedDigit()
                    Spacer()
                }
                .frame(height: 42)
                .padding(.horizontal, 12)
            }
            .buttonStyle(.borderedProminent)
            .tint(viewModel.snapshot.skillEnergy >= 100 ? Color.knGold : Color.white.opacity(0.18))
            .foregroundStyle(viewModel.snapshot.skillEnergy >= 100 ? .black : .white.opacity(0.55))
            .disabled(viewModel.snapshot.skillEnergy < 100)
        }
        .frame(maxWidth: .infinity)
    }

    private var playerNation: Nation {
        NationLibrary.nation(for: viewModel.configuration.playerNationID)
    }

    private var timeText: String {
        "\(max(0, Int(ceil(viewModel.snapshot.remainingTime))))"
    }
}

private struct MeterPill: View {
    let title: String
    let value: Int
    let color: Color

    var body: some View {
        HStack(spacing: 5) {
            Text(title)
                .font(.caption2.weight(.heavy))
                .foregroundStyle(.white.opacity(0.56))
            Text("\(value)")
                .font(.caption.weight(.black))
                .foregroundStyle(color)
                .monospacedDigit()
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 7)
        .background(.black.opacity(0.30), in: RoundedRectangle(cornerRadius: 8))
    }
}

private struct ScoreBadge: View {
    let nation: Nation
    let score: Int

    var body: some View {
        HStack(spacing: 8) {
            NationToken(nation: nation, size: 36)
            Text("\(score)")
                .font(.system(size: 30, weight: .black, design: .rounded))
                .foregroundStyle(.white)
                .monospacedDigit()
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .padding(.horizontal, 8)
        .background(.black.opacity(0.24), in: RoundedRectangle(cornerRadius: 8))
    }
}
