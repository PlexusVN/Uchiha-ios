import SwiftUI

// MARK: - Uchiha Red-Black Color Palette
extension Color {
    // Backgrounds
    static let cyberBg = Color(red: 0.02, green: 0, blue: 0)
    static let cyberSurface = Color(red: 0.1, green: 0, blue: 0)
    static let cyberCardBg = Color(red: 0.16, green: 0, blue: 0, opacity: 0.56)
    static let cyberDarkBorder = Color(red: 0.29, green: 0, blue: 0)

    // Accents (all red despite misleading names)
    static let cyberCyan = Color.red
    static let cyberCyanGlow = Color.red.opacity(0.2)
    static let cyberIceBlue = Color(red: 1, green: 0.92, blue: 0.92)
    static let cyberGold = Color(red: 0.54, green: 0, blue: 0)
    static let cyberGreen = Color(red: 0.33, green: 0, blue: 0)

    // Text
    static let cyberTextPrimary = Color.white
    static let cyberTextSecondary = Color(red: 0.85, green: 0.61, blue: 0.61)

    // Neon variants
    static let neonPurple = Color(red: 0.54, green: 0, blue: 0)
    static let neonPurpleLight = Color(red: 1, green: 0.25, blue: 0.25)
    static let neonPurpleDark = Color(red: 0.29, green: 0, blue: 0)
    static let neonCyan = Color.red
    static let neonCyanGlow = Color.red.opacity(0.25)
    static let neonMagenta = Color(red: 0.69, green: 0, blue: 0)
    static let neonBlue = Color(red: 0.13, green: 0, blue: 0)
    static let neonGreen = Color.black
    static let neonOrange = Color(red: 0.2, green: 0, blue: 0)
    static let neonRed = Color.red
    static let neonGold = Color(red: 0.33, green: 0, blue: 0)

    // Particle
    static let particlePurple = Color.black.opacity(0.73)
    static let particleCyan = Color.red.opacity(0.73)
    static let particleMagenta = Color(red: 0.54, green: 0, blue: 0).opacity(0.73)
    static let particleWhite = Color(white: 0.13).opacity(0.6)

    // Grid
    static let gridLinePurple = Color.red.opacity(0.09)
    static let gridLineCyan = Color(red: 0.54, green: 0, blue: 0).opacity(0.09)
    static let gridLineBright = Color.red.opacity(0.19)

    // Energy
    static let energyCore = Color.red
    static let energyOuter = Color.red.opacity(0)
    static let energyRing = Color(red: 0.54, green: 0, blue: 0).opacity(0.33)

    // Uchiha specific
    static let uchihaAccent = Color(red: 1, green: 0.13, blue: 0.13)
    static let uchihaBg = Color(red: 0.05, green: 0, blue: 0)
    static let uchihaCard = Color(red: 0.1, green: 0.04, blue: 0.04)
    static let uchihaRed = Color(red: 0.8, green: 0, blue: 0)
}

// MARK: - Font Extensions
extension Font {
    static func uchihaTitle(size: CGFloat = 18) -> Font {
        .system(size: size, weight: .black, design: .monospaced)
    }
    static func uchihaHeading(size: CGFloat = 14) -> Font {
        .system(size: size, weight: .bold, design: .default)
    }
    static func uchihaBody(size: CGFloat = 12) -> Font {
        .system(size: size, weight: .medium, design: .default)
    }
    static func uchihaCaption(size: CGFloat = 9) -> Font {
        .system(size: size, weight: .regular, design: .default)
    }
}

// MARK: - Shape Modifiers
struct UchihaCardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(Color.uchihaCard)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.uchihaRed.opacity(0.3), lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

extension View {
    func uchihaCard() -> some View {
        modifier(UchihaCardStyle())
    }
}
