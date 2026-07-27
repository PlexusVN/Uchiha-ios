import SwiftUI

struct CrosshairOverlayView: View {
    let color: Color
    let tier: String
    let offsetX: CGFloat
    let offsetY: CGFloat

    var body: some View {
        GeometryReader { geo in
            let cx = geo.size.width / 2 + offsetX
            let cy = geo.size.height / 2 + offsetY

            Canvas { context, size in
                // Center dot
                let dotSize = 3.0
                context.fill(Path(ellipseIn: CGRect(x: cx - dotSize, y: cy - dotSize, width: dotSize * 2, height: dotSize * 2)), with: .color(color))

                // Crosshair lines
                let lineLen = 22.0
                let gap = 6.0
                let strokeW = 4.0

                var path = Path()
                // Top
                path.move(to: CGPoint(x: cx, y: cy - gap))
                path.addLine(to: CGPoint(x: cx, y: cy - gap - lineLen))
                // Bottom
                path.move(to: CGPoint(x: cx, y: cy + gap))
                path.addLine(to: CGPoint(x: cx, y: cy + gap + lineLen))
                // Left
                path.move(to: CGPoint(x: cx - gap, y: cy))
                path.addLine(to: CGPoint(x: cx - gap - lineLen, y: cy))
                // Right
                path.move(to: CGPoint(x: cx + gap, y: cy))
                path.addLine(to: CGPoint(x: cx + gap + lineLen, y: cy))

                context.stroke(path, with: .color(color), lineWidth: strokeW)

                // Inner circle
                context.stroke(Path(ellipseIn: CGRect(x: cx - 18, y: cy - 18, width: 36, height: 36)),
                              with: .color(color.opacity(0.8)), lineWidth: 2)

                // VIP outer circle
                if tier == "vip" {
                    context.stroke(Path(ellipseIn: CGRect(x: cx - 38, y: cy - 38, width: 76, height: 76)),
                                  with: .color(color.opacity(0.6)), lineWidth: 3)
                }
            }
            .allowsHitTesting(false)
        }
        .background(Color.clear)
        .ignoresSafeArea()
    }
}
