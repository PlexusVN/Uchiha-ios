import SwiftUI

struct MainContainer: View {
    @ObservedObject var viewModel: AppViewModel

    var body: some View {
        ZStack(alignment: .bottom) {
            // Background — fills entire screen edge-to-edge
            CyberGridBackground().ignoresSafeArea()

            VStack(spacing: 0) {
                // Top bar — extends behind notch / Dynamic Island
                topBar
                    .background(CyberTheme.cyberCardBg.opacity(0.85)
                        .ignoresSafeArea(edges: .top))

                // Content — TabView with page-style swipe
                TabView(selection: $viewModel.selectedTab) {
                    OptimizerView(viewModel: viewModel)
                        .tag(0)
                    UserView(viewModel: viewModel)
                        .tag(1)
                    SystemInfoView(viewModel: viewModel)
                        .tag(2)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .ignoresSafeArea(.container, edges: .all)
            }

            // Bottom custom tab bar
            CyberTabBar(
                selectedTab: $viewModel.selectedTab,
                items: [
                    (icon: "bolt",      title: "TỐI ƯU"),
                    (icon: "person",    title: "THÀNH VIÊN"),
                    (icon: "info.circle", title: "HỆ THỐNG"),
                ]
            )
        }
        .ignoresSafeArea(.keyboard)
    }

    // MARK: - Top Bar
    private var topBar: some View {
        HStack(spacing: 8) {
            Image(systemName: "shield.checkered")
                .font(.system(size: 16))
                .foregroundColor(CyberTheme.cyberGlow)

            Text("Uchiha Ultralock")
                .font(.system(size: 15, weight: .bold, design: .monospaced))
                .foregroundColor(CyberTheme.textPrimary)

            Spacer()

            // Key type badge
            Group {
                switch viewModel.keyType {
                case .vip, .admin:
                    TierBadge(tier: "VIP", color: CyberTheme.tierVip)
                case .pro:
                    TierBadge(tier: "PRO", color: CyberTheme.tierPro)
                case .basic:
                    TierBadge(tier: "BASIC", color: CyberTheme.tierBasic)
                }
            }

            // FPS counter
            Text("\(viewModel.fps) FPS")
                .font(.system(size: 10, design: .monospaced))
                .foregroundColor(CyberTheme.textSecondary)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 10)
    }
}
