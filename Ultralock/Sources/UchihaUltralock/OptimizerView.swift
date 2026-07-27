import SwiftUI

struct OptimizerView: View {
    @ObservedObject var viewModel: AppViewModel

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 16) {
                // MARK: - Gauge
                CyberCard {
                    VStack(spacing: 10) {
                        CyberGauge(
                            value: viewModel.gaugeValue,
                            label: "System Optimization",
                            unit: "%"
                        )

                        Button(action: {
                            Haptics.light()
                            viewModel.randomizeGauge()
                        }) {
                            Text("OPTIMIZE")
                                .font(.system(size: 11, weight: .bold, design: .monospaced))
                                .foregroundColor(CyberTheme.cyberGlow)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 8)
                                .background(CyberTheme.cyberGlow.opacity(0.12))
                                .clipShape(Capsule())
                                .overlay(Capsule().stroke(CyberTheme.cyberGlow.opacity(0.3), lineWidth: 1))
                        }
                    }
                }

                // MARK: - BASIC Features
                featuresSection(
                    title: "Basic Optimization",
                    icon: "star.fill",
                    features: ModFeature.basicFeatures.filter { $0.isAvailableOniOS },
                    tierColor: CyberTheme.tierBasic
                )

                // MARK: - PRO Features
                let proFeats = ModFeature.proFeatures.filter { $0.isAvailableOniOS }
                if !proFeats.isEmpty {
                    featuresSection(
                        title: "Pro Features",
                        icon: "sparkles",
                        features: proFeats,
                        tierColor: CyberTheme.tierPro,
                        isLocked: viewModel.keyType != .pro && viewModel.keyType != .vip
                    )
                }

                // MARK: - VIP Features
                let vipFeats = ModFeature.vipFeatures.filter { $0.isAvailableOniOS }
                if !vipFeats.isEmpty {
                    featuresSection(
                        title: "VIP Features",
                        icon: "crown.fill",
                        features: vipFeats,
                        tierColor: CyberTheme.tierVip,
                        isLocked: viewModel.keyType != .vip
                    )
                }

                // MARK: - Advanced Tuner (VIP only)
                CyberCard {
                    VStack(alignment: .leading, spacing: 12) {
                        SectionHeader(title: "Advanced Tuner", icon: "slider.horizontal.3")

                        if viewModel.keyType == .vip {
                            tunerContent
                        } else {
                            LockOverlay()
                                .frame(height: 200)
                        }
                    }
                }

                Spacer().frame(height: 80)
            }
            .padding(.horizontal, 18)
            .padding(.top, 8)
            .padding(.bottom, 100)
        }
    }

    // MARK: - Features Section
    @ViewBuilder
    private func featuresSection(title: String, icon: String, features: [ModFeature], tierColor: Color, isLocked: Bool = false) -> some View {
        if !features.isEmpty {
            CyberCard {
                VStack(alignment: .leading, spacing: 8) {
                    SectionHeader(title: title, icon: icon)

                    ForEach(features) { feat in
                        let enabled = viewModel.isFeatureEnabled(feat.id) && !isLocked
                        CyberToggleRow(
                            icon: feat.icon,
                            title: feat.title,
                            isLocked: isLocked,
                            isVIP: feat.gate == .vip,
                            isOn: Binding(
                                get: { enabled },
                                set: { _ in
                                    guard !isLocked else {
                                        viewModel.showToast("Nâng cấp lên \(feat.gate == .vip ? "VIP" : "PRO") để sử dụng", isError: true)
                                        return
                                    }
                                    viewModel.toggleFeature(feat.id)
                                    Haptics.light()
                                }
                            )
                        )

                        if feat.id != features.last?.id {
                            Divider()
                                .background(CyberTheme.cyberCardBorder)
                        }
                    }
                }
            }
            .overlay(isLocked ? LockOverlay().clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous)) : nil)
        }
    }

    // MARK: - Tuner
    private var tunerContent: some View {
        VStack(spacing: 16) {
            // DPI
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("DPI")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(CyberTheme.textSecondary)
                    Spacer()
                    Text("\(Int(viewModel.tunerDpi))")
                        .font(.system(size: 13, weight: .bold, design: .monospaced))
                        .foregroundColor(CyberTheme.cyberGlow)
                }
                Slider(value: $viewModel.tunerDpi, in: 200...800, step: 50)
                    .tint(CyberTheme.cyberGlow)
            }

            // Recoil
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("Recoil Reduction")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(CyberTheme.textSecondary)
                    Spacer()
                    Text("\(Int(viewModel.tunerRecoil))%")
                        .font(.system(size: 13, weight: .bold, design: .monospaced))
                        .foregroundColor(CyberTheme.tierVip)
                }
                Slider(value: $viewModel.tunerRecoil, in: 0...100, step: 5)
                    .tint(CyberTheme.tierVip)
            }

            // Latency
            VStack(alignment: .leading, spacing: 4) {
                Text("Latency Mode")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(CyberTheme.textSecondary)

                HStack(spacing: 8) {
                    ForEach(viewModel.latencyOptions.indices, id: \.self) { i in
                        Button(action: {
                            viewModel.tunerLatency = i
                            Haptics.light()
                        }) {
                            Text(viewModel.latencyOptions[i])
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(viewModel.tunerLatency == i ? .white : CyberTheme.textSecondary)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(viewModel.tunerLatency == i
                                    ? CyberTheme.cyberGlow
                                    : CyberTheme.bgStart.opacity(0.5))
                                .clipShape(Capsule())
                                .overlay(Capsule().stroke(
                                    viewModel.tunerLatency == i
                                    ? CyberTheme.cyberGlow
                                    : CyberTheme.cyberCardBorder, lineWidth: 1))
                        }
                    }
                }
            }
        }
    }
}
