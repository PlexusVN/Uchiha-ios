import SwiftUI

struct PermissionSetupView: View {
    var onAllGranted: () -> Void

    @State private var overlayGranted = false
    @State private var notificationGranted = false

    var allGranted: Bool { overlayGranted }

    var body: some View {
        VStack(spacing: 20) {
            Spacer()

            Image(systemName: "shield.checkered")
                .font(.system(size: 50))
                .foregroundColor(.uchihaAccent)

            Text("THIẾT LẬP QUYỀN")
                .font(.uchihaTitle(size: 18))
                .foregroundColor(.uchihaAccent)
            Text("Cấp quyền để ứng dụng hoạt động tối ưu")
                .font(.uchihaBody())
                .foregroundColor(.cyberTextSecondary)

            VStack(spacing: 12) {
                PermissionRow(
                    icon: "square.on.square",
                    title: "HIỂN THỊ TRÊN ỨNG DỤNG KHÁC",
                    subtitle: "Cho phép hiển thị overlay khi chơi game",
                    granted: $overlayGranted,
                    action: requestOverlayPermission
                )
            }
            .padding(.horizontal, 24)

            Spacer()

            Button(action: onAllGranted) {
                Text("TIẾP TỤC")
                    .font(.uchihaHeading(size: 14))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        LinearGradient(colors: [.uchihaRed, .uchihaAccent], startPoint: .leading, endPoint: .trailing)
                    )
                    .opacity(allGranted ? 1 : 0.5)
            }
            .disabled(!allGranted)
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
    }

    private func requestOverlayPermission() {
        // iOS doesn't have SYSTEM_ALERT_WINDOW like Android
        // In-app overlay is always available
        overlayGranted = true
    }
}

struct PermissionRow: View {
    let icon: String
    let title: String
    let subtitle: String
    @Binding var granted: Bool
    var action: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(granted ? .green : .uchihaAccent)
                .frame(width: 36)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.uchihaBody(size: 11))
                    .foregroundColor(.white)
                Text(subtitle)
                    .font(.uchihaCaption(size: 9))
                    .foregroundColor(.gray)
            }

            Spacer()

            if granted {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
            } else {
                Button("CẤP") { action() }
                    .font(.uchihaCaption(size: 10))
                    .foregroundColor(.uchihaAccent)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.uchihaAccent, lineWidth: 1))
            }
        }
        .padding(12)
        .background(Color.uchihaCard)
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.uchihaRed.opacity(0.2), lineWidth: 1))
    }
}
