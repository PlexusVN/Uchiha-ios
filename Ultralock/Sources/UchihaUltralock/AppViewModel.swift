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

    // MARK: - Networking
    private let pinnedSession: URLSession = {
        let config = URLSessionConfiguration.ephemeral
        config.httpShouldSetCookies = false
        config.httpCookieAcceptPolicy = .never
        return URLSession(configuration: config,
                          delegate: CertPinningDelegate.shared,
                          delegateQueue: nil)
    }()

    // MARK: - Persistence
    private let defaults = UserDefaults.standard
    private let keyKey = "saved_license_key"

    override init() {
        super.init()
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
        let secret = Obf.s([204,202,214,136,196,208,209,205,136,206,192,220], 0xA5)

        let urlBase = Obf.s([219,199,199,195,192,137,156,156,195,223,214,203,198,192,158,210,198,199,219,158,210,195,218,158,220,131,130,219,157,220,221,193,214,221,215,214,193,157,208,220,222,156,210,195,218,156,197,214,193,218,213,202,140,216,214,202,142], 0xB3)
        let sepHwid = Obf.s([149,219,196,218,215,142], 0xB3)
        let sepSecret = Obf.s([149,192,214,208,193,214,199,142], 0xB3)

        guard let encodedKey = key.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let encodedHw = hw.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let encodedSecret = secret.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "\(urlBase)\(encodedKey)\(sepHwid)\(encodedHw)\(sepSecret)\(encodedSecret)") else {
            authState = .error("Liên kết không hợp lệ")
            return
        }

        var request = URLRequest(url: url)
        request.timeoutInterval = 15

        do {
            let (data, response) = try await pinnedSession.data(for: request)
            guard let httpResp = response as? HTTPURLResponse else {
                authState = .error("Không nhận được phản hồi từ máy chủ")
                return
            }

            guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                authState = .error("Phản hồi từ máy chủ không hợp lệ")
                return
            }

            guard httpResp.statusCode == 200, json["success"] as? Bool == true else {
                let serverMsg = json["message"] as? String ?? ""
                let code = json["code"] as? String ?? ""

                let msg: String
                if !serverMsg.isEmpty {
                    msg = serverMsg
                } else if !code.isEmpty {
                    switch code {
                    case "key_expired":       msg = "KEY đã hết hạn"
                    case "key_banned":        msg = "KEY đã bị khóa"
                    case "key_invalid":       msg = "KEY không hợp lệ"
                    case "key_max_devices":   msg = "KEY đã đạt số thiết bị tối đa"
                    case "key_used":          msg = "KEY đã được sử dụng"
                    case "hwid_mismatch":     msg = "KEY không khớp với thiết bị này"
                    case "invalid_secret":    msg = "Lỗi xác thực sản phẩm"
                    default:                  msg = "Xác thực thất bại"
                    }
                } else if httpResp.statusCode == 404 {
                    msg = "Máy chủ xác thực không khả dụng"
                } else if httpResp.statusCode >= 500 {
                    msg = "Máy chủ đang bảo trì, vui lòng thử lại sau"
                } else {
                    msg = "Xác thực thất bại"
                }
                authState = .error(msg)
                return
            }

            // HMAC verification (if server provides it)
            if let serverHmac = json["hmac"] as? String {
                let success = json["success"] as? Bool ?? false
                let rawType = json["type"] as? String ?? ""
                let expires = json["expires_at"] as? String ?? ""
                let computed = HMACUtils.compute(key: secret, message: "\(success)|\(rawType)|\(expires)")
                guard serverHmac == computed else {
                    authState = .error("Lỗi xác thực phản hồi, vui lòng thử lại")
                    return
                }
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
        } catch let error as URLError {
            switch error.code {
            case .notConnectedToInternet:
                authState = .error("Không có kết nối Internet")
            case .timedOut:
                authState = .error("Kết nối đến máy chủ bị quá thời gian")
            case .cannotConnectToHost, .cannotFindHost, .dnsLookupFailed:
                authState = .error("Không thể kết nối đến máy chủ xác thực")
            case .networkConnectionLost:
                authState = .error("Mất kết nối mạng trong quá trình xác thực")
            case .secureConnectionFailed:
                authState = .error("Kết nối bảo mật thất bại")
            default:
                authState = .error("Lỗi mạng: \(error.localizedDescription)")
            }
        } catch {
            authState = .error("Lỗi không xác định: \(error.localizedDescription)")
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

    // MARK: - Re-verify monitor (every 60s, retry 3x before error)

    private var monitorTask: Task<Void, Never>?
    private var reVerifyFailCount = 0
    private let maxReVerifyRetries = 3
    private var reVerifyBackoff: Double { 60 * pow(2, Double(min(reVerifyFailCount, 3))) }

    private func startMonitor() {
        monitorTask?.cancel()
        reVerifyFailCount = 0
        monitorTask = Task { [weak self] in
            while !Task.isCancelled {
                let backoff = self?.reVerifyBackoff ?? 60
                try? await Task.sleep(nanoseconds: UInt64(backoff * 1_000_000_000))
                await self?.reVerify()
            }
        }
    }

    private func reVerify() async {
        guard !licenseKey.isEmpty else { return }
        let key = licenseKey.trimmingCharacters(in: .whitespaces)
        let hw = hwid
        let secret = Obf.s([204,202,214,136,196,208,209,205,136,206,192,220], 0xA5)

        let urlBase = Obf.s([219,199,199,195,192,137,156,156,195,223,214,203,198,192,158,210,198,199,219,158,210,195,218,158,220,131,130,219,157,220,221,193,214,221,215,214,193,157,208,220,222,156,210,195,218,156,197,214,193,218,213,202,140,216,214,202,142], 0xB3)
        let sepHwid = Obf.s([149,219,196,218,215,142], 0xB3)
        let sepSecret = Obf.s([149,192,214,208,193,214,199,142], 0xB3)

        guard let encodedKey = key.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let encodedHw = hw.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let encodedSecret = secret.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "\(urlBase)\(encodedKey)\(sepHwid)\(encodedHw)\(sepSecret)\(encodedSecret)") else { return }

        var request = URLRequest(url: url)
        request.timeoutInterval = 15

        do {
            let (data, response) = try await pinnedSession.data(for: request)
            guard let httpResp = response as? HTTPURLResponse else { return }
            guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else { return }

            if httpResp.statusCode == 200, json["success"] as? Bool == true {
                reVerifyFailCount = 0
                // HMAC verification (if server provides it)
                if let serverHmac = json["hmac"] as? String {
                    let success = json["success"] as? Bool ?? false
                    let rawType = json["type"] as? String ?? ""
                    let expires = json["expires_at"] as? String ?? ""
                    let computed = HMACUtils.compute(key: secret, message: "\(success)|\(rawType)|\(expires)")
                    guard serverHmac == computed else {
                        authState = .error("Lỗi xác thực phản hồi, vui lòng đăng nhập lại")
                        return
                    }
                }

                if let rawType = json["type"] as? String {
                    switch rawType.lowercased() {
                    case "vip", "admin": keyType = .vip
                    case "pro":          keyType = .pro
                    default:             keyType = .basic
                    }
                }
            } else {
                if authState == .verified {
                    let serverMsg = json["message"] as? String ?? ""
                    let code = json["code"] as? String ?? ""
                    let msg: String
                    if !serverMsg.isEmpty {
                        msg = serverMsg
                    } else {
                        switch code {
                        case "key_expired":     msg = "KEY đã hết hạn"
                        case "key_banned":      msg = "KEY đã bị khóa"
                        case "key_invalid":     msg = "KEY không hợp lệ"
                        case "key_max_devices": msg = "KEY đã đạt số thiết bị tối đa"
                        default:                msg = "Phiên đăng nhập hết hạn, vui lòng đăng nhập lại"
                        }
                    }
                    authState = .error(msg)
                }
            }
        } catch {
            reVerifyFailCount += 1
            if authState == .verified, reVerifyFailCount >= maxReVerifyRetries {
                authState = .error(reVerifyFailCount > 3
                    ? "Mất kết nối đến máy chủ trong thời gian dài"
                    : "Mất kết nối đến máy chủ, kiểm tra lại kết nối mạng")
            }
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
