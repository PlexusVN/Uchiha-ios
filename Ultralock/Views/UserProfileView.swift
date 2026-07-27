import SwiftUI

struct UserProfileView: View {
    let keyType: KeyType
    let licenseKey: String
    let expiresAt: String?
    var onLogout: () -> Void

    @State private var hwid: String = ""
    @State private var showCopiedToast = false

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                // Avatar
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.uchihaAccent)
                    .padding(.top, 16)

                Text("UCHIHA ULTRALOCK")
                    .font(.uchihaTitle(size: 16))
                    .foregroundColor(.uchihaAccent)
                Text(keyType.rawValue)
                    .font(.uchihaHeading(size: 12))
                    .foregroundColor(keyType == .vip ? .neonGold : keyType == .pro ? .uchihaAccent : .gray)

                // Key Info
                VStack(spacing: 0) {
                    profileDetail("KEY", licenseKey) { UIPasteboard.general.string = licenseKey; showCopiedToast = true }
                    Divider().background(Color.uchihaRed.opacity(0.1))
                    profileDetail("LOẠI", keyType.rawValue, nil)
                    Divider().background(Color.uchihaRed.opacity(0.1))
                    if let exp = expiresAt {
                        profileDetail("HẠN SỬ DỤNG", exp, nil)
                        Divider().background(Color.uchihaRed.opacity(0.1))
                    }
                    profileDetail("HWID", hwid) { UIPasteboard.general.string = hwid; showCopiedToast = true }
                }
                .background(Color.uchihaCard)
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.uchihaRed.opacity(0.15), lineWidth: 1))

                // Admin Contacts
                VStack(spacing: 8) {
                    Text("LIÊN HỆ ADMIN")
                        .font(.uchihaHeading(size: 10))
                        .foregroundColor(.uchihaAccent)

                    Button(action: { openURL("https://t.me/trnmnhkh") }) {
                        contactRow(icon: "paperplane.fill", platform: "TELEGRAM", value: "t.me/trnmnhkh")
                    }
                    Button(action: { openURL("tel:0342145707") }) {
                        contactRow(icon: "phone.fill", platform: "ZALO", value: "Minh Khải - 0342145707")
                    }
                }

                // Logout
                Button(action: onLogout) {
                    HStack {
                        Image(systemName: "arrow.right.square")
                        Text("ĐĂNG XUẤT")
                    }
                    .font(.uchihaHeading(size: 12))
                    .foregroundColor(.neonRed)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.neonRed.opacity(0.1))
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.neonRed.opacity(0.3), lineWidth: 1))
                }
                .padding(.top, 8)

                // Copied toast
                if showCopiedToast {
                    Text("Đã sao chép!")
                        .font(.uchihaCaption(size: 10))
                        .foregroundColor(.green)
                        .transition(.opacity)
                }
            }
            .padding(.horizontal, 12)
            .onAppear { loadHWID() }
        }
    }

    private func loadHWID() {
        Task {
            hwid = await AuthService.shared.getHWID()
        }
    }

    private func profileDetail(_ label: String, _ value: String, _ onCopy: (() -> Void)?) -> some View {
        HStack {
            Text(label)
                .font(.uchihaCaption(size: 9))
                .foregroundColor(.gray)
                .frame(width: 80, alignment: .leading)
            Text(value)
                .font(.uchihaBody(size: 10))
                .foregroundColor(.white)
                .lineLimit(1)
                .truncationMode(.middle)
            Spacer()
            if let onCopy = onCopy {
                Button(action: onCopy) {
                    Image(systemName: "doc.on.doc")
                        .font(.system(size: 10))
                        .foregroundColor(.uchihaAccent)
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
    }

    private func contactRow(icon: String, platform: String, value: String) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.uchihaAccent)
                .frame(width: 20)
            VStack(alignment: .leading, spacing: 2) {
                Text(platform)
                    .font(.uchihaCaption(size: 8))
                    .foregroundColor(.gray)
                Text(value)
                    .font(.uchihaBody(size: 10))
                    .foregroundColor(.white)
            }
            Spacer()
            Image(systemName: "arrow.up.right")
                .font(.system(size: 8))
                .foregroundColor(.gray)
        }
        .padding(10)
        .background(Color.uchihaCard)
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.uchihaRed.opacity(0.15), lineWidth: 1))
    }

    private func openURL(_ urlString: String) {
        guard let url = URL(string: urlString) else { return }
        UIApplication.shared.open(url)
    }
}
