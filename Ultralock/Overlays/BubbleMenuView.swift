import SwiftUI

struct BubbleMenuView: View {
    @State private var selectedTab = 0
    @State private var activeFeatures: [String]
    @State private var crossColor: Color = .red
    @State private var offsetX: Float = 0
    @State private var offsetY: Float = 0

    private let keyType: KeyType
    private var isPro: Bool { keyType.isPro }
    private var isVip: Bool { keyType.isVip }

    private let crosshairColors: [(Color, String)] = [
        (.red, "ĐỎ"), (.green, "XANH LÁ"),
        (Color(red: 0, green: 0.75, blue: 1), "XANH DƯƠNG"),
        (.yellow, "VÀNG"), (.magenta, "HỒNG"), (.white, "TRẮNG")
    ]

    init() {
        let prefs = PreferencesService.shared
        _activeFeatures = State(initialValue: prefs.activeFeatures)
        let savedKeyType = prefs.savedKeyType.lowercased()
        if savedKeyType.contains("vip") {
            keyType = .vip
        } else if savedKeyType.contains("pro") {
            keyType = .pro
        } else {
            keyType = .basic
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Title
            Text("⚡ UCHIHA ULTRALOCK")
                .font(.uchihaTitle(size: 14))
                .foregroundColor(.uchihaAccent)
                .padding(.top, 12)

            Text("— うちは アルティメットロック —")
                .font(.uchihaCaption(size: 8))
                .foregroundColor(.gray)
                .padding(.bottom, 8)

            // Tab bar
            HStack(spacing: 0) {
                ForEach(["TỐI ƯU", "MOD", "THÔNG TIN"].indices, id: \.self) { i in
                    Text(["TỐI ƯU", "MOD", "THÔNG TIN"][i])
                        .font(.uchihaHeading(size: 10))
                        .foregroundColor(selectedTab == i ? .uchihaAccent : .gray)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(selectedTab == i ? Color.uchihaAccent.opacity(0.1) : .clear)
                        .onTapGesture { selectedTab = i }
                }
            }
            .overlay(
                Rectangle()
                    .fill(Color.uchihaAccent)
                    .frame(height: 2)
                    .offset(x: CGFloat(selectedTab) * 120)
                    .animation(.easeInOut(duration: 0.2), value: selectedTab)
                , alignment: .bottom
            )

            // Content
            TabView(selection: $selectedTab) {
                tab0.tag(0)
                tab1.tag(1)
                tab2.tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(maxHeight: 320)

            // Close button
            Button(action: { OverlayManager.shared.hideBubbleMenu() }) {
                Text("✕ ĐÓNG")
                    .font(.uchihaHeading(size: 12))
                    .foregroundColor(.uchihaAccent)
                    .padding(.vertical, 8)
            }
        }
        .frame(width: 280)
        .background(
            LinearGradient(colors: [Color(red: 0.05, green: 0, blue: 0), Color(red: 0.1, green: 0.02, blue: 0.02)],
                          startPoint: .top, endPoint: .bottom)
        )
        .overlay(
            Rectangle()
                .stroke(Color.uchihaAccent.opacity(0.2), lineWidth: 2)
        )
    }

    // Tab 0: TỐI ƯU
    private var tab0: some View {
        ScrollView {
            VStack(spacing: 4) {
                sectionHeader("CƠ BẢN")
                ForEach(ModFeature.basic, id: \.id) { feat in
                    compactToggleRow(feat, available: true)
                }
                sectionHeader("NÂNG CAO")
                ForEach(ModFeature.pro, id: \.id) { feat in
                    compactToggleRow(feat, available: isPro)
                }
            }
            .padding(8)
        }
    }

    // Tab 1: MOD
    private var tab1: some View {
        ScrollView {
            VStack(spacing: 4) {
                sectionHeader("VIP")
                ForEach(ModFeature.vip, id: \.id) { feat in
                    compactToggleRow(feat, available: isVip)
                }

                // Crosshair color picker (gated)
                if isPro || isVip {
                    sectionHeader("MÀU TÂM ẢO")
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 6) {
                        ForEach(crosshairColors, id: \.0.hashValue) { color, label in
                            VStack(spacing: 2) {
                                Circle()
                                    .fill(color)
                                    .frame(width: 24, height: 24)
                                    .overlay(Circle().stroke(crossColor == color ? Color.white : Color.gray.opacity(0.4), lineWidth: crossColor == color ? 2 : 1))
                                    .onTapGesture {
                                        crossColor = color
                                        OverlayManager.shared.updateCrosshair(color: color, tier: isVip ? "vip" : "pro")
                                    }
                                Text(label)
                                    .font(.uchihaCaption(size: 6))
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .padding(.horizontal, 4)

                    sectionHeader("VỊ TRÍ TÂM")
                    VStack(spacing: 4) {
                        compactOffsetRow("Trục X", value: $offsetX)
                        compactOffsetRow("Trục Y", value: $offsetY)
                        Button(action: {
                            offsetX = 0; offsetY = 0
                            OverlayManager.shared.updateCrosshair(color: crossColor, tier: isVip ? "vip" : "pro")
                        }) {
                            Text("🔄 MẶC ĐỊNH")
                                .font(.uchihaCaption(size: 8))
                                .foregroundColor(.uchihaAccent)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 4)
                                .background(Color.uchihaAccent.opacity(0.1))
                                .clipShape(RoundedRectangle(cornerRadius: 4))
                        }
                    }
                }
            }
            .padding(8)
        }
    }

    // Tab 2: THÔNG TIN
    private var tab2: some View {
        ScrollView {
            VStack(spacing: 6) {
                infoRow("ỨNG DỤNG", "Uchiha Ultralock")
                Divider().background(Color.uchihaRed.opacity(0.1))
                infoRow("PHIÊN BẢN", "1.0.0")
                Divider().background(Color.uchihaRed.opacity(0.1))
                infoRow("PHÁT TRIỂN", "Minh Khải")
                Divider().background(Color.uchihaRed.opacity(0.1))
                infoRow("LIÊN HỆ", "0342145707")
                Divider().background(Color.uchihaRed.opacity(0.1))
                Text("Cảm ơn bạn đã sử dụng sản phẩm!")
                    .font(.uchihaCaption(size: 8))
                    .foregroundColor(.gray)
                    .padding(.top, 8)
            }
            .padding(12)
        }
    }

    // MARK: - Helpers
    private func sectionHeader(_ title: String) -> some View {
        HStack {
            Text(title)
                .font(.uchihaCaption(size: 9))
                .foregroundColor(.uchihaAccent)
            Spacer()
        }
        .padding(.top, 8).padding(.bottom, 2)
    }

    private func compactToggleRow(_ feature: ModFeature, available: Bool) -> some View {
        let isActive = activeFeatures.contains(feature.id)
        return HStack {
            Text(feature.name)
                .font(.uchihaCaption(size: 8))
                .foregroundColor(available ? .white : .gray)
            Spacer()
            if available {
                Toggle("", isOn: Binding(
                    get: { isActive },
                    set: { newValue in
                        if newValue { activeFeatures.append(feature.id) }
                        else { activeFeatures.removeAll { $0 == feature.id } }
                        PreferencesService.shared.activeFeatures = activeFeatures
                        handleToggle(feature.id, on: newValue)
                    }
                ))
                .tint(.uchihaAccent)
                .scaleEffect(0.7)
            } else {
                Image(systemName: "lock.fill")
                    .font(.system(size: 10))
                    .foregroundColor(.gray)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(isActive && available ? Color.uchihaAccent.opacity(0.08) : Color.clear)
    }

    private func compactOffsetRow(_ label: String, value: Binding<Float>) -> some View {
        VStack(spacing: 2) {
            Text("\(label): \(Int(value.wrappedValue))px")
                .font(.uchihaCaption(size: 7))
                .foregroundColor(.gray)
                .frame(maxWidth: .infinity, alignment: .leading)
            Slider(value: value, in: -200...200, step: 1)
                .tint(.uchihaAccent)
                .onChange(of: value.wrappedValue) { _, _ in
                    OverlayManager.shared.updateCrosshair(
                        color: crossColor,
                        tier: isVip ? "vip" : "pro",
                        offsetX: Int(offsetX),
                        offsetY: Int(offsetY)
                    )
                }
        }
        .padding(.horizontal, 4)
    }

    private func handleToggle(_ id: String, on: Bool) {
        if id == "CROSSHAIR" || id == "CROSSHAIR_VIP" {
            let hasCrosshair = activeFeatures.contains("CROSSHAIR") || activeFeatures.contains("CROSSHAIR_VIP")
            let tier = activeFeatures.contains("CROSSHAIR_VIP") ? "vip" : "pro"
            if hasCrosshair {
                OverlayManager.shared.showCrosshair(color: crossColor, tier: tier)
            } else {
                OverlayManager.shared.hideCrosshair()
            }
        }
    }

    private func infoRow(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label)
                .font(.uchihaCaption(size: 8))
                .foregroundColor(.uchihaAccent)
                .frame(width: 60, alignment: .leading)
            Text(value)
                .font(.uchihaCaption(size: 9))
                .foregroundColor(.white)
            Spacer()
        }
    }
}
