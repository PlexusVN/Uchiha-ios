import SwiftUI

enum AppScreen {
    case loading
    case login
    case permissionSetup
    case dashboard
}

struct ContentView: View {
    @State private var currentScreen: AppScreen = .loading
    @State private var notificationMessage: String? = nil
    @State private var licenseKey: String = ""
    @State private var keyType: KeyType = .basic
    @State private var expiresAt: String? = nil
    @StateObject private var fpsMonitor = FpsMonitor.shared
    @State private var serverConnected = true

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            switch currentScreen {
            case .loading:
                LoadingView()
                    .onAppear { checkAuthState() }
            case .login:
                LoginView(
                    notificationMessage: $notificationMessage,
                    onLoginSuccess: { key, type, expiry in
                        licenseKey = key
                        keyType = type
                        expiresAt = expiry
                        withAnimation { currentScreen = .permissionSetup }
                    }
                )
                .background(GamingBackground3D())
            case .permissionSetup:
                PermissionSetupView(
                    onAllGranted: {
                        withAnimation { currentScreen = .dashboard }
                    }
                )
            case .dashboard:
                DashboardView(
                    keyType: keyType,
                    licenseKey: licenseKey,
                    expiresAt: expiresAt,
                    onLogout: {
                        Task { await AuthService.shared.clearCredentials() }
                        withAnimation { currentScreen = .login }
                    }
                )
                .background(GamingDashboardBackground())
            }

            // Server notification overlay
            if !serverConnected {
                ServerNotifOverlay()
            }
        }
        .onAppear {
            startHealthCheck()
        }
    }

    private func checkAuthState() {
        Task {
            serverConnected = await AuthService.shared.checkServerHealth()
            if let creds = AuthService.shared.loadSavedCredentials() {
                do {
                    let result = try await AuthService.shared.verify(key: creds.key)
                    if result.success, result.status == "valid" {
                        licenseKey = creds.key
                        keyType = result.keyType
                        expiresAt = result.expiresAt
                        withAnimation { currentScreen = .permissionSetup }
                        return
                    }
                } catch {
                    // Fall through to login
                }
            }
            withAnimation { currentScreen = .login }
        }
    }

    private func startHealthCheck() {
        Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { _ in
            Task {
                serverConnected = await AuthService.shared.checkServerHealth()
            }
        }
    }
}

struct LoadingView: View {
    @State private var rotation: Double = 0

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            RotatingHexCore()
                .frame(width: 60, height: 60)
            VStack {
                Spacer()
                Text("UCHIHA ULTRALOCK")
                    .font(.uchihaTitle(size: 16))
                    .foregroundColor(.uchihaAccent)
                Text("Đang khởi tạo...")
                    .font(.uchihaCaption())
                    .foregroundColor(.cyberTextSecondary)
                    .padding(.top, 4)
                ProgressView()
                    .tint(.uchihaAccent)
                    .padding(.top, 8)
            }
            .padding(.bottom, 80)
        }
    }
}
