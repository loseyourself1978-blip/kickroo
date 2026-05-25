import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var router: AppRouter
    @EnvironmentObject private var persistence: PersistenceService

    var body: some View {
        ZStack {
            Color.knBackground.ignoresSafeArea()

            VStack(spacing: 16) {
                header
                cupEntry
                progressStrip
                Spacer(minLength: 0)
                footer
            }
            .padding(.horizontal, 18)
            .padding(.top, 24)
            .padding(.bottom, 16)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Kickroo!")
                        .font(.system(size: 42, weight: .black, design: .rounded))
                        .foregroundStyle(Color.knInk)
                    Text("Swipe Soccer Cup")
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(Color.knGold)
                }
                Spacer()
                Button {
                    router.showStore()
                } label: {
                    Image(systemName: "bag.fill")
                        .font(.headline.weight(.bold))
                        .frame(width: 42, height: 42)
                }
                .buttonStyle(.bordered)
                .tint(.white.opacity(0.22))
            }

            HeroCupPanel()
                .frame(height: 190)
        }
    }

    private var cupEntry: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Image(systemName: "globe.americas.fill")
                    .font(.title2.weight(.black))
                    .foregroundStyle(.black)
                    .frame(width: 48, height: 48)
                    .background(Color.knGold, in: RoundedRectangle(cornerRadius: 8))

                VStack(alignment: .leading, spacing: 2) {
                    Text("Kickroo Cup")
                        .font(.title2.weight(.black))
                        .foregroundStyle(.white)
                    Text("48 teams, 12 groups, one trophy run")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.white.opacity(0.58))
                }

                Spacer()
                NationToken(nation: NationLibrary.nation(for: persistence.progress.selectedNationID), size: 46)
            }

            HStack(spacing: 10) {
                Button {
                    router.startCupPractice(nationID: persistence.progress.selectedNationID)
                } label: {
                    Label("Practice First", systemImage: "target")
                        .font(.headline.weight(.black))
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                }
                .buttonStyle(.bordered)
                .tint(Color.knMint)
                .foregroundStyle(.black)

                Button {
                    router.chooseNation(for: .globalCup)
                } label: {
                    Label("Start Cup", systemImage: "play.fill")
                        .font(.headline.weight(.black))
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                }
                .buttonStyle(.borderedProminent)
                .tint(Color.knGold)
                .foregroundStyle(.black)
            }
        }
        .padding(14)
        .background(Color.knPanel, in: RoundedRectangle(cornerRadius: 8))
        .overlay {
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.knGold.opacity(0.20), lineWidth: 1)
        }
    }

    private var progressStrip: some View {
        HStack(spacing: 10) {
            ProgressPill(title: "Coins", value: "\(persistence.progress.coins)", symbolName: "circle.hexagongrid.fill")
            ProgressPill(title: "Matches", value: "\(persistence.progress.matchesCompleted)", symbolName: "flag.checkered")
        }
    }

    private var footer: some View {
        Text("Unofficial arcade football cup game built for the 2026 global soccer season.")
            .font(.caption2.weight(.semibold))
            .foregroundStyle(.white.opacity(0.48))
            .multilineTextAlignment(.center)
            .lineLimit(2)
            .minimumScaleFactor(0.75)
            .frame(maxWidth: .infinity)
            .padding(.horizontal)
    }
}

private struct ModeRow: View {
    let title: String
    let subtitle: String
    let symbolName: String
    let tint: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: symbolName)
                    .font(.title3.weight(.black))
                    .foregroundStyle(.black)
                    .frame(width: 42, height: 42)
                    .background(tint, in: RoundedRectangle(cornerRadius: 8))

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.title3.weight(.black))
                        .foregroundStyle(.white)
                    Text(subtitle)
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.white.opacity(0.56))
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.headline.weight(.black))
                    .foregroundStyle(.white.opacity(0.38))
            }
            .padding(12)
            .background(Color.knPanel, in: RoundedRectangle(cornerRadius: 8))
            .overlay {
                RoundedRectangle(cornerRadius: 8)
                    .stroke(.white.opacity(0.06), lineWidth: 1)
            }
        }
        .buttonStyle(.plain)
    }
}

private struct ProgressPill: View {
    let title: String
    let value: String
    let symbolName: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: symbolName)
                .foregroundStyle(Color.knGold)
            VStack(alignment: .leading, spacing: 1) {
                Text(title)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.white.opacity(0.55))
                Text(value)
                    .font(.headline.weight(.black))
                    .foregroundStyle(.white)
            }
            Spacer(minLength: 0)
        }
        .padding(12)
        .background(Color.knPanelAlt, in: RoundedRectangle(cornerRadius: 8))
    }
}

struct NationToken: View {
    let nation: Nation
    let size: CGFloat

    var body: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [Color(hex: nation.palette.primaryHex), Color(hex: nation.palette.secondaryHex)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            Circle()
                .stroke(Color.white.opacity(0.65), lineWidth: max(2, size * 0.055))
            Rectangle()
                .fill(Color(hex: nation.palette.secondaryHex).opacity(0.85))
                .frame(width: size * 0.74, height: size * 0.15)
                .rotationEffect(.degrees(-12))
                .clipShape(RoundedRectangle(cornerRadius: 3))
            Text(nation.shortCode)
                .font(.system(size: size * 0.24, weight: .black, design: .rounded))
                .foregroundStyle(Color(hex: nation.palette.accentHex))
                .minimumScaleFactor(0.55)
                .lineLimit(1)
        }
        .frame(width: size, height: size)
        .shadow(color: .black.opacity(0.28), radius: 6, y: 4)
    }
}

private struct HeroCupPanel: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.knField)

            FieldLines()
                .stroke(.white.opacity(0.24), lineWidth: 2)
                .padding(12)

            HeroGoalFrame(isTop: true)
                .frame(width: 170, height: 54)
                .position(x: 174, y: 30)

            HeroGoalFrame(isTop: false)
                .frame(width: 170, height: 54)
                .position(x: 174, y: 160)

            HStack(spacing: -8) {
                ForEach(NationLibrary.all.prefix(4)) { nation in
                    NationToken(nation: nation, size: 48)
                }
            }
            .position(x: 104, y: 42)

            Image(systemName: "soccerball")
                .font(.system(size: 34, weight: .black))
                .foregroundStyle(.white)
                .position(x: 226, y: 96)

            VStack(spacing: 2) {
                Circle()
                    .fill(Color(hex: NationLibrary.nation(for: .usa).palette.primaryHex))
                    .overlay(Circle().stroke(.white.opacity(0.65), lineWidth: 2))
                    .frame(width: 34, height: 34)
                Text("YOU")
                    .font(.system(size: 8, weight: .black, design: .rounded))
                    .foregroundStyle(.white.opacity(0.8))
            }
            .position(x: 174, y: 140)
        }
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay {
            RoundedRectangle(cornerRadius: 8)
                .stroke(.white.opacity(0.08), lineWidth: 1)
        }
    }
}

private struct HeroGoalFrame: View {
    let isTop: Bool

    var body: some View {
        ZStack {
            Rectangle()
                .stroke(.white.opacity(0.18), lineWidth: 1)
                .background(Color.white.opacity(0.035))
            HStack {
                Capsule()
                    .fill(Color.knGold)
                    .overlay(Capsule().stroke(.white.opacity(0.75), lineWidth: 1))
                    .frame(width: 8)
                Spacer()
                Capsule()
                    .fill(Color.knGold)
                    .overlay(Capsule().stroke(.white.opacity(0.75), lineWidth: 1))
                    .frame(width: 8)
            }
            VStack {
                if !isTop { Spacer() }
                Capsule()
                    .fill(Color.knGold)
                    .overlay(Capsule().stroke(.white.opacity(0.75), lineWidth: 1))
                    .frame(height: 8)
                if isTop { Spacer() }
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 4))
    }
}

private struct FieldLines: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.addRect(rect.insetBy(dx: 10, dy: 10))
        path.move(to: CGPoint(x: rect.minX + 10, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.maxX - 10, y: rect.midY))
        path.addEllipse(in: CGRect(x: rect.midX - 24, y: rect.midY - 24, width: 48, height: 48))
        return path
    }
}
