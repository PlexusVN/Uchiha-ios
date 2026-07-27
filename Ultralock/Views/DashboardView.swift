import SwiftUI

struct DashboardView: View {
    let keyType: KeyType
    let licenseKey: String
    let expiresAt: String?
    var onLogout: () -> Void

    @State private var selectedTab = 0
    @State private var bubbleEnabled: Bool
    @State private var activeFeatures: [String]
    @StateObject private var fpsMonitor = FpsMonitor.shared
    @State private var showCopiedToast = false

    // Crosshair state
    @State private var crosshairColor: Color = .red
    @State private var crosshairOffsetX: Float = 0
    @State private var crosshairOffsetY: Float = 0

    private let crosshairColors: [(Color, String)] = [
        (.red, "ĐỎ"), (.green, "XANH LÁ"),
        (Color(red: 0, green: 0.75, blue: 1), "XANH DƯƠNG"),
        (.yellow, "VÀNG"), (.magenta, "HỒNG"), (.white, "TRẮNG")
    ]

    init(keyType: KeyType, licenseKey: String, expiresAt: String?, onLogout: @escaping () -> Void) {
        self.keyType = keyType
        self.licenseKey = licenseKey
        self.expiresAt = expiresAt
        self.onLogout = onLogout
        _bubbleEnabled = State(initialValue: PreferencesService.shared.bubbleEnabled)
        _activeFeatures = State(initialValue: PreferencesService.shared.activeFeatures)
    }

    var body: some View {
        VStack(spacing: 0) {
            bubbleToggleCard
            tabBar
            TabView(selection: $selectedTab) {
                toiUuTab.tag(0)
                heThongTab.tag(1)
                thanhVienTab.tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
        }
        .background(Color.cyberBg.ignoresSafeArea())
        .overlay(
            Group {
                if showCopiedToast {
                    Text("Đã sao chép!")
                        .font(.uchihaCaption(size: 10))
                        .foregroundColor(.green)
                        .padding(8)
                        .background(Color.black.opacity(0.8))
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                        .transition(.opacity)
                        .onAppear { DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { showCopiedToast = false } }
                }
            }
            , alignment: .bottom
        )
    }

    // MARK: - Bubble Toggle
    private var bubbleToggleCard: some View {
        HStack(spacing: 10) {
            Image(systemName: "message.circle.fill")
                .font(.title3)
                .foregroundColor(.uchihaAccent)
            VStack(alignment: .leading, spacing: 2) {
                Text("BONG BÓNG NỔI")
                    .font(.uchihaHeading(size: 11))
                    .foregroundColor(.uchihaAccent)
                Text("Điều khiển tính năng nhanh từ màn hình")
                    .font(.uchihaCaption(size: 8))
                    .foregroundColor(.gray)
            }
            Spacer()
            Toggle("", isOn: $bubbleEnabled)
                .tint(.uchihaAccent)
                .onChange(of: bubbleEnabled) { _, newValue in
                    PreferencesService.shared.bubbleEnabled = newValue
                    if newValue {
                        OverlayManager.shared.showBubbleMenu()
                    } else {
                        OverlayManager.shared.hideBubbleMenu()
                    }
                }
        }
        .padding(10)
        .background(Color.uchihaCard)
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.uchihaAccent.opacity(0.3), lineWidth: 1))
        .padding(.horizontal, 12)
        .padding(.top, 8)
    }

    // MARK: - Tab Bar
    private var tabBar: some View {
        HStack(spacing: 0) {
            ForEach(["⚡ TỐI ƯU", "🖥 HỆ THỐNG", "👤 THÀNH VIÊN"].indices, id: \.self) { i in
                Text(["⚡ TỐI ƯU", "🖥 HỆ THỐNG", "👤 THÀNH VIÊN"][i])
                    .font(.uchihaHeading(size: 10))
                    .foregroundColor(selectedTab == i ? .uchihaAccent : .gray)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(selectedTab == i ? Color.uchihaAccent.opacity(0.1) : .clear)
                    .onTapGesture { selectedTab = i }
            }
        }
        .overlay(
            Rectangle()
                .fill(Color.uchihaAccent)
                .frame(height: 2)
                .offset(x: CGFloat(selectedTab) * UIScreen.main.bounds.width / 3)
                .animation(.easeInOut(duration: 0.2), value: selectedTab)
            , alignment: .bottom
        )
        .padding(.horizontal, 8)
        .padding(.top, 4)
    }

    // MARK: - Tab 0: TỐI ƯU
    private var toiUuTab: some View {
        ScrollView {
            VStack(spacing: 8) {
                // FPS HUD
                FpsHudBadge(state: fpsMonitor.state)

                // Key type badge
                keyTypeBadge

                // Basic features
                sectionHeader("🔰 TÍNH NĂNG THƯỜNG")
                ForEach(ModFeature.basic) { feature in
                    featureToggleRow(feature)
                }

                // PRO features
                sectionHeader("⚡ TÍNH NĂNG CAO CẤP")
                ForEach(ModFeature.pro) { feature in
                    featureToggleRow(feature)
                }

                // VIP features
                sectionHeader("👑 TÍNH NĂNG THƯỢNG HẠNG")
                ForEach(ModFeature.vip) { feature in
                    featureToggleRow(feature)
                }

                // Crosshair color picker (visible when crosshair is enabled)
                if activeFeatures.contains("CROSSHAIR") || activeFeatures.contains("CROSSHAIR_VIP") {
                    crosshairSection
                }

                // Status footer
                statusFooter
            }
            .padding(.horizontal, 12)
            .padding(.top, 8)
        }
    }

    // MARK: - Tab 1: HỆ THỐNG
    private var heThongTab: some View {
        SystemInfoView(
            hardwareInfo: HardwareService.collect(),
            fpsMonitor: fpsMonitor
        )
    }

    // MARK: - Tab 2: THÀNH VIÊN
    private var thanhVienTab: some View {
        UserProfileView(
            keyType: keyType,
            licenseKey: licenseKey,
            expiresAt: expiresAt,
            onLogout: onLogout
        )
    }

    // MARK: - Key Type Badge
    private var keyTypeBadge: some View {
        HStack {
            Text("TRẠNG THÁI:")
                .font(.uchihaCaption(size: 9))
                .foregroundColor(.gray)
            if keyType == .vip {
                Text("👑 VIP PREMIUM")
                    .font(.uchihaHeading(size: 10))
                    .foregroundColor(.neonGold)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(Color.neonGold.opacity(0.15))
                    .clipShape(RoundedRectangle(cornerRadius: 4))
            } else if keyType == .pro {
                Text("⚡ PRO SPECIAL")
                    .font(.uchihaHeading(size: 10))
                    .foregroundColor(.uchihaAccent)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(Color.uchihaAccent.opacity(0.15))
                    .clipShape(RoundedRectangle(cornerRadius: 4))
            } else {
                Text("🔰 FREE BASIC")
                    .font(.uchihaHeading(size: 10))
                    .foregroundColor(.cyan)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(Color.cyan.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 4))
            }
            Spacer()
        }
        .padding(.vertical, 4)
    }

    // MARK: - Crosshair Section
    private var crosshairSection: some View {
        VStack(spacing: 8) {
            sectionHeader("MÀU TÂM ẢO")
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 8) {
                ForEach(crosshairColors, id: \.0.hashValue) { color, label in
                    VStack(spacing: 2) {
                        Circle()
                            .fill(color)
                            .frame(width: 28, height: 28)
                            .overlay(Circle().stroke(crosshairColor == color ? Color.white : Color.gray.opacity(0.4), lineWidth: crosshairColor == color ? 2 : 1))
                            .onTapGesture {
                                crosshairColor = color
                                OverlayManager.shared.updateCrosshair(color: color, tier: activeFeatures.contains("CROSSHAIR_VIP") ? "vip" : "pro")
                            }
                        Text(label)
                            .font(.uchihaCaption(size: 6))
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding(.horizontal, 4)

            sectionHeader("VỊ TRÍ TÂM")
            VStack(spacing: 6) {
                offsetRow(label: "Trục X (Ngang)", value: $crosshairOffsetX)
                offsetRow(label: "Trục Y (Dọc)", value: $crosshairOffsetY)
                Button(action: {
                    crosshairOffsetX = 0
                    crosshairOffsetY = 0
                    OverlayManager.shared.updateCrosshair(color: crosshairColor, tier: activeFeatures.contains("CROSSHAIR_VIP") ? "vip" : "pro")
                }) {
                    Text("🔄 MẶC ĐỊNH")
                        .font(.uchihaHeading(size: 10))
                        .foregroundColor(.uchihaAccent)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 6)
                        .background(Color.uchihaAccent.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                }
            }
        }
        .padding(8)
        .background(Color.uchihaCard)
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.uchihaRed.opacity(0.15), lineWidth: 1))
    }

    private func offsetRow(label: String, value: Binding<Float>) -> some View {
        VStack(spacing: 2) {
            Text("\(label): \(Int(value.wrappedValue)) px")
                .font(.uchihaCaption(size: 8))
                .foregroundColor(.gray)
                .frame(maxWidth: .infinity, alignment: .leading)
            Slider(value: value, in: -200...200, step: 1)
                .tint(.uchihaAccent)
                .onChange(of: value.wrappedValue) { _, _ in
                    OverlayManager.shared.updateCrosshair(
                        color: crosshairColor,
                        tier: activeFeatures.contains("CROSSHAIR_VIP") ? "vip" : "pro",
                        offsetX: Int(crosshairOffsetX),
                        offsetY: Int(crosshairOffsetY)
                    )
                }
        }
        .padding(.horizontal, 4)
    }

    // MARK: - Status Footer
    private var statusFooter: some View {
        HStack {
            Circle()
                .fill(Color.green)
                .frame(width: 6, height: 6)
            Text("Hệ thống đang hoạt động...")
                .font(.uchihaCaption(size: 9))
                .foregroundColor(.gray)
        }
        .padding(.vertical, 8)
    }

    // MARK: - Common Components
    private func sectionHeader(_ title: String) -> some View {
        HStack {
            Text(title)
                .font(.uchihaHeading(size: 10))
                .foregroundColor(.uchihaAccent)
            Spacer()
        }
        .padding(.top, 12)
        .padding(.bottom, 4)
    }

    private func featureToggleRow(_ feature: ModFeature) -> some View {
        let isAvailable: Bool = {
            if feature.isVipOnly { return keyType.isVip }
            if feature.isProOnly { return keyType.isPro }
            return true
        }()
        let isActive = activeFeatures.contains(feature.id)

        return HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(feature.name)
                    .font(.uchihaBody(size: 11))
                    .foregroundColor(isAvailable ? .white : .gray)
                Text(feature.description)
                    .font(.uchihaCaption(size: 8))
                    .foregroundColor(.gray)
            }
            Spacer()
            if !isAvailable {
                Image(systemName: "lock.fill")
                    .foregroundColor(.gray)
                    .font(.system(size: 14))
            } else {
                Toggle("", isOn: Binding(
                    get: { isActive },
                    set: { newValue in
                        if newValue {
                            if !activeFeatures.contains(feature.id) { activeFeatures.append(feature.id) }
                        } else {
                            activeFeatures.removeAll { $0 == feature.id }
                        }
                        PreferencesService.shared.activeFeatures = activeFeatures
                        handleFeatureToggle(feature.id, enabled: newValue)
                    }
                ))
                .tint(.uchihaAccent)
            }
        }
        .padding(10)
        .background(isActive ? Color.uchihaAccent.opacity(0.08) : Color.uchihaCard)
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(
            feature.isVipOnly && isAvailable ? Color.neonGold.opacity(0.3) :
            feature.isProOnly && isAvailable ? Color.uchihaAccent.opacity(0.3) :
            Color.uchihaRed.opacity(0.15), lineWidth: 1))
    }

    private func handleFeatureToggle(_ id: String, enabled: Bool) {
        if id == "CROSSHAIR" || id == "CROSSHAIR_VIP" {
            let hasCrosshair = activeFeatures.contains("CROSSHAIR") || activeFeatures.contains("CROSSHAIR_VIP")
            let tier = activeFeatures.contains("CROSSHAIR_VIP") ? "vip" : "pro"
            if hasCrosshair {
                OverlayManager.shared.showCrosshair(color: crosshairColor, tier: tier)
            } else {
                OverlayManager.shared.hideCrosshair()
            }
        }
    }
}

// MARK: - FPS HUD Badge
struct FpsHudBadge: View {
    let state: FpsState

    var fpsColor: Color {
        if state.currentFps >= 60 { return .green }
        if state.currentFps >= 45 { return .orange }
        return .red
    }

    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(fpsColor)
                .frame(width: 6, height: 6)
            Text("\(Int(state.currentFps)) FPS")
                .font(.system(size: 11, weight: .bold, design: .monospaced))
                .foregroundColor(.white)
            Text("| \(Int(state.maxRefreshRate))Hz")
                .font(.system(size: 9, design: .monospaced))
                .foregroundColor(.gray)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 4)
        .background(Color.black.opacity(0.5))
        .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.uchihaRed.opacity(0.2), lineWidth: 1))
        .frame(maxWidth: .infinity, alignment: .trailing)
    }
}

// MARK: - Server Notification
struct ServerNotifOverlay: View {
    var body: some View {
        VStack {
            HStack {
                Image(systemName: "wifi.slash")
                    .foregroundColor(.neonRed)
                Text("Mất kết nối máy chủ")
                    .font(.uchihaCaption(size: 10))
                    .foregroundColor(.white)
            }
            .padding(8)
            .background(Color.neonRed.opacity(0.2))
            .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.neonRed.opacity(0.3), lineWidth: 1))
            Spacer()
        }
        .transition(.move(edge: .top))
        .animation(.easeInOut, value: true)
    }
}
