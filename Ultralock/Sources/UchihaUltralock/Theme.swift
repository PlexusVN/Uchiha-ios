import SwiftUI

enum CyberTheme {
    // MARK: - Core palette
    static let bgStart  = Color(hex: 0x0B0E1A)
    static let bgEnd    = Color(hex: 0x141929)
    static let bgGradient = LinearGradient(
        colors: [bgStart, bgEnd],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let cyberCardBg     = Color(hex: 0x1A1F33)
    static let cyberCardBorder = Color(hex: 0x2A2F4A).opacity(0.5)
    static let cyberGlow       = Color(hex: 0x6D5DFF)

    static let textPrimary   = Color.white
    static let textSecondary = Color(hex: 0x8890B0)
    static let textAccent    = Color(hex: 0x6D5DFF)

    static let toggleOn  = Color(hex: 0x6D5DFF)
    static let toggleOff = Color(hex: 0x2A2F4A)

    static let tierBasic = Color(hex: 0x4ECDC4)
    static let tierPro   = Color(hex: 0x6D5DFF)
    static let tierVip   = Color(hex: 0xFFA940)

    static let danger   = Color(hex: 0xFF4757)
    static let success  = Color(hex: 0x2ED573)
    static let warning  = Color(hex: 0xFFA940)

    static let gaugeEmpty = Color(hex: 0x2A2F4A)
    static let gaugeFill  = Color(hex: 0x6D5DFF)

    static let blurredBg: some View = {
        if #available(iOS 15.0, *) {
            return AnyView(Color.clear.background(.ultraThinMaterial))
        } else {
            return AnyView(Color.black.opacity(0.6))
        }
    }()
}

extension Color {
    init(hex: UInt32, alpha: Double = 1) {
        self.init(
            .sRGB,
            red:   Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue:  Double(hex & 0xFF) / 255,
            opacity: alpha
        )
    }
}
