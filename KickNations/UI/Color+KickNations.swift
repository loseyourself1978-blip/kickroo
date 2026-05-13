import SwiftUI

extension Color {
    static let knBackground = Color(hex: "#10131A")
    static let knPanel = Color(hex: "#1A1F2B")
    static let knPanelAlt = Color(hex: "#222A36")
    static let knField = Color(hex: "#105B42")
    static let knGold = Color(hex: "#F2C14E")
    static let knRed = Color(hex: "#F0524F")
    static let knMint = Color(hex: "#17B978")
    static let knBlue = Color(hex: "#2458E6")
    static let knInk = Color(hex: "#F7F8FA")

    init(hex: String) {
        let sanitized = hex.replacingOccurrences(of: "#", with: "")
        var value: UInt64 = 0
        Scanner(string: sanitized).scanHexInt64(&value)

        let red: Double
        let green: Double
        let blue: Double

        if sanitized.count == 6 {
            red = Double((value & 0xFF0000) >> 16) / 255
            green = Double((value & 0x00FF00) >> 8) / 255
            blue = Double(value & 0x0000FF) / 255
        } else {
            red = 1
            green = 1
            blue = 1
        }

        self.init(red: red, green: green, blue: blue)
    }
}
