import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var router: AppRouter
    @EnvironmentObject private var persistence: PersistenceService

    var body: some View {
        ZStack {
            Color.knBackground.ignoresSafeArea()

            VStack(spacing: 16) {
                header
                modeStack
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
                    Text("Kick Nations")
                        .font(.system(size: 42, weight: .black, design: .rounded))
                        .foregroundStyle(Color.knInk)
                    Text("Arcade Soccer Pinball")
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

            HeroPinballPanel()
                .frame(height: 190)
        }
    }

    private var modeStack: some View {
        VStack(spacing: 10) {
            ModeRow(title: "Quick Match", subtitle: "45s bounce battle", symbolName: "bolt.fill", tint: Color.knGold) {
                router.chooseNation(for: .quickKick)
            }
            ModeRow(title: "Daily Rally", subtitle: "Fixed seed challenge", symbolName: "calendar", tint: Color.knMint) {
                router.startMatch(mode: .dailyClash, nationID: persistence.progress.selectedNationID)
            }
            ModeRow(title: "Pinball Rush", subtitle: "First to three goals", symbolName: "circle.grid.cross.fill", tint: Color.knBlue) {
                router.chooseNation(for: .partyMode)
            }
        }
    }

    private var progressStrip: some View {
        HStack(spacing: 10) {
            ProgressPill(title: "Coins", value: "\(persistence.progress.coins)", symbolName: "circle.hexagongrid.fill")
            ProgressPill(title: "Matches", value: "\(persistence.progress.matchesCompleted)", symbolName: "flag.checkered")
        }
    }

    private var footer: some View {
        Text("Original arcade football game. No official tournament affiliation.")
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

private struct HeroPinballPanel: View {
    private let fanColors: [Color] = [.knRed, .knBlue, .knGold, .knMint, .white]

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.knField)

            FieldLines()
                .stroke(.white.opacity(0.24), lineWidth: 2)
                .padding(12)

            ForEach(0..<4) { index in
                Circle()
                    .fill(index.isMultiple(of: 2) ? Color.knGold : .white)
                    .overlay(Circle().stroke(Color.knRed.opacity(0.85), lineWidth: 3))
                    .frame(width: 30, height: 30)
                    .position(x: index < 2 ? 34 : 320, y: index.isMultiple(of: 2) ? 65 : 126)
            }

            HStack(spacing: 7) {
                ForEach(0..<18) { index in
                    Circle()
                        .fill(fanColors[index % fanColors.count])
                        .frame(width: 9, height: 9)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 9)
            .background(.black.opacity(0.22), in: RoundedRectangle(cornerRadius: 8))
            .position(x: 174, y: 164)

            HStack(spacing: -8) {
                ForEach(NationLibrary.all.prefix(4)) { nation in
                    NationToken(nation: nation, size: 48)
                }
            }
            .position(x: 104, y: 42)

            Image(systemName: "soccerball")
                .font(.system(size: 34, weight: .black))
                .foregroundStyle(.white)
                .position(x: 230, y: 96)
        }
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay {
            RoundedRectangle(cornerRadius: 8)
                .stroke(.white.opacity(0.08), lineWidth: 1)
        }
    }
}

private struct FieldLines: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.addRect(rect.insetBy(dx: 10, dy: 10))
        path.move(to: CGPoint(x: rect.midX, y: rect.minY + 10))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY - 10))
        path.addEllipse(in: CGRect(x: rect.midX - 24, y: rect.midY - 24, width: 48, height: 48))
        return path
    }
}

