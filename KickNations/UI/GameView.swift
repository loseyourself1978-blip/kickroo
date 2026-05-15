import Combine
import SpriteKit
import SwiftUI

struct GameView: View {
    @EnvironmentObject private var router: AppRouter
    @EnvironmentObject private var persistence: PersistenceService
    @StateObject private var viewModel: MatchViewModel
    @AppStorage("kickNations.hasSeenFirstMatchTutorial.v1") private var hasSeenFirstMatchTutorial = false
    @State private var showTutorial = false

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
            .padding(.bottom, 18)

            if showTutorial {
                FirstMatchTutorialOverlay {
                    hasSeenFirstMatchTutorial = true
                    showTutorial = false
                }
            }
        }
        .onAppear(perform: presentTutorialIfNeeded)
        .onReceive(viewModel.$result.compactMap { $0 }) { result in
            if !result.configuration.isPractice {
                persistence.apply(result)
            }
            router.finishMatch(result)
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
                Text(viewModel.snapshot.phaseName)
                    .font(.caption.weight(.heavy))
                    .foregroundStyle(.white.opacity(0.70))
                    .textCase(.uppercase)
                    .lineLimit(1)
                    .minimumScaleFactor(0.56)
                Text("\(viewModel.snapshot.phaseDetail)  C\(viewModel.snapshot.combo)")
                    .font(.caption2.weight(.heavy))
                    .foregroundStyle(viewModel.snapshot.isOvertime ? Color.knGold : Color.white.opacity(0.62))
                    .textCase(.uppercase)
                    .lineLimit(1)
                    .minimumScaleFactor(0.50)
            }
            .frame(width: 118)
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

    private func presentTutorialIfNeeded() {
        let arguments = ProcessInfo.processInfo.arguments
        if arguments.contains("-showTutorial") {
            showTutorial = true
        } else if !hasSeenFirstMatchTutorial && !arguments.contains("-skipTutorial") {
            showTutorial = true
        }
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

private struct FirstMatchTutorialOverlay: View {
    let dismiss: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.72).ignoresSafeArea()

            VStack(spacing: 14) {
                Text("Kickoff Drill")
                    .font(.system(size: 34, weight: .black, design: .rounded))
                    .foregroundStyle(.white)

                TutorialAnimationView()
                    .frame(height: 118)

                VStack(spacing: 8) {
                    TutorialStep(symbolName: "arrow.up.circle.fill", title: "Attack upward", detail: "Your player starts at the bottom and shoots toward the top net.")
                    TutorialStep(symbolName: "gauge.with.dots.needle.67percent", title: "Hold for power", detail: "Press on the field, aim the arrow, then release at full charge.")
                    TutorialStep(symbolName: "soccerball", title: "Hunt lucky rebounds", detail: "Posts, springs, and blockers can send one sharp shot all the way in.")
                    TutorialStep(symbolName: "speaker.wave.3.fill", title: "Use roar waves", detail: "Tap Left, Roar, or Right to push the ball upward and bend it late.")
                }

                Button(action: dismiss) {
                    Label("Kick Off", systemImage: "play.fill")
                        .font(.headline.weight(.black))
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                }
                .buttonStyle(.borderedProminent)
                .tint(Color.knGold)
                .foregroundStyle(.black)
            }
            .padding(18)
            .background(Color.knPanel, in: RoundedRectangle(cornerRadius: 8))
            .overlay {
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.knGold.opacity(0.55), lineWidth: 2)
            }
            .padding(24)
        }
    }
}

private struct TutorialAnimationView: View {
    var body: some View {
        TimelineView(.animation) { timeline in
            GeometryReader { proxy in
                let size = proxy.size
                let phase = (timeline.date.timeIntervalSinceReferenceDate.truncatingRemainder(dividingBy: 2.7)) / 2.7
                let ballPoint = ballPoint(in: size, progress: phase)
                let charge = min(1, max(0, phase / 0.28))

                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.knField)
                        .overlay {
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(.white.opacity(0.16), lineWidth: 1)
                        }

                    Path { path in
                        path.move(to: CGPoint(x: 14, y: size.height * 0.50))
                        path.addLine(to: CGPoint(x: size.width - 14, y: size.height * 0.50))
                        path.addEllipse(in: CGRect(x: size.width * 0.5 - 18, y: size.height * 0.5 - 18, width: 36, height: 36))
                    }
                    .stroke(.white.opacity(0.18), lineWidth: 2)

                    Path { path in
                        let start = CGPoint(x: size.width * 0.50, y: size.height * 0.80)
                        let bank = CGPoint(x: size.width * 0.76, y: size.height * 0.38)
                        let finish = CGPoint(x: size.width * 0.50, y: size.height * 0.14)
                        path.move(to: start)
                        path.addQuadCurve(to: bank, control: CGPoint(x: size.width * 0.66, y: size.height * 0.62))
                        path.addQuadCurve(to: finish, control: CGPoint(x: size.width * 0.84, y: size.height * 0.18))
                    }
                    .trim(from: 0, to: min(1, max(0, (phase - 0.18) / 0.70)))
                    .stroke(Color.knGold.opacity(0.85), style: StrokeStyle(lineWidth: 3, lineCap: .round, dash: [7, 6]))

                    TutorialGoalFrame(isTop: true)
                        .frame(width: size.width * 0.52, height: 30)
                        .position(x: size.width * 0.50, y: 18)

                    TutorialGoalFrame(isTop: false)
                        .frame(width: size.width * 0.52, height: 30)
                        .position(x: size.width * 0.50, y: size.height - 18)

                    Circle()
                        .fill(Color.knBlue)
                        .overlay(Circle().stroke(.white.opacity(0.70), lineWidth: 2))
                        .frame(width: 32, height: 32)
                        .overlay {
                            Text("YOU")
                                .font(.system(size: 8, weight: .black, design: .rounded))
                                .foregroundStyle(.white)
                        }
                        .position(x: size.width * 0.50, y: size.height * 0.82)

                    VStack(spacing: 4) {
                        Image(systemName: "arrow.up")
                            .font(.system(size: 24, weight: .black))
                            .foregroundStyle(Color.knGold)
                            .scaleEffect(1 + charge * 0.30)
                        Capsule()
                            .fill(Color.knGold.opacity(0.25))
                            .frame(width: 46, height: 6)
                            .overlay(alignment: .leading) {
                                Capsule()
                                    .fill(Color.knGold)
                                    .frame(width: 8 + 38 * charge, height: 6)
                            }
                    }
                    .opacity(phase < 0.34 ? 1 : 0.25)
                    .position(x: size.width * 0.50, y: size.height * 0.62)

                    Image(systemName: "sparkles")
                        .font(.system(size: 18, weight: .black))
                        .foregroundStyle(Color.knGold)
                        .opacity(phase > 0.48 && phase < 0.72 ? 1 : 0.25)
                        .position(x: size.width * 0.78, y: size.height * 0.34)

                    Image(systemName: "soccerball")
                        .font(.system(size: 24, weight: .black))
                        .foregroundStyle(.white)
                        .shadow(color: .black.opacity(0.55), radius: 1, x: 1, y: 1)
                        .position(ballPoint)
                }
            }
        }
    }

    private func ballPoint(in size: CGSize, progress: Double) -> CGPoint {
        if progress < 0.24 {
            return CGPoint(x: size.width * 0.50, y: size.height * 0.76)
        }

        let flight = min(1, max(0, (progress - 0.24) / 0.68))
        let start = CGPoint(x: size.width * 0.50, y: size.height * 0.76)
        let bank = CGPoint(x: size.width * 0.78, y: size.height * 0.34)
        let finish = CGPoint(x: size.width * 0.50, y: size.height * 0.13)

        if flight < 0.58 {
            return interpolate(start, bank, CGFloat(flight / 0.58))
        }
        return interpolate(bank, finish, CGFloat((flight - 0.58) / 0.42))
    }

    private func interpolate(_ a: CGPoint, _ b: CGPoint, _ progress: CGFloat) -> CGPoint {
        CGPoint(
            x: a.x + (b.x - a.x) * progress,
            y: a.y + (b.y - a.y) * progress
        )
    }
}

private struct TutorialGoalFrame: View {
    let isTop: Bool

    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color.white.opacity(0.05))
            HStack {
                Capsule()
                    .fill(Color.knGold)
                    .overlay(Capsule().stroke(.white.opacity(0.75), lineWidth: 1))
                    .frame(width: 7)
                Spacer()
                Capsule()
                    .fill(Color.knGold)
                    .overlay(Capsule().stroke(.white.opacity(0.75), lineWidth: 1))
                    .frame(width: 7)
            }
            VStack {
                if !isTop { Spacer() }
                Capsule()
                    .fill(Color.knGold)
                    .overlay(Capsule().stroke(.white.opacity(0.75), lineWidth: 1))
                    .frame(height: 7)
                if isTop { Spacer() }
            }
            Path { path in
                for index in 1..<4 {
                    let x = CGFloat(index) / 4
                    path.move(to: CGPoint(x: x * 180, y: 0))
                    path.addLine(to: CGPoint(x: x * 180, y: 30))
                }
                for index in 1..<3 {
                    let y = CGFloat(index) / 3
                    path.move(to: CGPoint(x: 0, y: y * 30))
                    path.addLine(to: CGPoint(x: 180, y: y * 30))
                }
            }
            .stroke(.white.opacity(0.22), lineWidth: 1)
        }
        .clipShape(RoundedRectangle(cornerRadius: 4))
    }
}

private struct TutorialStep: View {
    let symbolName: String
    let title: String
    let detail: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: symbolName)
                .font(.headline.weight(.black))
                .foregroundStyle(.black)
                .frame(width: 38, height: 38)
                .background(Color.knGold, in: RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline.weight(.black))
                    .foregroundStyle(.white)
                Text(detail)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.62))
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
        }
        .padding(10)
        .background(Color.knPanelAlt, in: RoundedRectangle(cornerRadius: 8))
    }
}
