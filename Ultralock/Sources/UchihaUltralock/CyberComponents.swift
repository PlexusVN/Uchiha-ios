import SwiftUI

// MARK: - Cyber Card
struct CyberCard<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) { self.content = content() }

    var body: some View {
        content
            .padding(14)
            .background(CyberTheme.cyberCardBg)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(CyberTheme.cyberCardBorder, lineWidth: 1))
    }
}

// MARK: - Cyber Toggle Row
struct CyberToggleRow: View {
    let icon: String
    let title: String
    let isLocked: Bool
    let isVIP: Bool
    @Binding var isOn: Bool
    var action: (() -> Void)? = nil

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .frame(width: 22, height: 22)
                .foregroundColor(isOn ? CyberTheme.cyberGlow : CyberTheme.textSecondary)

            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(isOn ? CyberTheme.textPrimary : CyberTheme.textSecondary)

            Spacer()

            if isLocked {
                Image(systemName: "lock.fill")
                    .font(.system(size: 12))
                    .foregroundColor(CyberTheme.textSecondary)
            } else if isVIP {
                Image(systemName: "crown.fill")
                    .font(.system(size: 12))
                    .foregroundColor(CyberTheme.tierVip)
            }

            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(CyberTheme.toggleOn)
                .disabled(isLocked)
                .scaleEffect(0.8)
                .onChange(of: isOn) { _ in action?() }
        }
        .padding(.vertical, 2)
    }
}

// MARK: - Cyber Gauge
struct CyberGauge: View {
    let value: Double
    let label: String
    let unit: String

    private let gaugeSize: CGFloat = 150

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .stroke(CyberTheme.gaugeEmpty, lineWidth: 10)
                    .frame(width: gaugeSize, height: gaugeSize)

                Circle()
                    .trim(from: 0, to: value / 100)
                    .stroke(
                        AngularGradient(
                            gradient: Gradient(colors: [CyberTheme.cyberGlow, CyberTheme.tierVip]),
                            center: .center,
                            startAngle: .degrees(-90),
                            endAngle: .degrees(270)
                        ),
                        style: StrokeStyle(lineWidth: 10, lineCap: .round)
                    )
                    .frame(width: gaugeSize, height: gaugeSize)
                    .rotationEffect(.degrees(-90))

                    .overlay(Circle()
                        .fill(CyberTheme.cyberGlow.opacity(0.15))
                        .frame(width: gaugeSize - 24, height: gaugeSize - 24))

                VStack(spacing: 0) {
                    Text("\(Int(value))")
                        .font(.system(size: 34, weight: .bold, design: .monospaced))
                        .foregroundColor(CyberTheme.textPrimary)
                    Text(unit)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(CyberTheme.textSecondary)
                }
            }

            Text(label)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(CyberTheme.textSecondary)
        }
    }
}

// MARK: - Cyber Grid Background
struct CyberGridBackground: View {
    var body: some View {
        ZStack {
            CyberTheme.bgGradient

            GridPattern()
                .stroke(CyberTheme.cyberCardBorder.opacity(0.3), lineWidth: 1)
        }
    }
}

private struct GridPattern: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let spacing: CGFloat = 32
        for x in stride(from: 0, through: rect.width, by: spacing) {
            path.move(to: CGPoint(x: x, y: 0))
            path.addLine(to: CGPoint(x: x, y: rect.height))
        }
        for y in stride(from: 0, through: rect.height, by: spacing) {
            path.move(to: CGPoint(x: 0, y: y))
            path.addLine(to: CGPoint(x: rect.width, y: y))
        }
        return path
    }
}

// MARK: - Tier Badge
struct TierBadge: View {
    let tier: String
    let color: Color

    var body: some View {
        Text(tier.uppercased())
            .font(.system(size: 9, weight: .bold, design: .monospaced))
            .foregroundColor(color)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(color.opacity(0.15))
            .clipShape(Capsule())
            .overlay(Capsule().stroke(color.opacity(0.4), lineWidth: 1))
    }
}

// MARK: - Copyable Row
struct CopyableRow: View {
    let label: String
    let value: String
    let copyAction: (String) -> Void

    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(CyberTheme.textSecondary)
            Spacer()
            Text(value)
                .font(.system(size: 12, design: .monospaced))
                .foregroundColor(CyberTheme.textPrimary)
                .lineLimit(1)
                .truncationMode(.middle)
            Button(action: { copyAction(value) }) {
                Image(systemName: "doc.on.doc")
                    .font(.system(size: 10))
                    .foregroundColor(CyberTheme.cyberGlow)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Section Header
struct SectionHeader: View {
    let title: String
    let icon: String

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 12))
                .foregroundColor(CyberTheme.cyberGlow)
            Text(title)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(CyberTheme.textPrimary)
            Spacer()
        }
        .padding(.top, 8)
        .padding(.bottom, 4)
    }
}

// MARK: - Blurred Lock Overlay
struct LockOverlay: View {
    var body: some View {
        ZStack {
            CyberTheme.blurredBg
            VStack(spacing: 8) {
                Image(systemName: "lock.fill")
                    .font(.system(size: 20))
                    .foregroundColor(CyberTheme.textSecondary)
                Text("Upgrade to unlock")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(CyberTheme.textSecondary)
            }
        }
    }
}

// MARK: - Status Card (Clock + System Info)
struct StatusCard: View {
    @ObservedObject var viewModel: AppViewModel
    @State private var currentTime = Date()
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    private var enabledCount: Int {
        viewModel.availableFeatures.filter { viewModel.isFeatureEnabled($0.id) }.count
    }

    private var totalCount: Int {
        viewModel.availableFeatures.count
    }

    private var clockLevel: Int {
        let total = totalCount
        guard total > 0 else { return 1 }
        let pct = Double(enabledCount) / Double(total)
        if pct >= 0.8 { return 5 }
        if pct >= 0.6 { return 4 }
        if pct >= 0.4 { return 3 }
        if pct >= 0.2 { return 2 }
        return 1
    }

    private var clockColor: Color {
        switch clockLevel {
        case 1: return CyberTheme.textSecondary
        case 2: return CyberTheme.tierBasic
        case 3: return CyberTheme.tierPro
        case 4: return CyberTheme.cyberGlow
        case 5: return Color(hex: 0xFF4444)
        default: return CyberTheme.textSecondary
        }
    }

    private var keyTypeLabel: String {
        switch viewModel.keyType {
        case .vip, .admin: return "VIP SUPREME"
        case .pro:         return "PRO EDITION"
        case .basic:       return "FREE BASIC"
        }
    }

    private var keyTypeColor: Color {
        switch viewModel.keyType {
        case .vip, .admin: return CyberTheme.tierVip
        case .pro:         return CyberTheme.tierPro
        case .basic:       return CyberTheme.tierBasic
        }
    }

    var body: some View {
        CyberCard {
            HStack(spacing: 14) {
                // Left: info
                VStack(alignment: .leading, spacing: 4) {
                    // Title row
                    HStack(spacing: 5) {
                        Circle()
                            .fill(clockColor)
                            .frame(width: 6, height: 6)
                        Text("SYSTEM STATUS")
                            .font(.system(size: 11, weight: .bold, design: .monospaced))
                            .foregroundColor(CyberTheme.textPrimary)
                    }

                    // Key type
                    HStack(spacing: 3) {
                        Text("KEY")
                            .font(.system(size: 9, weight: .medium))
                            .foregroundColor(CyberTheme.textSecondary)
                        Text(keyTypeLabel)
                            .font(.system(size: 9, weight: .bold, design: .monospaced))
                            .foregroundColor(keyTypeColor)
                    }

                    // Feature count
                    HStack(spacing: 3) {
                        Text("FEATURES")
                            .font(.system(size: 9, weight: .medium))
                            .foregroundColor(CyberTheme.textSecondary)
                        Text("\(enabledCount)/\(totalCount)")
                            .font(.system(size: 9, weight: .bold, design: .monospaced))
                            .foregroundColor(clockColor)
                        Text("ACTIVE")
                            .font(.system(size: 8))
                            .foregroundColor(CyberTheme.textSecondary)
                    }

                    // Progress bar
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 1.5)
                                .fill(CyberTheme.cyberCardBorder)
                                .frame(height: 3)
                            RoundedRectangle(cornerRadius: 1.5)
                                .fill(clockColor)
                                .frame(width: geo.size.width * CGFloat(totalCount > 0 ? enabledCount : 0) / CGFloat(max(totalCount, 1)), height: 3)
                        }
                    }
                    .frame(height: 3)

                    // Status
                    HStack(spacing: 3) {
                        Circle()
                            .fill(enabledCount > 0 ? CyberTheme.success : CyberTheme.textSecondary)
                            .frame(width: 4, height: 4)
                        Text(enabledCount > 0 ? "OPERATIONAL" : "STANDBY")
                            .font(.system(size: 8, weight: .medium, design: .monospaced))
                            .foregroundColor(enabledCount > 0 ? CyberTheme.success : CyberTheme.textSecondary)
                    }
                }

                Spacer()

                // Right: clock
                VStack(spacing: 4) {
                    ZStack {
                        // Outer glow ring
                        Circle()
                            .stroke(clockColor.opacity(clockLevel > 3 ? 0.4 : 0.2), lineWidth: 3)
                            .frame(width: 68, height: 68)
                            .shadow(color: clockColor.opacity(clockLevel > 2 ? 0.5 : 0.15), radius: clockLevel > 3 ? 10 : 4)

                        Circle()
                            .stroke(clockColor.opacity(0.1), lineWidth: 1)
                            .frame(width: 60, height: 60)

                        VStack(spacing: 1) {
                            Text(currentTime, style: .time)
                                .font(.system(size: 17, weight: .bold, design: .monospaced))
                                .foregroundColor(clockColor)
                                .shadow(color: clockColor.opacity(clockLevel > 2 ? 0.6 : 0), radius: clockLevel > 2 ? 4 : 0)

                            HStack(spacing: 2) {
                                Text("LV")
                                    .font(.system(size: 7, design: .monospaced))
                                    .foregroundColor(CyberTheme.textSecondary)
                                Text("\(clockLevel)")
                                    .font(.system(size: 8, weight: .bold, design: .monospaced))
                                    .foregroundColor(clockColor)
                            }
                        }
                    }
                }
            }
        }
        .onReceive(timer) { time in
            currentTime = time
        }
    }
}

// MARK: - Tab Bar
struct CyberTabBar: View {
    @Binding var selectedTab: Int
    let items: [(icon: String, title: String)]

    var body: some View {
        HStack(spacing: 0) {
            ForEach(items.indices, id: \.self) { i in
                let isActive = selectedTab == i
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) { selectedTab = i }
                    Haptics.light()
                }) {
                    VStack(spacing: 4) {
                        Image(systemName: isActive ? items[i].icon + ".fill" : items[i].icon)
                            .font(.system(size: 18, weight: isActive ? .semibold : .regular))
                        Text(items[i].title)
                            .font(.system(size: 9, weight: isActive ? .semibold : .regular))
                    }
                    .foregroundColor(isActive ? CyberTheme.cyberGlow : CyberTheme.textSecondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                }
            }
        }
        .background(CyberTheme.cyberCardBg.opacity(0.95)
            .ignoresSafeArea(edges: .bottom))
        .overlay(Rectangle()
            .frame(height: 0.5)
            .foregroundColor(CyberTheme.cyberCardBorder),
            alignment: .top)
    }
}
