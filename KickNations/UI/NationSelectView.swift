import SwiftUI

struct NationSelectView: View {
    @EnvironmentObject private var router: AppRouter
    @EnvironmentObject private var persistence: PersistenceService
    @State private var selectedNationID: NationID

    let mode: GameMode
    private let columns = [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]

    init(mode: GameMode) {
        self.mode = mode
        _selectedNationID = State(initialValue: .usa)
    }

    var body: some View {
        ZStack {
            Color.knBackground.ignoresSafeArea()

            VStack(spacing: 18) {
                HStack {
                    Button {
                        router.showHome()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.headline.weight(.bold))
                            .frame(width: 42, height: 42)
                    }
                    .buttonStyle(.bordered)
                    .tint(.white.opacity(0.2))

                    VStack(alignment: .leading, spacing: 2) {
                        Text(mode.displayName)
                            .font(.title.weight(.black))
                        Text(selectedNation.skill.displayName)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.white.opacity(0.62))
                    }
                    Spacer()
                }
                .foregroundStyle(.white)

                ScrollView(showsIndicators: false) {
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(NationLibrary.all) { nation in
                            NationCard(
                                nation: nation,
                                isSelected: nation.id == selectedNationID,
                                isUnlocked: persistence.progress.unlockedNationIDs.contains(nation.id)
                            ) {
                                selectedNationID = nation.id
                            }
                        }
                    }
                    .padding(.bottom, 8)
                }

                selectedSummary

                Button {
                    persistence.selectNation(selectedNationID)
                    router.startMatch(mode: mode, nationID: selectedNationID)
                } label: {
                    Label(startTitle, systemImage: "play.fill")
                        .font(.headline.weight(.bold))
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                }
                .buttonStyle(.borderedProminent)
                .tint(Color.knGold)
                .foregroundStyle(.black)
            }
            .padding(20)
        }
        .onAppear {
            selectedNationID = persistence.progress.selectedNationID
        }
    }

    private var selectedNation: Nation {
        NationLibrary.nation(for: selectedNationID)
    }

    private var startTitle: String {
        "Start Cup"
    }

    private var selectedSummary: some View {
        HStack(spacing: 12) {
            NationToken(nation: selectedNation, size: 54)

            VStack(alignment: .leading, spacing: 5) {
                Text(mode == .globalCup ? "Global Cup 48" : selectedNation.homeArena.displayName)
                    .font(.headline.weight(.bold))
                    .foregroundStyle(.white)
                Text(mode == .globalCup ? "48 teams, 12 groups, knockout bracket" : selectedNation.skill.shortEffect)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.knGold)
            }

            Spacer()
        }
        .padding(14)
        .background(Color.knPanel, in: RoundedRectangle(cornerRadius: 8))
    }
}

private struct NationCard: View {
    let nation: Nation
    let isSelected: Bool
    let isUnlocked: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    NationToken(nation: nation, size: 46)
                    Spacer()
                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        .foregroundStyle(isSelected ? Color.knGold : Color.white.opacity(0.28))
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(nation.displayName)
                        .font(.headline.weight(.black))
                        .foregroundStyle(.white)
                    Text(nation.skill.displayName)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.58))
                }

                VStack(spacing: 7) {
                    StatBar(label: "SPD", value: nation.baseStats.speed)
                    StatBar(label: "PWR", value: nation.baseStats.power)
                    StatBar(label: "CTL", value: nation.baseStats.control)
                    StatBar(label: "FUN", value: nation.baseStats.chaos)
                }
            }
            .padding(12)
            .frame(maxWidth: .infinity, minHeight: 182, alignment: .topLeading)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isUnlocked ? Color.knPanel : Color.knPanel.opacity(0.55))
            )
            .overlay {
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isSelected ? Color.knGold : .white.opacity(0.08), lineWidth: isSelected ? 2 : 1)
            }
        }
        .buttonStyle(.plain)
    }
}

private struct StatBar: View {
    let label: String
    let value: Double

    var body: some View {
        HStack(spacing: 6) {
            Text(label)
                .font(.system(size: 9, weight: .heavy, design: .rounded))
                .foregroundStyle(.white.opacity(0.48))
                .frame(width: 24, alignment: .leading)
            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule().fill(.white.opacity(0.12))
                    Capsule()
                        .fill(Color.knGold)
                        .frame(width: proxy.size.width * max(0.08, min(1, value)))
                }
            }
            .frame(height: 6)
        }
    }
}
