import SwiftUI
import Foundation
import Combine

@MainActor
final class AppViewModel: NSObject, ObservableObject {

    // MARK: - Auth
    @Published var authState: AuthState = .idle
    @Published var licenseKey: String = ""
    @Published var hwid: String = DeviceUtils.hwid
    @Published var keyType: KeyType = .basic
    @Published var expiresAt: Date?
    @Published var errorMessage: String?

    enum AuthState: Equatable {
        case idle
        case loading(String)
        case verified
        case error(String)
    }

    enum KeyType: String, Codable {
        case basic, pro, vip, admin
    }

    // MARK: - Features
    @Published var featureStates: [String: Bool] = [:]
    @Published var gaugeValue: Double = 65

    // MARK: - Tuner (VIP)
    @Published var tunerDpi: Double = 400
    @Published var tunerRecoil: Double = 50
    @Published var tunerLatency: Int = 1
    let latencyOptions = ["Low", "Medium", "High"]

    // MARK: - Toast
    @Published var toastMessage: String?
    @Published var toastIsError: Bool = false
    private var toastTask: Task<Void, Never>?

    // MARK: - System Info
    @Published var fps: Int = 0
    private var fpsDisplayLink: CADisplayLink?
    private var fpsFrameCount: Int = 0
    private var fpsLastTime: CFTimeInterval = 0

    // MARK: - Tabs
    @Published var selectedTab: Int = 0

    // MARK: - Persistence
    private let defaults = UserDefaults.standard
    private let keyKey = "saved_license_key"

    override init() {
        loadSavedKey()
        startFpsMonitor()
    }

    deinit {
        fpsDisplayLink?.invalidate()
    }

    // MARK: - Auth

    private func loadSavedKey() {
        if let saved = defaults.string(forKey: keyKey), !saved.isEmpty {
            licenseKey = saved
        }
    }

    func login() async {
        guard !licenseKey.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorMessage = "Please enter a license key"
            return
        }

        authState = .loading("Verifying key...")

        let key = licenseKey.trimmingCharacters(in: .whitespaces)
        let hw = hwid
        let secret = "adr-auth-key"

        guard let encodedKey = key.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let encodedHw = hw.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let encodedSecret = secret.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "https://plexus-auth-api-o01h.onrender.com/api/verify?key=\(encodedKey)&hwid=\(encodedHw)&secret=\(encodedSecret)") else {
            authState = .error("Invalid URL")
            return
        }

        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            guard let httpResp = response as? HTTPURLResponse else {
                authState = .error("No response from server")
                return
            }

            guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                authState = .error("Invalid server response")
                return
            }

            guard httpResp.statusCode == 200, json["success"] as? Bool == true else {
                let msg = json["message"] as? String ?? "Verification failed"
                authState = .error(msg)
                return
            }

            // Parse key type
            if let rawType = json["type"] as? String {
                switch rawType.lowercased() {
                case "vip", "admin": keyType = .vip
                case "pro":          keyType = .pro
                default:             keyType = .basic
                }
            }

            if let expires = json["expires_at"] as? String {
                let df = ISO8601DateFormatter()
                df.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
                expiresAt = df.date(from: expires)
            }

            defaults.set(key, forKey: keyKey)
            authState = .verified
            errorMessage = nil
            startMonitor()
        } catch {
            authState = .error("Network error: \(error.localizedDescription)")
        }
    }

    func restoreSessionIfNeeded() async {
        guard !licenseKey.isEmpty else { return }
        authState = .loading("Restoring session...")
        try? await Task.sleep(nanoseconds: 600_000_000)
        await login()
    }

    func logout() {
        authState = .idle
        licenseKey = ""
        keyType = .basic
        expiresAt = nil
        errorMessage = nil
        defaults.removeObject(forKey: keyKey)
    }

    // MARK: - Re-verify monitor (every 60s)

    private var monitorTask: Task<Void, Never>?

    private func startMonitor() {
        monitorTask?.cancel()
        monitorTask = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 60_000_000_000)
                await self?.reVerify()
            }
        }
    }

    private func reVerify() async {
        guard !licenseKey.isEmpty else { return }
        let key = licenseKey.trimmingCharacters(in: .whitespaces)
        let hw = hwid
        let secret = "adr-auth-key"

        guard let encodedKey = key.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let encodedHw = hw.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let encodedSecret = secret.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "https://plexus-auth-api-o01h.onrender.com/api/verify?key=\(encodedKey)&hwid=\(encodedHw)&secret=\(encodedSecret)") else { return }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else { return }
            if json["success"] as? Bool == true {
                if let rawType = json["type"] as? String {
                    switch rawType.lowercased() {
                    case "vip", "admin": keyType = .vip
                    case "pro":          keyType = .pro
                    default:             keyType = .basic
                    }
                }
            } else {
                if authState == .verified {
                    authState = .error("Session expired. Please re-login.")
                }
            }
        } catch {
            // silent fail — retry next cycle
        }
    }

    // MARK: - Features

    var availableFeatures: [ModFeature] {
        ModFeature.all.filter { feat in
            guard feat.isAvailableOniOS else { return false }
            switch feat.gate {
            case .basic: return true
            case .pro:   return keyType == .pro || keyType == .vip
            case .vip:   return keyType == .vip
            }
        }
    }

    var lockedFeatures: [ModFeature] {
        ModFeature.all.filter { feat in
            guard feat.isAvailableOniOS else { return false }
            switch feat.gate {
            case .basic: return false
            case .pro:   return keyType != .pro && keyType != .vip
            case .vip:   return keyType != .vip
            }
        }
    }

    func toggleFeature(_ id: String) {
        featureStates[id] = !(featureStates[id] ?? false)
    }

    func isFeatureEnabled(_ id: String) -> Bool {
        featureStates[id] ?? false
    }

    // MARK: - Toast

    func showToast(_ message: String, isError: Bool = false, duration: TimeInterval = 2.5) {
        toastTask?.cancel()
        toastMessage = message
        toastIsError = isError
        toastTask = Task { [weak self] in
            try? await Task.sleep(nanoseconds: UInt64(duration * 1_000_000_000))
            self?.toastMessage = nil
        }
    }

    // MARK: - FPS Monitor

    private func startFpsMonitor() {
        fpsDisplayLink = CADisplayLink(target: self, selector: #selector(fpsTick(_:)))
        fpsDisplayLink?.add(to: .main, forMode: .common)
    }

    @objc private func fpsTick(_ link: CADisplayLink) {
        fpsFrameCount += 1
        if fpsLastTime == 0 { fpsLastTime = link.timestamp; return }
        let delta = link.timestamp - fpsLastTime
        if delta >= 1.0 {
            fps = Int(Double(fpsFrameCount) / delta)
            fpsFrameCount = 0
            fpsLastTime = link.timestamp
        }
    }

    // MARK: - Gauge

    func randomizeGauge() {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
            gaugeValue = Double.random(in: 45...95)
        }
    }
}
