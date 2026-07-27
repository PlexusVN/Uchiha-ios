import SwiftUI

struct LoginView: View {
    @Binding var notificationMessage: String?
    var onLoginSuccess: (String, KeyType, String?) -> Void

    @State private var keyInput: String = ""
    @State private var isLoading = false
    @State private var showHelp = false
    @State private var errorMessage: String? = nil

    private let telegramURL = "https://t.me/trnmnhkh"
    private let zaloPhone = "0342145707"

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Avatar
                Image("itachi_avt")
                    .resizable()
                    .frame(width: 80, height: 80)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.uchihaAccent, lineWidth: 2))
                    .shadow(color: .uchihaAccent.opacity(0.4), radius: 12)
                    .padding(.top, 40)

                // Title
                Text("UCHIHA ULTRALOCK")
                    .font(.uchihaTitle(size: 20))
                    .foregroundColor(.uchihaAccent)
                Text("— うちは アルティメットロック —")
                    .font(.uchihaCaption())
                    .foregroundColor(.gray)

                // Key Input
                VStack(alignment: .leading, spacing: 6) {
                    Text("NHẬP KEY KÍCH HOẠT")
                        .font(.uchihaCaption(size: 10))
                        .foregroundColor(.cyberTextSecondary)
                    HStack {
                        Image(systemName: "key.fill")
                            .foregroundColor(.uchihaAccent)
                            .font(.system(size: 14))
                        TextField("", text: $keyInput)
                            .font(.system(size: 14, design: .monospaced))
                            .foregroundColor(.white)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .placeholder(when: keyInput.isEmpty) {
                                Text("Nhập key của bạn...")
                                    .foregroundColor(.gray)
                                    .font(.system(size: 14, design: .monospaced))
                            }
                    }
                    .padding(12)
                    .background(Color.uchihaCard)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.uchihaAccent.opacity(0.3), lineWidth: 1)
                    )
                }
                .padding(.horizontal, 24)

                // Error
                if let error = errorMessage {
                    Text(error)
                        .font(.uchihaCaption())
                        .foregroundColor(.neonRed)
                        .padding(.horizontal, 24)
                }

                // Verify Button
                Button(action: verifyKey) {
                    ZStack {
                        Text("XÁC THỰC NGAY")
                            .font(.uchihaHeading(size: 14))
                            .foregroundColor(.white)
                            .opacity(isLoading ? 0 : 1)
                        if isLoading {
                            ProgressView()
                                .tint(.white)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        LinearGradient(colors: [.uchihaRed, .uchihaAccent], startPoint: .leading, endPoint: .trailing)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.uchihaAccent.opacity(0.6), lineWidth: 1)
                    )
                }
                .disabled(keyInput.trimmingCharacters(in: .whitespaces).isEmpty || isLoading)
                .padding(.horizontal, 24)

                // Support Channels
                VStack(spacing: 12) {
                    Text("KÊNH HỖ TRỢ")
                        .font(.uchihaCaption(size: 10))
                        .foregroundColor(.cyberTextSecondary)

                    Button(action: { openURL(telegramURL) }) {
                        AdminContactRow(icon: "paperplane.fill", platform: "TELEGRAM", value: "t.me/trnmnhkh", color: .uchihaAccent)
                    }

                    Button(action: { openURL("tel:\(zaloPhone)") }) {
                        AdminContactRow(icon: "phone.fill", platform: "ZALO", value: "Minh Khải - \(zaloPhone)", color: .uchihaAccent)
                    }
                }
                .padding(.horizontal, 24)

                // Help Toggle
                Button(action: { withAnimation { showHelp.toggle() } }) {
                    HStack {
                        Image(systemName: showHelp ? "chevron.down" : "chevron.right")
                            .font(.system(size: 10))
                        Text("HƯỚNG DẪN LẤY KEY")
                            .font(.uchihaCaption(size: 10))
                    }
                    .foregroundColor(.cyberTextSecondary)
                }

                if showHelp {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("1. Liên hệ admin qua Telegram hoặc Zalo").font(.uchihaCaption()).foregroundColor(.gray)
                        Text("2. Mua key và nhận mã kích hoạt").font(.uchihaCaption()).foregroundColor(.gray)
                        Text("3. Nhập key vào ô trên và nhấn Xác Thực").font(.uchihaCaption()).foregroundColor(.gray)
                    }
                    .padding()
                    .background(Color.uchihaCard)
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.uchihaRed.opacity(0.2), lineWidth: 1))
                    .padding(.horizontal, 24)
                }

                Spacer()
            }
        }
    }

    private func verifyKey() {
        guard !keyInput.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        isLoading = true
        errorMessage = nil
        Task {
            do {
                let result = try await AuthService.shared.verify(key: keyInput.trimmingCharacters(in: .whitespaces))
                if result.success, result.status == "valid" {
                    await MainActor.run {
                        onLoginSuccess(keyInput.trimmingCharacters(in: .whitespaces), result.keyType, result.expiresAt)
                    }
                } else {
                    await MainActor.run {
                        errorMessage = result.message ?? "Key không hợp lệ"
                    }
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                }
            }
            await MainActor.run { isLoading = false }
        }
    }

    private func openURL(_ urlString: String) {
        guard let url = URL(string: urlString) else { return }
        UIApplication.shared.open(url)
    }
}

struct AdminContactRow: View {
    let icon: String
    let platform: String
    let value: String
    let color: Color

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 24)
            VStack(alignment: .leading, spacing: 2) {
                Text(platform)
                    .font(.uchihaCaption(size: 9))
                    .foregroundColor(.cyberTextSecondary)
                Text(value)
                    .font(.uchihaBody(size: 11))
                    .foregroundColor(.white)
            }
            Spacer()
            Image(systemName: "arrow.up.right")
                .font(.system(size: 10))
                .foregroundColor(.gray)
        }
        .padding(12)
        .background(Color.uchihaCard)
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.uchihaRed.opacity(0.2), lineWidth: 1))
    }
}

extension View {
    func placeholder<Content: View>(when shouldShow: Bool, @ViewBuilder content: () -> Content) -> some View {
        ZStack(alignment: .leading) {
            if shouldShow { content() }
            self
        }
    }
}
