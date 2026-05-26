import SwiftUI
import UIKit

struct ResultsView: View {
    @EnvironmentObject private var router: AppRouter
    @EnvironmentObject private var persistence: PersistenceService

    let result: MatchResult
    private let shareService = ShareService()

    @State private var selectedPosterContent: SharePosterContent = .match
    @State private var selectedPosterStyle: SharePosterStyle = .stadiumLights
    @State private var shareSheetItems: [Any] = []
    @State private var isShareSheetPresented = false

    var body: some View {
        ZStack {
            Color.knBackground.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 16) {
                    Text(result.outcome.title)
                        .font(.system(size: 38, weight: .black, design: .rounded))
                        .foregroundStyle(result.outcome == .win ? Color.knGold : Color.white)
                        .padding(.top, 8)

                    HStack(spacing: 18) {
                        ResultNation(nation: playerNation, score: result.playerScore)
                        Text("-")
                            .font(.system(size: 36, weight: .black, design: .rounded))
                            .foregroundStyle(.white.opacity(0.42))
                        ResultNation(nation: opponentNation, score: result.opponentScore)
                    }

                    VStack(spacing: 8) {
                        Text(result.headline)
                            .font(.title3.weight(.black))
                            .foregroundStyle(.white)
                            .multilineTextAlignment(.center)

                        HStack(spacing: 12) {
                            ResultMetric(title: "Combo", value: "\(result.maxCombo)")
                            ResultMetric(title: "Style", value: "\(result.chaosScore)")
                            ResultMetric(title: "Coins", value: "+\(result.coinsEarned)")
                        }
                    }
                    .padding(12)
                    .background(Color.knPanel, in: RoundedRectangle(cornerRadius: 8))

                    if !result.configuration.isPractice {
                        cupStatusPanel
                    } else if result.configuration.isPractice {
                        practicePanel
                    }

                    sharePosterPanel

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
                .padding(18)
            }
        }
        .sheet(isPresented: $isShareSheetPresented) {
            ShareSheet(activityItems: shareSheetItems) { completed in
                if completed {
                    AnalyticsService().track(.highlightShared, properties: [
                        "content": selectedPosterContent.rawValue,
                        "style": selectedPosterStyle.rawValue
                    ])
                }
            }
        }
    }

    private var playerNation: Nation {
        NationLibrary.nation(for: result.configuration.playerNationID)
    }

    private var opponentNation: Nation {
        NationLibrary.nation(for: result.configuration.opponentNationID)
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
        .padding(12)
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
        .padding(12)
        .background(Color.knPanelAlt, in: RoundedRectangle(cornerRadius: 8))
    }

    private var sharePosterPanel: some View {
        VStack(spacing: 12) {
            HStack {
                Label("Share Poster", systemImage: "photo.on.rectangle.angled")
                    .font(.headline.weight(.black))
                    .foregroundStyle(Color.knGold)
                Spacer()
                Text("kickroo landing")
                    .font(.caption.weight(.heavy))
                    .foregroundStyle(.white.opacity(0.48))
                    .lineLimit(1)
            }

            HStack(spacing: 12) {
                Image(uiImage: posterPreviewImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 104)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.white.opacity(0.12), lineWidth: 1)
                    )

                VStack(spacing: 8) {
                    Picker("Poster Type", selection: $selectedPosterContent) {
                        ForEach(SharePosterContent.allCases) { content in
                            Text(content.title).tag(content)
                        }
                    }
                    .pickerStyle(.segmented)

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                        ForEach(SharePosterStyle.allCases) { style in
                            ShareStyleButton(
                                style: style,
                                isSelected: selectedPosterStyle == style
                            ) {
                                selectedPosterStyle = style
                            }
                        }
                    }
                }
            }

            Button {
                presentPosterShare()
            } label: {
                Label("Share Poster", systemImage: "square.and.arrow.up")
                    .font(.headline.weight(.bold))
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
            }
            .buttonStyle(.borderedProminent)
            .tint(Color.knGold)
            .foregroundStyle(.black)
        }
        .padding(12)
        .background(Color.knPanel, in: RoundedRectangle(cornerRadius: 8))
    }

    private var posterPreviewImage: UIImage {
        shareService.makeHighlightPoster(
            for: result,
            campaign: router.cupCampaign,
            content: selectedPosterContent,
            style: selectedPosterStyle,
            size: CGSize(width: 360, height: 640)
        )
    }

    private func presentPosterShare() {
        let poster = shareService.makeHighlightPoster(
            for: result,
            campaign: router.cupCampaign,
            content: selectedPosterContent,
            style: selectedPosterStyle
        )
        shareSheetItems = [
            poster,
            shareService.text(for: result, campaign: router.cupCampaign, content: selectedPosterContent),
            shareService.landingURL
        ]
        AnalyticsService().track(.highlightGenerated, properties: [
            "content": selectedPosterContent.rawValue,
            "style": selectedPosterStyle.rawValue
        ])
        isShareSheetPresented = true
    }
}

private struct ResultNation: View {
    let nation: Nation
    let score: Int

    var body: some View {
        VStack(spacing: 10) {
            NationToken(nation: nation, size: 58)
            Text(nation.shortCode)
                .font(.subheadline.weight(.black))
                .foregroundStyle(.white.opacity(0.72))
            Text("\(score)")
                .font(.system(size: 40, weight: .black, design: .rounded))
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
                .font(.headline.weight(.black))
                .foregroundStyle(.white)
                .monospacedDigit()
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(Color.knPanelAlt, in: RoundedRectangle(cornerRadius: 8))
    }
}

private struct ShareStyleButton: View {
    let style: SharePosterStyle
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Label(style.title, systemImage: style.systemImage)
                .font(.caption.weight(.black))
                .lineLimit(1)
                .minimumScaleFactor(0.72)
                .frame(maxWidth: .infinity)
                .frame(height: 34)
        }
        .buttonStyle(.plain)
        .foregroundStyle(isSelected ? .black : .white.opacity(0.82))
        .background(isSelected ? Color.knGold : Color.knPanelAlt, in: RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(isSelected ? Color.white.opacity(0.42) : Color.white.opacity(0.08), lineWidth: 1)
        )
    }
}

private struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    let onComplete: (Bool) -> Void

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        controller.completionWithItemsHandler = { _, completed, _, _ in
            onComplete(completed)
        }
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
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
