import SwiftUI

struct UserView: View {
    @ObservedObject var viewModel: AppViewModel

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 16) {
                Spacer().frame(height: 10)

                // MARK: - Avatar & Tier
                VStack(spacing: 10) {
                    ZStack {
                        Circle()
                            .fill(CyberTheme.cyberGlow.opacity(0.12))
                            .frame(width: 72, height: 72)
                        Image(systemName: "person.crop.circle.fill")
                            .font(.system(size: 36))
                            .foregroundColor(CyberTheme.cyberGlow)
                    }

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
                }

                // MARK: - License Info
                CyberCard {
                    VStack(alignment: .leading, spacing: 8) {
                        SectionHeader(title: "License Info", icon: "key.fill")

                        CopyableRow(
                            label: "Key",
                            value: maskKey(viewModel.licenseKey),
                            copyAction: { val in
                                UIPasteboard.general.string = viewModel.licenseKey
                                viewModel.showToast("Key copied")
                            }
                        )

                        CopyableRow(
                            label: "HWID",
                            value: viewModel.hwid,
                            copyAction: { val in
                                UIPasteboard.general.string = val
                                viewModel.showToast("HWID copied")
                            }
                        )

                        if let exp = viewModel.expiresAt {
                            row(label: "Expires", value: formatted(exp))
                        }

                        row(label: "Type", value: viewModel.keyType.rawValue.uppercased())
                    }
                }

                // MARK: - Admin Contacts
                CyberCard {
                    VStack(alignment: .leading, spacing: 8) {
                        SectionHeader(title: "Support", icon: "envelope.fill")

                        contactRow(icon: "paperplane.fill", label: "Telegram", value: "@plexus_support")
                        contactRow(icon: "envelope", label: "Email", value: "support@ultralock.dev")
                    }
                }

                // MARK: - Logout
                Button(action: {
                    Haptics.heavy()
                    viewModel.logout()
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                            .font(.system(size: 14))
                        Text("LOGOUT")
                            .font(.system(size: 13, weight: .bold, design: .monospaced))
                    }
                    .foregroundColor(CyberTheme.danger)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(CyberTheme.danger.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .overlay(RoundedRectangle(cornerRadius: 10)
                        .stroke(CyberTheme.danger.opacity(0.3), lineWidth: 1))
                }

                // MARK: - App Info
                VStack(spacing: 4) {
                    Text("Uchiha Ultralock")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(CyberTheme.textSecondary)
                    Text("Version 1.0.0")
                        .font(.system(size: 10))
                        .foregroundColor(CyberTheme.textSecondary.opacity(0.6))
                }
                .padding(.top, 8)

                Spacer().frame(height: 80)
            }
            .padding(.horizontal, 18)
            .padding(.top, 8)
            .padding(.bottom, 100)
        }
    }

    // MARK: - Helpers
    private func maskKey(_ key: String) -> String {
        guard key.count > 8 else { return key }
        return "\(key.prefix(4))...\(key.suffix(4))"
    }

    private func formatted(_ date: Date) -> String {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd HH:mm"
        return df.string(from: date)
    }

    private func row(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(CyberTheme.textSecondary)
            Spacer()
            Text(value)
                .font(.system(size: 12, design: .monospaced))
                .foregroundColor(CyberTheme.textPrimary)
        }
        .padding(.vertical, 4)
    }

    private func contactRow(icon: String, label: String, value: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 12))
                .foregroundColor(CyberTheme.cyberGlow)
                .frame(width: 20)
            Text(label)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(CyberTheme.textSecondary)
            Spacer()
            Text(value)
                .font(.system(size: 12, design: .monospaced))
                .foregroundColor(CyberTheme.tierVip)
        }
        .padding(.vertical, 4)
    }
}
