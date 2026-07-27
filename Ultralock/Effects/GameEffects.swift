import SwiftUI

// MARK: - Perspective Grid 3D
struct PerspectiveGrid3D: View {
    let color: Color
    let lineCount: Int

    var body: some View {
        Canvas { context, size in
            let cx = size.width / 2
            let cy = size.height / 2
            let maxDist = sqrt(cx * cx + cy * cy)

            // Horizontal lines (perspective)
            for i in 0..<lineCount {
                let t = CGFloat(i) / CGFloat(lineCount)
                let y = cy + (t * cy * 0.8)
                if y <= size.height {
                    var path = Path()
                    path.move(to: CGPoint(x: 0, y: y))
                    path.addLine(to: CGPoint(x: size.width, y: y))
                    let alpha = (1 - t) * 0.5
                    context.stroke(path, with: .color(color.opacity(alpha)), lineWidth: 0.5)
                }
            }

            // Vertical lines (perspective)
            for i in 0..<lineCount * 2 {
                let t = CGFloat(i) / CGFloat(lineCount * 2) - 0.5
                let x = cx + t * size.width * 0.8
                if x >= 0 && x <= size.width {
                    var path = Path()
                    path.move(to: CGPoint(x: x, y: 0))
                    path.addLine(to: CGPoint(x: x, y: size.height))
                    let alpha = (1 - abs(t) * 1.5) * 0.3
                    context.stroke(path, with: .color(color.opacity(max(alpha, 0))), lineWidth: 0.5)
                }
            }

            // Center glow
            let centerGlow = RadialGradient(colors: [
                color.opacity(0.15), color.opacity(0.05), .clear
            ], center: .center, startRadius: 0, endRadius: 80)
            context.fill(Path(ellipseIn: CGRect(x: cx - 80, y: cy - 80, width: 160, height: 160)),
                        with: .linearGradient(centerGlow, startPoint: .top, endPoint: .bottom))
        }
    }
}

// MARK: - Rotating Hex Core
struct RotatingHexCore: View {
    @State private var rotation: Double = 0
    let color: Color = .uchihaAccent

    var body: some View {
        Canvas { context, size in
            let cx = size.width / 2
            let cy = size.height / 2
            let outerR = min(size.width, size.height) / 2

            // Outer hex
            var outerHex = Path()
            for i in 0..<6 {
                let angle = CGFloat(i) * .pi / 3 - .pi / 6
                let px = cx + outerR * cos(angle)
                let py = cy + outerR * sin(angle)
                if i == 0 { outerHex.move(to: CGPoint(x: px, y: py)) }
                else { outerHex.addLine(to: CGPoint(x: px, y: py)) }
            }
            outerHex.closeSubpath()
            context.stroke(outerHex, with: .color(color.opacity(0.4)), lineWidth: 2)

            // Inner hex (rotated)
            let innerR = outerR * 0.6
            var innerHex = Path()
            for i in 0..<6 {
                let angle = CGFloat(i) * .pi / 3 + rotation
                let px = cx + innerR * cos(angle)
                let py = cy + innerR * sin(angle)
                if i == 0 { innerHex.move(to: CGPoint(x: px, y: py)) }
                else { innerHex.addLine(to: CGPoint(x: px, y: py)) }
            }
            innerHex.closeSubpath()
            context.stroke(innerHex, with: .color(color.opacity(0.6)), lineWidth: 1.5)

            // Center glow
            context.fill(Path(ellipseIn: CGRect(x: cx - 4, y: cy - 4, width: 8, height: 8)),
                        with: .color(color))
        }
        .onAppear {
            withAnimation(.linear(duration: 12).repeatForever(autoreverses: false)) {
                rotation = .pi * 2
            }
        }
    }
}

// MARK: - Energy Rings
struct EnergyRings: View {
    @State private var phase: CGFloat = 0
    let ringCount = 4

    var body: some View {
        Canvas { context, size in
            let cx = size.width / 2
            let cy = size.height / 2
            let maxR = min(size.width, size.height) / 2

            for i in 0..<ringCount {
                let t = CGFloat(i) / CGFloat(ringCount)
                let baseR = maxR * (0.2 + t * 0.6)
                let r = baseR + sin(phase * 3 - t * .pi * 2) * 10
                let alpha = 0.3 - t * 0.25
                context.stroke(
                    Path(ellipseIn: CGRect(x: cx - r, y: cy - r, width: r * 2, height: r * 2)),
                    with: .color(Color.uchihaAccent.opacity(max(alpha, 0.05))),
                    lineWidth: 1.5
                )
            }
        }
        .onAppear {
            withAnimation(.linear(duration: 4).repeatForever(autoreverses: false)) {
                phase = .pi * 2
            }
        }
    }
}

// MARK: - Hexagonal Grid Overlay
struct HexagonalGridOverlay: View {
    @State private var pulse: CGFloat = 0

    var body: some View {
        Canvas { context, size in
            let hexSize: CGFloat = 30
            let w = hexSize * 1.5
            let h = hexSize * sqrt(3)
            let cols = Int(size.width / w) + 2
            let rows = Int(size.height / h) + 2

            for row in 0..<rows {
                for col in 0..<cols {
                    let offsetX = (row % 2 == 0) ? 0 : w / 2
                    let cx = CGFloat(col) * w + offsetX
                    let cy = CGFloat(row) * h + h / 2
                    let dist = sqrt(pow(cx - size.width / 2, 2) + pow(cy - size.height / 2, 2))
                    let alpha = max(0, 0.15 - dist / (size.width * 1.5))
                    let scale = 0.6 + (sin(pulse * 2 + dist * 0.05) * 0.5 + 0.5) * 0.4

                    var hex = Path()
                    for i in 0..<6 {
                        let angle = CGFloat(i) * .pi / 3 - .pi / 6
                        let px = cx + hexSize * scale * cos(angle)
                        let py = cy + hexSize * scale * sin(angle)
                        if i == 0 { hex.move(to: CGPoint(x: px, y: py)) }
                        else { hex.addLine(to: CGPoint(x: px, y: py)) }
                    }
                    hex.closeSubpath()
                    context.stroke(hex, with: .color(Color.uchihaAccent.opacity(alpha)), lineWidth: 0.5)
                }
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 3).repeatForever()) {
                pulse = 1
            }
        }
    }
}

// MARK: - Scan Line Effect
struct ScanLineEffect: View {
    @State private var scanPos: CGFloat = 0

    var body: some View {
        Canvas { context, size in
            // Scan line
            let y = scanPos * size.height
            var line = Path()
            line.move(to: CGPoint(x: 0, y: y))
            line.addLine(to: CGPoint(x: size.width, y: y))
            context.stroke(line, with: .color(Color.uchihaAccent.opacity(0.15)), lineWidth: 2)

            // Glow
            let glowRect = CGRect(x: 0, y: y - 20, width: size.width, height: 40)
            context.fill(Path(glowRect),
                        with: .linearGradient(
                            Gradient(colors: [.clear, Color.uchihaAccent.opacity(0.05), .clear]),
                            startPoint: .top, endPoint: .bottom
                        ))
        }
        .onAppear {
            withAnimation(.linear(duration: 4).repeatForever(autoreverses: false)) {
                scanPos = 1
            }
        }
    }
}

// MARK: - Floating Particles
struct FloatingParticleField: View {
    @State private var particles: [Particle] = []
    let count: Int

    struct Particle {
        var x: CGFloat; var y: CGFloat
        var radius: CGFloat; var alpha: CGFloat
        var speedY: CGFloat; var speedX: CGFloat
        var color: Color
    }

    var body: some View {
        Canvas { context, size in
            for p in particles {
                let dot = Path(ellipseIn: CGRect(x: p.x - p.radius, y: p.y - p.radius,
                                                  width: p.radius * 2, height: p.radius * 2))
                context.fill(dot, with: .color(p.color.opacity(p.alpha)))
            }
        }
        .onAppear { initParticles(size: CGSize(width: 300, height: 500)) }
        .onReceive(Timer.publish(every: 0.032, on: .main, in: .common).autoconnect()) { _ in
            updateParticles()
        }
    }

    private func initParticles(size: CGSize) {
        particles = (0..<count).map { _ in
            Particle(
                x: CGFloat.random(in: 0...size.width),
                y: CGFloat.random(in: 0...size.height),
                radius: CGFloat.random(in: 1...3),
                alpha: CGFloat.random(in: 0.1...0.5),
                speedY: CGFloat.random(in: -0.5...(-0.1)),
                speedX: CGFloat.random(in: -0.2...0.2),
                color: [Color.uchihaAccent, Color.uchihaRed, Color.white.opacity(0.5)].randomElement()!
            )
        }
    }

    private func updateParticles() {
        for i in particles.indices {
            particles[i].y += particles[i].speedY
            particles[i].x += particles[i].speedX
            if particles[i].y < -10 { particles[i].y = 500 }
            if particles[i].x < -10 { particles[i].x = 310 }
            if particles[i].x > 310 { particles[i].x = -10 }
        }
    }
}

// MARK: - Vignette Overlay
struct VignetteOverlay: View {
    var body: some View {
        Rectangle()
            .fill(
                RadialGradient(colors: [.clear, .black.opacity(0.6)],
                              center: .center, startRadius: 100, endRadius: 400)
            )
            .allowsHitTesting(false)
    }
}

// MARK: - Corner Brackets
struct CornerBrackets: View {
    var body: some View {
        Canvas { context, size in
            let len: CGFloat = 30
            let gap: CGFloat = 4
            let color = Color.uchihaAccent.opacity(0.3)

            // Top-left
            var tl = Path()
            tl.move(to: CGPoint(x: gap, y: gap + len))
            tl.addLine(to: CGPoint(x: gap, y: gap))
            tl.addLine(to: CGPoint(x: gap + len, y: gap))
            context.stroke(tl, with: .color(color), lineWidth: 2)

            // Top-right
            var tr = Path()
            tr.move(to: CGPoint(x: size.width - gap - len, y: gap))
            tr.addLine(to: CGPoint(x: size.width - gap, y: gap))
            tr.addLine(to: CGPoint(x: size.width - gap, y: gap + len))
            context.stroke(tr, with: .color(color), lineWidth: 2)

            // Bottom-left
            var bl = Path()
            bl.move(to: CGPoint(x: gap, y: size.height - gap - len))
            bl.addLine(to: CGPoint(x: gap, y: size.height - gap))
            bl.addLine(to: CGPoint(x: gap + len, y: size.height - gap))
            context.stroke(bl, with: .color(color), lineWidth: 2)

            // Bottom-right
            var br = Path()
            br.move(to: CGPoint(x: size.width - gap - len, y: size.height - gap))
            br.addLine(to: CGPoint(x: size.width - gap, y: size.height - gap))
            br.addLine(to: CGPoint(x: size.width - gap, y: size.height - gap - len))
            context.stroke(br, with: .color(color), lineWidth: 2)
        }
        .allowsHitTesting(false)
    }
}

// MARK: - Sharingan Overlay
struct SharinganOverlay: View {
    @State private var rotation: Double = 0
    @State private var pulse: CGFloat = 1

    var body: some View {
        Canvas { context, size in
            let cx = size.width / 2
            let cy = size.height / 2
            let outerR = min(size.width, size.height) * 0.35 * pulse

            // Outer ring
            context.stroke(
                Path(ellipseIn: CGRect(x: cx - outerR, y: cy - outerR, width: outerR * 2, height: outerR * 2)),
                with: .color(Color.red.opacity(0.6)), lineWidth: 3
            )

            // Inner ring
            let innerR = outerR * 0.6
            context.stroke(
                Path(ellipseIn: CGRect(x: cx - innerR, y: cy - innerR, width: innerR * 2, height: innerR * 2)),
                with: .color(Color.red.opacity(0.4)), lineWidth: 1.5
            )

            // Center dot
            context.fill(Path(ellipseIn: CGRect(x: cx - 4, y: cy - 4, width: 8, height: 8)),
                        with: .color(Color.red))

            // Tomoe (3)
            for i in 0..<3 {
                let angle = CGFloat(i) * .pi * 2 / 3 + rotation
                let dist = outerR * 0.5
                let tx = cx + dist * cos(angle)
                let ty = cy + dist * sin(angle)
                let tomoeR = outerR * 0.15

                context.fill(
                    Path(ellipseIn: CGRect(x: tx - tomoeR, y: ty - tomoeR, width: tomoeR * 2, height: tomoeR * 2)),
                    with: .color(Color.red.opacity(0.8))
                )

                // Tail
                var tail = Path()
                let tailAngle = angle + .pi / 3
                let tailLen = tomoeR * 1.5
                tail.move(to: CGPoint(x: tx, y: ty))
                tail.addLine(to: CGPoint(x: tx + tailLen * cos(tailAngle), y: ty + tailLen * sin(tailAngle)))
                context.stroke(tail, with: .color(Color.red.opacity(0.6)), lineWidth: 2)
            }
        }
        .onAppear {
            withAnimation(.linear(duration: 8).repeatForever(autoreverses: false)) {
                rotation = .pi * 2
            }
            withAnimation(.easeInOut(duration: 2).repeatForever()) {
                pulse = 1.05
            }
        }
    }
}

// MARK: - Crow Feather Fall
struct CrowFeatherFall: View {
    struct Feather {
        var x: CGFloat; var y: CGFloat
        var speedY: CGFloat; var speedX: CGFloat
        var size: CGFloat; var rotation: Double
        var rotSpeed: Double
    }

    @State private var feathers: [Feather] = []
    @State private var timer: Timer?

    var body: some View {
        Canvas { context, size in
            for f in feathers {
                context.translateBy(x: f.x, y: f.y)
                context.rotate(by: Angle(radians: f.rotation))
                let featherSize = f.size
                var path = Path()
                path.move(to: CGPoint(x: -featherSize, y: 0))
                path.addCurve(to: CGPoint(x: 0, y: -featherSize * 0.5),
                              control1: CGPoint(x: -featherSize * 0.5, y: -featherSize * 0.2),
                              control2: CGPoint(x: -featherSize * 0.3, y: -featherSize * 0.6))
                path.addCurve(to: CGPoint(x: featherSize, y: 0),
                              control1: CGPoint(x: featherSize * 0.3, y: -featherSize * 0.6),
                              control2: CGPoint(x: featherSize * 0.5, y: -featherSize * 0.2))
                path.addCurve(to: CGPoint(x: -featherSize, y: 0),
                              control1: CGPoint(x: featherSize * 0.3, y: featherSize * 0.2),
                              control2: CGPoint(x: -featherSize * 0.3, y: featherSize * 0.2))
                context.fill(path, with: .color(Color.black.opacity(0.6)))
                context.translateBy(x: -f.x, y: -f.y)
            }
        }
        .onAppear { initFeathers() }
    }

    private func initFeathers() {
        feathers = (0..<15).map { _ in
            Feather(
                x: CGFloat.random(in: -50...400),
                y: CGFloat.random(in: -200...0),
                speedY: CGFloat.random(in: 0.5...1.5),
                speedX: CGFloat.random(in: -0.3...0.3),
                size: CGFloat.random(in: 8...16),
                rotation: Double.random(in: 0...360),
                rotSpeed: Double.random(in: -2...2)
            )
        }
        timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
            for i in feathers.indices {
                feathers[i].y += feathers[i].speedY
                feathers[i].x += feathers[i].speedX + sin(feathers[i].y * 0.05) * 0.3
                feathers[i].rotation += feathers[i].rotSpeed * 0.05
                if feathers[i].y > 400 { feathers[i].y = -20; feathers[i].x = CGFloat.random(in: -50...400) }
            }
        }
    }
}

// MARK: - Akatsuki Red Moon
struct AkatsukiRedMoon: View {
    @State private var pulse: CGFloat = 1

    var body: some View {
        Canvas { context, size in
            let moonR: CGFloat = 40 * pulse
            let cx: CGFloat = size.width - 60
            let cy: CGFloat = 50

            // Moon glow
            let glow = RadialGradient(colors: [
                Color.red.opacity(0.3), Color.red.opacity(0.1), .clear
            ], center: .init(x: 0.5, y: 0.5), startRadius: 0, endRadius: moonR * 2)
            context.fill(Path(ellipseIn: CGRect(x: cx - moonR * 2, y: cy - moonR * 2,
                                                  width: moonR * 4, height: moonR * 4)),
                        with: .linearGradient(glow, startPoint: .top, endPoint: .bottom))

            // Moon
            context.fill(
                Path(ellipseIn: CGRect(x: cx - moonR, y: cy - moonR, width: moonR * 2, height: moonR * 2)),
                with: .color(Color.red.opacity(0.7))
            )
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 3).repeatForever()) {
                pulse = 1.03
            }
        }
    }
}

// MARK: - Matrix Rain
struct MatrixRain: View {
    struct Drop {
        var x: CGFloat; var y: CGFloat; var speed: CGFloat; var length: Int
        var chars: [String]
    }

    @State private var drops: [Drop] = []

    var body: some View {
        Canvas { context, size in
            for drop in drops {
                for i in 0..<drop.length {
                    let cy = drop.y - CGFloat(i) * 12
                    let alpha = 1 - CGFloat(i) / CGFloat(drop.length)
                    let color = Color.uchihaAccent.opacity(Double(alpha) * 0.3)
                    let char = drop.chars[safe: i] ?? "0"
                    let text = Text(char).font(.system(size: 10, weight: .light)).foregroundColor(color)
                    context.draw(text, at: CGPoint(x: drop.x, y: cy))
                }
            }
        }
        .onAppear { initDrops() }
        .onReceive(Timer.publish(every: 0.05, on: .main, in: .common).autoconnect()) { _ in
            updateDrops()
        }
    }

    private func initDrops() {
        let chars = "01アイウエオカキクケコサシスセソタチツテトナニヌネノハヒフヘホマミムメモヤユヨラリルレロワヲン"
        drops = (0..<20).map { _ in
            Drop(
                x: CGFloat.random(in: 0...400),
                y: CGFloat.random(in: -200...0),
                speed: CGFloat.random(in: 2...6),
                length: Int.random(in: 5...15),
                chars: (0..<15).map { _ in String(chars.randomElement()!) }
            )
        }
    }

    private func updateDrops() {
        for i in drops.indices {
            drops[i].y += drops[i].speed
            if drops[i].y > 500 {
                drops[i].y = -CGFloat(drops[i].length) * 12
                drops[i].x = CGFloat.random(in: 0...400)
            }
        }
    }
}

// MARK: - Holographic Grid
struct HolographicGrid: View {
    @State private var wave: CGFloat = 0

    var body: some View {
        Canvas { context, size in
            let spacing: CGFloat = 40
            for x in stride(from: 0, through: size.width, by: spacing) {
                var path = Path()
                path.move(to: CGPoint(x: x, y: 0))
                for y in stride(from: 0, through: size.height, by: 5) {
                    let offset = sin((y * 0.02) + wave) * 5
                    path.addLine(to: CGPoint(x: x + offset, y: y))
                }
                context.stroke(path, with: .color(Color.uchihaAccent.opacity(0.06)), lineWidth: 0.5)
            }
            for y in stride(from: 0, through: size.height, by: spacing) {
                var path = Path()
                path.move(to: CGPoint(x: 0, y: y))
                for x in stride(from: 0, through: size.width, by: 5) {
                    let offset = sin((x * 0.02) + wave) * 5
                    path.addLine(to: CGPoint(x: x, y: y + offset))
                }
                context.stroke(path, with: .color(Color.uchihaAccent.opacity(0.06)), lineWidth: 0.5)
            }
        }
        .onAppear {
            withAnimation(.linear(duration: 3).repeatForever(autoreverses: false)) {
                wave = .pi * 4
            }
        }
    }
}

// MARK: - Cyber Data Stream
struct CyberDataStream: View {
    struct StreamLine {
        var x: CGFloat; var speed: CGFloat; var offset: CGFloat; var length: CGFloat
    }

    @State private var streams: [StreamLine] = []

    var body: some View {
        Canvas { context, size in
            for s in streams {
                let startY = s.offset
                let endY = startY + s.length
                var path = Path()
                path.move(to: CGPoint(x: s.x, y: startY))
                path.addLine(to: CGPoint(x: s.x, y: endY))
                context.stroke(path, with: .color(Color.uchihaAccent.opacity(0.08)), lineWidth: 1)

                // Bright head
                context.fill(
                    Path(ellipseIn: CGRect(x: s.x - 2, y: startY - 1, width: 4, height: 2)),
                    with: .color(Color.uchihaAccent.opacity(0.2))
                )
            }
        }
        .onAppear {
            streams = (0..<15).map { _ in
                StreamLine(x: CGFloat.random(in: 0...400), speed: CGFloat.random(in: 1...3),
                          offset: CGFloat.random(in: 0...500), length: CGFloat.random(in: 20...80))
            }
        }
        .onReceive(Timer.publish(every: 0.05, on: .main, in: .common).autoconnect()) { _ in
            for i in streams.indices {
                streams[i].offset -= streams[i].speed
                streams[i].offset = streams[i].offset.truncatingRemainder(dividingBy: 500)
                if streams[i].offset < 0 { streams[i].offset += 500 }
            }
        }
    }
}

// MARK: - Cyber Hex Ring
struct CyberHexRing: View {
    @State private var rotation: Double = 0

    var body: some View {
        Canvas { context, size in
            let cx = size.width / 2
            let cy = size.height / 2
            let r = min(size.width, size.height) * 0.35

            // Outer (CW)
            var outer = Path()
            for i in 0..<6 {
                let angle = CGFloat(i) * .pi / 3 + rotation
                let px = cx + r * cos(angle)
                let py = cy + r * sin(angle)
                if i == 0 { outer.move(to: CGPoint(x: px, y: py)) }
                else { outer.addLine(to: CGPoint(x: px, y: py)) }
            }
            outer.closeSubpath()
            context.stroke(outer, with: .color(Color.uchihaAccent.opacity(0.15)), lineWidth: 1)

            // Inner (CCW)
            var inner = Path()
            for i in 0..<6 {
                let angle = CGFloat(i) * .pi / 3 - rotation
                let px = cx + r * 0.65 * cos(angle)
                let py = cy + r * 0.65 * sin(angle)
                if i == 0 { inner.move(to: CGPoint(x: px, y: py)) }
                else { inner.addLine(to: CGPoint(x: px, y: py)) }
            }
            inner.closeSubpath()
            context.stroke(inner, with: .color(Color.uchihaAccent.opacity(0.1)), lineWidth: 0.5)
        }
        .onAppear {
            withAnimation(.linear(duration: 10).repeatForever(autoreverses: false)) {
                rotation = .pi * 2
            }
        }
    }
}

// MARK: - Combined Backgrounds
struct GamingBackground3D: View {
    var body: some View {
        ZStack {
            LinearGradient(colors: [Color.cyberBg, Color(red: 0.05, green: 0, blue: 0), Color.cyberSurface],
                          startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()

            PerspectiveGrid3D(color: .uchihaRed, lineCount: 12)
            MatrixRain()
            HolographicGrid()
            CyberDataStream()
            FloatingParticleField(count: 20)
            CyberHexRing()
            ScanLineEffect()
            EnergyRings()

            // Itachi effects
            AkatsukiRedMoon()
            SharinganOverlay()
            CrowFeatherFall()

            CornerBrackets()
            VignetteOverlay()
        }
    }
}

struct GamingDashboardBackground: View {
    var body: some View {
        ZStack {
            LinearGradient(colors: [Color.cyberBg, Color(red: 0.08, green: 0, blue: 0)],
                          startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()

            HolographicGrid()
            PerspectiveGrid3D(color: .uchihaAccent, lineCount: 8)
            FloatingParticleField(count: 10)
            CrowFeatherFall()
            CornerBrackets()
            VignetteOverlay()
        }
    }
}

// MARK: - Helper extension
extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
