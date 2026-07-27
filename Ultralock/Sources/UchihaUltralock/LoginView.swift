import SwiftUI

struct LoginView: View {
    @ObservedObject var viewModel: AppViewModel

    @State private var showKey: Bool = false

    var body: some View {
        ZStack {
            CyberGridBackground().ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    Spacer().frame(height: 20)

                    // Itachi avatar
                    Image("itachi_avt")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 110, height: 110)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(CyberTheme.cyberGlow, lineWidth: 2))
                        .shadow(color: CyberTheme.cyberGlow.opacity(0.4), radius: 16)

                    // Title
                    Text("Uchiha Ultralock")
                        .font(.system(size: 28, weight: .bold, design: .default))
                        .foregroundColor(CyberTheme.textPrimary)
                        .italic()

                    Text("HỆ THỐNG TỐI ƯU CẤU HÌNH FREE FIRE")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(CyberTheme.textSecondary)

                    // Key input card
                    CyberCard {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("KÍCH HOẠT HỆ THỐNG PLEXUS")
                                .font(.system(size: 12, weight: .bold, design: .monospaced))
                                .foregroundColor(CyberTheme.cyberGlow)

                            Text("Mã kích hoạt VIP (License Key)")
                                .font(.system(size: 11))
                                .foregroundColor(CyberTheme.textSecondary)

                            HStack {
                                if showKey {
                                    TextField("", text: $viewModel.licenseKey)
                                        .font(.system(size: 13, design: .monospaced))
                                        .foregroundColor(CyberTheme.textPrimary)
                                        .autocapitalization(.none)
                                        .disableAutocorrection(true)
                                } else {
                                    SecureField("Nhập mã kích hoạt", text: $viewModel.licenseKey)
                                        .font(.system(size: 13, design: .monospaced))
                                        .foregroundColor(CyberTheme.textPrimary)
                                        .autocapitalization(.none)
                                        .disableAutocorrection(true)
                                }

                                Button(action: { showKey.toggle() }) {
                                    Image(systemName: showKey ? "eye.slash" : "eye")
                                        .font(.system(size: 12))
                                        .foregroundColor(CyberTheme.textSecondary)
                                }
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 10)
                            .background(CyberTheme.bgStart.opacity(0.5))
                            .cornerRadius(8)
                            .overlay(RoundedRectangle(cornerRadius: 8)
                                .stroke(CyberTheme.cyberCardBorder, lineWidth: 1))

                            CopyableRow(
                                label: "HWID",
                                value: viewModel.hwid,
                                copyAction: { val in
                                    UIPasteboard.general.string = val
                                    viewModel.showToast("Đã sao chép HWID")
                                }
                            )
                        }
                    }

                    // Error
                    if case .error(let msg) = viewModel.authState {
                        Text(msg)
                            .font(.system(size: 12))
                            .foregroundColor(CyberTheme.danger)
                            .multilineTextAlignment(.center)
                    }

                    // Activate button
                    Button(action: {
                        Haptics.medium()
                        Task { await viewModel.login() }
                    }) {
                        ZStack {
                            if case .loading(let text) = viewModel.authState {
                                HStack(spacing: 10) {
                                    ProgressView()
                                        .tint(.white)
                                        .scaleEffect(0.8)
                                    Text(text)
                                        .font(.system(size: 14, weight: .semibold))
                                }
                                .foregroundColor(.white)
                            } else {
                                Text("XÁC THỰC NGAY")
                                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                                    .foregroundColor(.white)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            LinearGradient(colors: [CyberTheme.cyberGlow, Color(hex: 0x8A0000)],
                                           startPoint: .leading, endPoint: .trailing)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(RoundedRectangle(cornerRadius: 12)
                            .stroke(CyberTheme.cyberGlow.opacity(0.5), lineWidth: 1))
                    }
                    .disabled(viewModel.licenseKey.trimmingCharacters(in: .whitespaces).isEmpty)
                    .opacity(viewModel.licenseKey.trimmingCharacters(in: .whitespaces).isEmpty ? 0.5 : 1)

                    // Instruction card
                    CyberCard {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("HƯỚNG DẪN KÍCH HOẠT PLEXUS KEY")
                                .font(.system(size: 10, weight: .bold, design: .monospaced))
                                .foregroundColor(CyberTheme.textAccent)

                            instructionRow("1", "Mua KEY tại người bán uy tín")
                            instructionRow("2", "Sao chép mã KEY vào ô bên trên")
                            instructionRow("3", "Nhấn XÁC THỰC NGAY để kích hoạt")
                        }
                    }

                    // Contact card
                    CyberCard {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("LIÊN HỆ HỖ TRỢ")
                                .font(.system(size: 11, weight: .bold, design: .monospaced))
                                .foregroundColor(CyberTheme.cyberGlow)

                            contactRow(icon: "paperplane.fill", label: "Telegram", value: "@trnmnhkh",
                                       action: { UIPasteboard.general.string = "@trnmnhkh"
                                          viewModel.showToast("Đã sao chép Telegram")
                                       })
                            contactRow(icon: "phone.fill", label: "Zalo", value: "0342145707",
                                       action: { UIPasteboard.general.string = "0342145707"
                                          viewModel.showToast("Đã sao chép Zalo")
                                       })
                        }
                    }

                    Spacer().frame(height: 30)
                }
                .padding(.horizontal, 24)
            }
        }
    }

    private func instructionRow(_ num: String, _ text: String) -> some View {
        HStack(spacing: 8) {
            Text(num)
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(CyberTheme.cyberGlow)
                .frame(width: 16, height: 16)
                .background(CyberTheme.cyberGlow.opacity(0.15))
                .clipShape(Circle())
            Text(text)
                .font(.system(size: 11))
                .foregroundColor(CyberTheme.textSecondary)
        }
    }

    private func contactRow(icon: String, label: String, value: String, action: @escaping () -> Void) -> some View {
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
                .foregroundColor(CyberTheme.textPrimary)
            Button(action: action) {
                Text("SAO CHÉP")
                    .font(.system(size: 9, weight: .bold, design: .monospaced))
                    .foregroundColor(CyberTheme.cyberGlow)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(CyberTheme.cyberGlow.opacity(0.12))
                    .clipShape(Capsule())
            }
        }
        .padding(.vertical, 2)
    }
}
