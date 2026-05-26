import Foundation
import CoreImage
import UIKit

enum SharePosterContent: String, CaseIterable, Identifiable {
    case match
    case cup

    var id: String { rawValue }

    var title: String {
        switch self {
        case .match: "Match"
        case .cup: "Cup"
        }
    }
}

enum SharePosterStyle: String, CaseIterable, Identifiable {
    case stadiumLights
    case trophyGold
    case streetRoar
    case neonBracket

    var id: String { rawValue }

    var title: String {
        switch self {
        case .stadiumLights: "Stadium"
        case .trophyGold: "Final"
        case .streetRoar: "Roar"
        case .neonBracket: "Bracket"
        }
    }

    var systemImage: String {
        switch self {
        case .stadiumLights: "sun.max.fill"
        case .trophyGold: "trophy.fill"
        case .streetRoar: "megaphone.fill"
        case .neonBracket: "tablecells.fill"
        }
    }
}

struct ShareService {
    let landingURL = URL(string: "https://loseyourself1978-blip.github.io/kickroo/")!

    func text(for result: MatchResult, campaign: GlobalCupCampaign? = nil, content: SharePosterContent = .match) -> String {
        let player = NationLibrary.nation(for: result.configuration.playerNationID)
        let opponent = NationLibrary.nation(for: result.configuration.opponentNationID)
        let score = "\(player.shortCode) \(result.playerScore)-\(result.opponentScore) \(opponent.shortCode)"

        switch content {
        case .match:
            return "Kickroo!: \(score). \(result.headline) Get Kickroo! on iPhone: \(landingURL.absoluteString)"
        case .cup:
            return "Kickroo!: \(cupAchievement(for: result, campaign: campaign)). \(score). Get Kickroo! on iPhone: \(landingURL.absoluteString)"
        }
    }

    func makePlaceholderHighlightCard(for result: MatchResult) -> UIImage {
        makeHighlightPoster(for: result, campaign: nil, content: .match, style: .stadiumLights, size: CGSize(width: 720, height: 1280))
    }

    func makeHighlightPoster(
        for result: MatchResult,
        campaign: GlobalCupCampaign?,
        content: SharePosterContent,
        style: SharePosterStyle,
        size: CGSize = CGSize(width: 1080, height: 1920)
    ) -> UIImage {
        let player = NationLibrary.nation(for: result.configuration.playerNationID)
        let opponent = NationLibrary.nation(for: result.configuration.opponentNationID)
        let palette = PosterPalette(style: style)
        let rendererFormat = UIGraphicsImageRendererFormat()
        rendererFormat.scale = 1
        rendererFormat.opaque = true
        let renderer = UIGraphicsImageRenderer(size: size, format: rendererFormat)

        return renderer.image { context in
            let rect = CGRect(origin: .zero, size: size)
            let scale = size.width / 1080
            let cgContext = context.cgContext

            fillGradient(in: rect, colors: [palette.backgroundTop, palette.backgroundBottom], context: cgContext)
            drawBackgroundPattern(style: style, palette: palette, rect: rect, scale: scale, context: cgContext)

            drawText(
                "KICKROO!",
                in: CGRect(x: 70 * scale, y: 92 * scale, width: 470 * scale, height: 82 * scale),
                font: .systemFont(ofSize: 68 * scale, weight: .black),
                color: palette.ink
            )

            drawPill(
                text: content == .match ? "MATCH POSTER" : "GLOBAL CUP 48",
                in: CGRect(x: 70 * scale, y: 184 * scale, width: 335 * scale, height: 48 * scale),
                fill: palette.accent,
                textColor: UIColor(hex: "#10131A"),
                scale: scale
            )

            let title = posterTitle(for: result, campaign: campaign, content: content)
            drawText(
                title,
                in: CGRect(x: 70 * scale, y: 278 * scale, width: 940 * scale, height: 220 * scale),
                font: .systemFont(ofSize: 88 * scale, weight: .black),
                color: palette.ink
            )

            drawScoreboard(
                result: result,
                player: player,
                opponent: opponent,
                palette: palette,
                rect: CGRect(x: 70 * scale, y: 545 * scale, width: 940 * scale, height: 430 * scale),
                scale: scale
            )

            drawStats(
                result: result,
                palette: palette,
                rect: CGRect(x: 70 * scale, y: 1018 * scale, width: 940 * scale, height: 150 * scale),
                scale: scale
            )

            let detail = posterDetail(for: result, campaign: campaign, content: content)
            drawStoryBlock(
                headline: content == .match ? result.headline : cupAchievement(for: result, campaign: campaign),
                detail: detail,
                palette: palette,
                rect: CGRect(x: 70 * scale, y: 1220 * scale, width: 940 * scale, height: 260 * scale),
                scale: scale
            )

            drawQRCodeFooter(
                palette: palette,
                rect: CGRect(x: 70 * scale, y: 1570 * scale, width: 940 * scale, height: 245 * scale),
                scale: scale
            )
        }
    }

    private func posterTitle(for result: MatchResult, campaign: GlobalCupCampaign?, content: SharePosterContent) -> String {
        let player = NationLibrary.nation(for: result.configuration.playerNationID)
        let opponent = NationLibrary.nation(for: result.configuration.opponentNationID)

        switch content {
        case .match:
            return "\(player.shortCode) \(result.playerScore)-\(result.opponentScore) \(opponent.shortCode)"
        case .cup:
            return cupAchievement(for: result, campaign: campaign).uppercased()
        }
    }

    private func posterDetail(for result: MatchResult, campaign: GlobalCupCampaign?, content: SharePosterContent) -> String {
        let player = NationLibrary.nation(for: result.configuration.playerNationID)
        let opponent = NationLibrary.nation(for: result.configuration.opponentNationID)
        let score = "\(player.shortCode) \(result.playerScore)-\(result.opponentScore) \(opponent.shortCode)"

        switch content {
        case .match:
            if result.configuration.isPractice {
                return "Practice First complete. Swipe speed, rebounds, and roar waves are ready for the official run."
            }
            return "\(result.configuration.cupContext?.stage.displayName ?? "Global Cup") result: \(score). \(campaign?.lastSummary ?? result.configuration.cupContext?.standingSummary ?? "Cup table updated")."
        case .cup:
            return "\(score). \(campaign?.lastSummary ?? result.configuration.cupContext?.standingSummary ?? "Cup table updated")."
        }
    }

    private func cupAchievement(for result: MatchResult, campaign: GlobalCupCampaign?) -> String {
        if result.configuration.isPractice {
            return "Practice First Complete"
        }

        guard let campaign else {
            return result.configuration.cupContext?.stage.displayName ?? "Global Cup Result"
        }

        switch campaign.stage {
        case .champion:
            return "Global Cup Champion"
        case .eliminated:
            return campaign.lastSummary
        case .groupStage:
            if let playerRank = campaign.standings.firstIndex(where: { $0.nationID == campaign.playerNationID }) {
                return "Group \(campaign.groupID) Rank \(playerRank + 1)"
            }
            return "Group \(campaign.groupID) Updated"
        case .roundOf32, .roundOf16, .quarterFinal, .semiFinal, .final:
            return campaign.lastSummary
        }
    }

    private func drawBackgroundPattern(
        style: SharePosterStyle,
        palette: PosterPalette,
        rect: CGRect,
        scale: CGFloat,
        context: CGContext
    ) {
        switch style {
        case .stadiumLights:
            drawLightBeam(origin: CGPoint(x: rect.minX + 95 * scale, y: rect.minY), color: UIColor.white.withAlphaComponent(0.22), context: context, scale: scale)
            drawLightBeam(origin: CGPoint(x: rect.maxX - 140 * scale, y: rect.minY + 20 * scale), color: palette.secondary.withAlphaComponent(0.26), context: context, scale: scale)
            drawPitchLines(rect: rect.insetBy(dx: 80 * scale, dy: 390 * scale), color: UIColor.white.withAlphaComponent(0.13), scale: scale)
        case .trophyGold:
            drawDiagonalBands(rect: rect, colors: [palette.accent.withAlphaComponent(0.25), palette.secondary.withAlphaComponent(0.16)], scale: scale)
            drawConfetti(rect: rect, colors: [palette.accent, palette.secondary, UIColor.white], scale: scale)
        case .streetRoar:
            drawSprayBursts(rect: rect, colors: [palette.accent, palette.secondary, UIColor(hex: "#24A0ED")], scale: scale)
            drawDiagonalBands(rect: rect, colors: [UIColor.white.withAlphaComponent(0.12), palette.secondary.withAlphaComponent(0.22)], scale: scale)
        case .neonBracket:
            drawBracketLines(rect: rect, color: palette.accent.withAlphaComponent(0.42), scale: scale)
            drawPitchLines(rect: rect.insetBy(dx: 70 * scale, dy: 430 * scale), color: palette.secondary.withAlphaComponent(0.20), scale: scale)
        }
    }

    private func drawScoreboard(
        result: MatchResult,
        player: Nation,
        opponent: Nation,
        palette: PosterPalette,
        rect: CGRect,
        scale: CGFloat
    ) {
        UIColor(hex: "#07111F").withAlphaComponent(0.62).setFill()
        UIBezierPath(roundedRect: rect, cornerRadius: 34 * scale).fill()

        drawNationToken(nation: player, center: CGPoint(x: rect.minX + 205 * scale, y: rect.minY + 158 * scale), radius: 96 * scale, scale: scale)
        drawNationToken(nation: opponent, center: CGPoint(x: rect.maxX - 205 * scale, y: rect.minY + 158 * scale), radius: 96 * scale, scale: scale)
        drawSoccerBall(center: CGPoint(x: rect.midX, y: rect.minY + 158 * scale), radius: 54 * scale)

        drawText(player.shortCode, in: CGRect(x: rect.minX + 90 * scale, y: rect.minY + 280 * scale, width: 230 * scale, height: 48 * scale), font: .systemFont(ofSize: 36 * scale, weight: .black), color: palette.ink, alignment: .center)
        drawText(opponent.shortCode, in: CGRect(x: rect.maxX - 320 * scale, y: rect.minY + 280 * scale, width: 230 * scale, height: 48 * scale), font: .systemFont(ofSize: 36 * scale, weight: .black), color: palette.ink, alignment: .center)

        drawText("\(result.playerScore)", in: CGRect(x: rect.minX + 92 * scale, y: rect.minY + 315 * scale, width: 230 * scale, height: 94 * scale), font: .systemFont(ofSize: 92 * scale, weight: .black), color: palette.ink, alignment: .center)
        drawText("\(result.opponentScore)", in: CGRect(x: rect.maxX - 322 * scale, y: rect.minY + 315 * scale, width: 230 * scale, height: 94 * scale), font: .systemFont(ofSize: 92 * scale, weight: .black), color: palette.ink, alignment: .center)

        drawText("FINAL", in: CGRect(x: rect.midX - 82 * scale, y: rect.minY + 316 * scale, width: 164 * scale, height: 42 * scale), font: .systemFont(ofSize: 28 * scale, weight: .heavy), color: palette.accent, alignment: .center)
        drawText(outcomeTitle(for: result).uppercased(), in: CGRect(x: rect.midX - 150 * scale, y: rect.minY + 358 * scale, width: 300 * scale, height: 44 * scale), font: .systemFont(ofSize: 30 * scale, weight: .black), color: palette.secondary, alignment: .center)
    }

    private func drawStats(result: MatchResult, palette: PosterPalette, rect: CGRect, scale: CGFloat) {
        let items = [
            ("COMBO", "\(result.maxCombo)"),
            ("STYLE", "\(result.chaosScore)"),
            ("COINS", "+\(result.coinsEarned)")
        ]
        let gap = 18 * scale
        let itemWidth = (rect.width - gap * 2) / 3

        for (index, item) in items.enumerated() {
            let itemRect = CGRect(x: rect.minX + CGFloat(index) * (itemWidth + gap), y: rect.minY, width: itemWidth, height: rect.height)
            UIColor(hex: "#FFFFFF").withAlphaComponent(0.11).setFill()
            UIBezierPath(roundedRect: itemRect, cornerRadius: 22 * scale).fill()
            drawText(item.0, in: itemRect.insetBy(dx: 18 * scale, dy: 24 * scale), font: .systemFont(ofSize: 24 * scale, weight: .black), color: palette.ink.withAlphaComponent(0.62), alignment: .center)
            drawText(item.1, in: CGRect(x: itemRect.minX + 18 * scale, y: itemRect.minY + 68 * scale, width: itemRect.width - 36 * scale, height: 60 * scale), font: .systemFont(ofSize: 48 * scale, weight: .black), color: palette.ink, alignment: .center)
        }
    }

    private func drawStoryBlock(headline: String, detail: String, palette: PosterPalette, rect: CGRect, scale: CGFloat) {
        UIColor(hex: "#FFFFFF").withAlphaComponent(0.12).setFill()
        UIBezierPath(roundedRect: rect, cornerRadius: 28 * scale).fill()
        palette.accent.setFill()
        UIBezierPath(roundedRect: CGRect(x: rect.minX, y: rect.minY, width: 12 * scale, height: rect.height), cornerRadius: 6 * scale).fill()

        drawText(headline, in: CGRect(x: rect.minX + 42 * scale, y: rect.minY + 34 * scale, width: rect.width - 84 * scale, height: 74 * scale), font: .systemFont(ofSize: 42 * scale, weight: .black), color: palette.ink)
        drawText(detail, in: CGRect(x: rect.minX + 42 * scale, y: rect.minY + 118 * scale, width: rect.width - 84 * scale, height: 98 * scale), font: .systemFont(ofSize: 30 * scale, weight: .heavy), color: palette.ink.withAlphaComponent(0.72))
    }

    private func drawQRCodeFooter(palette: PosterPalette, rect: CGRect, scale: CGFloat) {
        UIColor(hex: "#07111F").withAlphaComponent(0.72).setFill()
        UIBezierPath(roundedRect: rect, cornerRadius: 30 * scale).fill()

        drawText("SCAN TO GET KICKROO!", in: CGRect(x: rect.minX + 34 * scale, y: rect.minY + 42 * scale, width: 540 * scale, height: 58 * scale), font: .systemFont(ofSize: 42 * scale, weight: .black), color: palette.accent)
        drawText("Unofficial arcade soccer for iPhone", in: CGRect(x: rect.minX + 34 * scale, y: rect.minY + 108 * scale, width: 560 * scale, height: 46 * scale), font: .systemFont(ofSize: 28 * scale, weight: .bold), color: palette.ink.withAlphaComponent(0.74))
        drawText(landingURL.host ?? landingURL.absoluteString, in: CGRect(x: rect.minX + 34 * scale, y: rect.minY + 162 * scale, width: 560 * scale, height: 36 * scale), font: .systemFont(ofSize: 22 * scale, weight: .heavy), color: palette.secondary)

        let qrSide = 166 * scale
        let qrContainer = CGRect(x: rect.maxX - qrSide - 38 * scale, y: rect.midY - qrSide / 2, width: qrSide, height: qrSide)
        UIColor.white.setFill()
        UIBezierPath(roundedRect: qrContainer.insetBy(dx: -14 * scale, dy: -14 * scale), cornerRadius: 18 * scale).fill()
        if let qr = makeQRCodeImage(from: landingURL.absoluteString, side: qrSide) {
            UIGraphicsGetCurrentContext()?.interpolationQuality = .none
            qr.draw(in: qrContainer)
        }
    }

    private func drawNationToken(nation: Nation, center: CGPoint, radius: CGFloat, scale: CGFloat) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        context.saveGState()
        defer { context.restoreGState() }

        let rect = CGRect(x: center.x - radius, y: center.y - radius, width: radius * 2, height: radius * 2)
        let path = UIBezierPath(ovalIn: rect)
        path.addClip()
        fillGradient(in: rect, colors: [UIColor(hex: nation.palette.primaryHex), UIColor(hex: nation.palette.secondaryHex)], context: context)
        UIColor.white.withAlphaComponent(0.72).setStroke()
        path.lineWidth = max(4 * scale, radius * 0.08)
        path.stroke()

        UIColor(hex: nation.palette.secondaryHex).withAlphaComponent(0.86).setFill()
        let sash = UIBezierPath(roundedRect: CGRect(x: rect.minX + radius * 0.28, y: rect.midY - radius * 0.12, width: radius * 1.44, height: radius * 0.24), cornerRadius: 8 * scale)
        sash.apply(CGAffineTransform(translationX: -center.x, y: -center.y))
        sash.apply(CGAffineTransform(rotationAngle: -0.18))
        sash.apply(CGAffineTransform(translationX: center.x, y: center.y))
        sash.fill()

        drawText(nation.shortCode, in: rect.insetBy(dx: radius * 0.26, dy: radius * 0.63), font: .systemFont(ofSize: radius * 0.42, weight: .black), color: UIColor(hex: nation.palette.accentHex), alignment: .center)
    }

    private func drawSoccerBall(center: CGPoint, radius: CGFloat) {
        let rect = CGRect(x: center.x - radius, y: center.y - radius, width: radius * 2, height: radius * 2)
        UIColor(hex: "#F8F5E8").setFill()
        UIBezierPath(ovalIn: rect).fill()
        UIColor(hex: "#10131A").setFill()
        UIBezierPath(ovalIn: rect.insetBy(dx: radius * 0.36, dy: radius * 0.36)).fill()
        for index in 0..<5 {
            let angle = CGFloat(index) * .pi * 2 / 5 - .pi / 2
            let point = CGPoint(x: center.x + cos(angle) * radius * 0.52, y: center.y + sin(angle) * radius * 0.52)
            UIBezierPath(ovalIn: CGRect(x: point.x - radius * 0.15, y: point.y - radius * 0.15, width: radius * 0.3, height: radius * 0.3)).fill()
        }
    }

    private func drawPill(text: String, in rect: CGRect, fill: UIColor, textColor: UIColor, scale: CGFloat) {
        fill.setFill()
        UIBezierPath(roundedRect: rect, cornerRadius: rect.height / 2).fill()
        drawText(text, in: rect.insetBy(dx: 18 * scale, dy: 9 * scale), font: .systemFont(ofSize: 22 * scale, weight: .black), color: textColor, alignment: .center)
    }

    private func drawText(
        _ text: String,
        in rect: CGRect,
        font: UIFont,
        color: UIColor,
        alignment: NSTextAlignment = .left
    ) {
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = alignment
        paragraph.lineBreakMode = .byTruncatingTail
        NSString(string: text).draw(
            with: rect,
            options: [.usesLineFragmentOrigin, .usesFontLeading, .truncatesLastVisibleLine],
            attributes: [
                .font: font,
                .foregroundColor: color,
                .paragraphStyle: paragraph
            ],
            context: nil
        )
    }

    private func fillGradient(in rect: CGRect, colors: [UIColor], context: CGContext) {
        guard let gradient = CGGradient(
            colorsSpace: CGColorSpaceCreateDeviceRGB(),
            colors: colors.map(\.cgColor) as CFArray,
            locations: nil
        ) else { return }
        context.drawLinearGradient(gradient, start: CGPoint(x: rect.minX, y: rect.minY), end: CGPoint(x: rect.maxX, y: rect.maxY), options: [])
    }

    private func drawLightBeam(origin: CGPoint, color: UIColor, context: CGContext, scale: CGFloat) {
        context.saveGState()
        context.setFillColor(color.cgColor)
        let path = UIBezierPath()
        path.move(to: origin)
        path.addLine(to: CGPoint(x: origin.x + 250 * scale, y: origin.y + 900 * scale))
        path.addLine(to: CGPoint(x: origin.x - 170 * scale, y: origin.y + 940 * scale))
        path.close()
        path.fill()
        context.restoreGState()
    }

    private func drawPitchLines(rect: CGRect, color: UIColor, scale: CGFloat) {
        color.setStroke()
        let path = UIBezierPath(roundedRect: rect, cornerRadius: 32 * scale)
        path.lineWidth = 4 * scale
        path.stroke()
        UIBezierPath(ovalIn: CGRect(x: rect.midX - 140 * scale, y: rect.midY - 140 * scale, width: 280 * scale, height: 280 * scale)).stroke()
        let midline = UIBezierPath()
        midline.move(to: CGPoint(x: rect.minX, y: rect.midY))
        midline.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        midline.lineWidth = 3 * scale
        midline.stroke()
    }

    private func drawDiagonalBands(rect: CGRect, colors: [UIColor], scale: CGFloat) {
        for index in 0..<7 {
            colors[index % colors.count].setFill()
            let y = CGFloat(index) * 285 * scale - 210 * scale
            let path = UIBezierPath()
            path.move(to: CGPoint(x: rect.minX - 80 * scale, y: y))
            path.addLine(to: CGPoint(x: rect.maxX, y: y + 220 * scale))
            path.addLine(to: CGPoint(x: rect.maxX, y: y + 310 * scale))
            path.addLine(to: CGPoint(x: rect.minX - 80 * scale, y: y + 90 * scale))
            path.close()
            path.fill()
        }
    }

    private func drawConfetti(rect: CGRect, colors: [UIColor], scale: CGFloat) {
        for index in 0..<46 {
            colors[index % colors.count].withAlphaComponent(0.62).setFill()
            let x = rect.minX + CGFloat((index * 149) % 980) * scale
            let y = rect.minY + CGFloat((index * 257) % 1700) * scale
            UIBezierPath(roundedRect: CGRect(x: x, y: y, width: 34 * scale, height: 10 * scale), cornerRadius: 3 * scale).fill()
        }
    }

    private func drawSprayBursts(rect: CGRect, colors: [UIColor], scale: CGFloat) {
        for index in 0..<18 {
            colors[index % colors.count].withAlphaComponent(0.24).setFill()
            let x = rect.minX + CGFloat((index * 211) % 1000) * scale
            let y = rect.minY + CGFloat((index * 317) % 1780) * scale
            UIBezierPath(ovalIn: CGRect(x: x - 90 * scale, y: y - 90 * scale, width: 180 * scale, height: 180 * scale)).fill()
        }
    }

    private func drawBracketLines(rect: CGRect, color: UIColor, scale: CGFloat) {
        color.setStroke()
        for index in 0..<5 {
            let y = rect.minY + (300 + CGFloat(index) * 270) * scale
            let path = UIBezierPath()
            path.move(to: CGPoint(x: rect.minX + 34 * scale, y: y))
            path.addLine(to: CGPoint(x: rect.minX + 200 * scale, y: y))
            path.addLine(to: CGPoint(x: rect.minX + 200 * scale, y: y + 95 * scale))
            path.addLine(to: CGPoint(x: rect.maxX - 34 * scale, y: y + 95 * scale))
            path.lineWidth = 5 * scale
            path.stroke()
        }
    }

    private func makeQRCodeImage(from string: String, side: CGFloat) -> UIImage? {
        guard let data = string.data(using: .utf8),
              let filter = CIFilter(name: "CIQRCodeGenerator") else { return nil }
        filter.setValue(data, forKey: "inputMessage")
        filter.setValue("M", forKey: "inputCorrectionLevel")
        guard let outputImage = filter.outputImage else { return nil }

        let transform = CGAffineTransform(scaleX: side / outputImage.extent.width, y: side / outputImage.extent.height)
        let scaledImage = outputImage.transformed(by: transform)
        let context = CIContext()
        guard let cgImage = context.createCGImage(scaledImage, from: scaledImage.extent) else { return nil }
        return UIImage(cgImage: cgImage)
    }

    private func outcomeTitle(for result: MatchResult) -> String {
        switch result.outcome {
        case .win: "Victory"
        case .loss: "Close One"
        case .draw: "Draw"
        }
    }
}

private struct PosterPalette {
    let backgroundTop: UIColor
    let backgroundBottom: UIColor
    let accent: UIColor
    let secondary: UIColor
    let ink: UIColor

    init(style: SharePosterStyle) {
        switch style {
        case .stadiumLights:
            backgroundTop = UIColor(hex: "#061A2E")
            backgroundBottom = UIColor(hex: "#0F5B43")
            accent = UIColor(hex: "#F2C14E")
            secondary = UIColor(hex: "#24A0ED")
            ink = UIColor(hex: "#F8F5E8")
        case .trophyGold:
            backgroundTop = UIColor(hex: "#2B0F22")
            backgroundBottom = UIColor(hex: "#090C12")
            accent = UIColor(hex: "#F2C14E")
            secondary = UIColor(hex: "#F0524F")
            ink = UIColor(hex: "#FFF4D6")
        case .streetRoar:
            backgroundTop = UIColor(hex: "#10131A")
            backgroundBottom = UIColor(hex: "#1D2433")
            accent = UIColor(hex: "#17B978")
            secondary = UIColor(hex: "#F0524F")
            ink = UIColor(hex: "#F8F5E8")
        case .neonBracket:
            backgroundTop = UIColor(hex: "#111A3A")
            backgroundBottom = UIColor(hex: "#120B2E")
            accent = UIColor(hex: "#9DE7FF")
            secondary = UIColor(hex: "#F2C14E")
            ink = UIColor(hex: "#F7F8FA")
        }
    }
}
