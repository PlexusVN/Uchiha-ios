import SwiftUI

struct UserView: View {
    @ObservedObject var viewModel: AppViewModel

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 16) {
                Spacer().frame(height: 10)

                // MARK: - Avatar & Tier Title
                VStack(spacing: 10) {
                    Image(uiImage: UIImage(named: "itachi_ios_avt_1024")!)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 80, height: 80)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(CyberTheme.cyberGlow, lineWidth: 2))
                        .shadow(color: CyberTheme.cyberGlow.opacity(0.3), radius: 10)

                    Group {
                        switch viewModel.keyType {
                        case .vip, .admin:
                            Text("THÀNH VIÊN VIP PREMIUM")
                                .font(.system(size: 14, weight: .bold, design: .monospaced))
                                .foregroundColor(CyberTheme.tierVip)
                        case .pro:
                            Text("THÀNH VIÊN PRO SPECIAL")
                                .font(.system(size: 14, weight: .bold, design: .monospaced))
                                .foregroundColor(CyberTheme.tierPro)
                        case .basic:
                            Text("THÀNH VIÊN BASIC FREE")
                                .font(.system(size: 14, weight: .bold, design: .monospaced))
                                .foregroundColor(CyberTheme.tierBasic)
                        }
                    }
                }

                // MARK: - Member Info Card
                CyberCard {
                    VStack(alignment: .leading, spacing: 6) {
                        SectionHeader(title: "CARD THÔNG TIN THÀNH VIÊN", icon: "person.fill")

                        memberRow(label: "Mã Kích Hoạt",
                                  value: maskKey(viewModel.licenseKey),
                                  copyValue: viewModel.licenseKey)
                        memberRow(label: "Loại Tài Khoản",
                                  value: accountTypeLabel)
                        memberRow(label: "Thời Gian Hết Hạn",
                                  value: expiryLabel)
                        memberRow(label: "Mã Thiết Bị (HWID)",
                                  value: viewModel.hwid,
                                  copyValue: viewModel.hwid)
                        memberRow(label: "Hệ Thống Phân Phối",
                                  value: "Plexus Cloud Auth v2.1")
                        memberRow(label: "Trạng Thái Xác Thực",
                                  value: "ĐÃ LIÊN KẾT THÀNH CÔNG ✅")
                    }
                }

                // MARK: - Admin Card
                CyberCard {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 8) {
                            Image(systemName: "shield.checkered")
                                .font(.system(size: 14))
                                .foregroundColor(CyberTheme.cyberGlow)
                                .frame(width: 28, height: 28)
                                .background(CyberTheme.cyberGlow.opacity(0.12))
                                .clipShape(Circle())

                            VStack(alignment: .leading, spacing: 2) {
                                Text("QUẢN TRỊ VIÊN HỆ THỐNG")
                                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                                    .foregroundColor(CyberTheme.cyberGlow)
                                Text("Hỗ trợ 24/7 & Kích hoạt bản quyền")
                                    .font(.system(size: 10))
                                    .foregroundColor(CyberTheme.textSecondary)
                            }
                        }

                        Divider().background(CyberTheme.cyberCardBorder)

                        // Admin profile
                        HStack(spacing: 10) {
                            ZStack {
                                Circle()
                                    .fill(LinearGradient(colors: [Color(hex: 0x8A0000), Color(hex: 0x330000)],
                                                         startPoint: .topLeading, endPoint: .bottomTrailing))
                                    .frame(width: 40, height: 40)
                                    .overlay(Circle().stroke(Color(hex: 0xCC4444), lineWidth: 1.5))
                                Text("VA")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(CyberTheme.textPrimary)
                            }

                            VStack(alignment: .leading, spacing: 2) {
                                Text("Minh Khai")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(CyberTheme.textPrimary)
                                Text("Plexus Developer & Distributor")
                                    .font(.system(size: 10))
                                    .foregroundColor(CyberTheme.textSecondary)
                            }
                        }

                        Divider().background(CyberTheme.cyberCardBorder)

                        // Contact items
                        adminContactRow(icon: "phone.fill", label: "Zalo Admin", value: "0342145707")
                        adminContactRow(icon: "paperplane.fill", label: "Telegram Admin", value: "@trnmnhkh")
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
                        Text("ĐĂNG XUẤT TÀI KHOẢN / ĐỔI KEY")
                            .font(.system(size: 12, weight: .bold, design: .monospaced))
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

    private var accountTypeLabel: String {
        switch viewModel.keyType {
        case .vip, .admin: return "VIP SUPREME"
        case .pro:         return "PRO EDITION"
        case .basic:       return "FREE BASIC"
        }
    }

    private var expiryLabel: String {
        guard let date = viewModel.expiresAt else { return "Vĩnh viễn / Không giới hạn" }
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd HH:mm"
        return df.string(from: date)
    }

    private func memberRow(label: String, value: String, copyValue: String? = nil) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(CyberTheme.textSecondary)
                .frame(width: 130, alignment: .leading)
            Spacer()
            Text(value)
                .font(.system(size: 11, design: .monospaced))
                .foregroundColor(CyberTheme.textPrimary)
                .lineLimit(1)
                .truncationMode(.middle)
            if let cv = copyValue {
                Button(action: {
                    Haptics.light()
                    UIPasteboard.general.string = cv
                    viewModel.showToast("Đã sao chép")
                }) {
                    Image(systemName: "doc.on.doc")
                        .font(.system(size: 10))
                        .foregroundColor(CyberTheme.cyberGlow)
                }
            }
        }
        .padding(.vertical, 3)
    }

    private func adminContactRow(icon: String, label: String, value: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 11))
                .foregroundColor(CyberTheme.cyberGlow)
                .frame(width: 18)
            Text(label)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(CyberTheme.textSecondary)
            Spacer()
            Text(value)
                .font(.system(size: 11, design: .monospaced))
                .foregroundColor(CyberTheme.textPrimary)
            Button(action: {
                Haptics.light()
                UIPasteboard.general.string = value
                viewModel.showToast("Đã sao chép \(label)")
            }) {
                Text("SAO CHÉP")
                    .font(.system(size: 8, weight: .bold, design: .monospaced))
                    .foregroundColor(CyberTheme.cyberGlow)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(CyberTheme.cyberGlow.opacity(0.12))
                    .clipShape(Capsule())
            }
        }
        .padding(.vertical, 2)
    }
}
