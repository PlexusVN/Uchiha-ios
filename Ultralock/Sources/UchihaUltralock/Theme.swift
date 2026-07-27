import SwiftUI

enum CyberTheme {
    // MARK: - Core palette (Red-Black Uchiha style)
    static let bgStart  = Color(hex: 0x050000)
    static let bgEnd    = Color(hex: 0x1A0000)
    static let bgGradient = LinearGradient(
        colors: [bgStart, bgEnd],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let cyberCardBg     = Color(hex: 0x1A0000)
    static let cyberCardBorder = Color(hex: 0x4A0000).opacity(0.5)
    static let cyberGlow       = Color(hex: 0xFF0000)

    static let textPrimary   = Color.white
    static let textSecondary = Color(hex: 0xD99B9B)
    static let textAccent    = Color(hex: 0xFF0000)

    static let toggleOn  = Color(hex: 0xFF0000)
    static let toggleOff = Color(hex: 0x4A0000)

    static let tierBasic = Color(hex: 0xAA3333)
    static let tierPro   = Color(hex: 0xCC4444)
    static let tierVip   = Color(hex: 0xFF0000)

    static let danger   = Color(hex: 0xFF0000)
    static let success  = Color(hex: 0x00CC66)
    static let warning  = Color(hex: 0xFFAA00)

    static let gaugeEmpty = Color(hex: 0x4A0000)
    static let gaugeFill  = Color(hex: 0xFF0000)

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
