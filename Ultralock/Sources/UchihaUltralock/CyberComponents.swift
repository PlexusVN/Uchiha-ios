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
