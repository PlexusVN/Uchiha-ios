import Foundation

struct AuthResult: Codable {
    let success: Bool
    let status: String
    let message: String?
    let expiresAt: String?
    let serverTime: String?
    let type: String?

    enum CodingKeys: String, CodingKey {
        case success, status, message
        case expiresAt = "expires_at"
        case serverTime = "server_time"
        case type
    }

    var keyType: KeyType {
        guard let t = type?.lowercased() else { return .basic }
        if t.contains("vip") || t.contains("admin") { return .vip }
        if t.contains("pro") { return .pro }
        return .basic
    }
}

enum KeyType: String, Codable {
    case basic = "BASIC"
    case pro = "PRO"
    case vip = "VIP"

    var isPro: Bool { self == .pro || self == .vip }
    var isVip: Bool { self == .vip }
}

struct SavedCredentials: Codable {
    let key: String
    let type: String
    let expiresAt: String?
}

struct HardwareInfo {
    let chipset: String
    let cpuCores: Int
    let cpuFreq: String
    let gpu: String
    let ramTotal: String
    let ramAvailable: String
    let storageTotal: String
    let storageAvail: String
    let screenRes: String
    let screenSize: String
    let refreshRate: Int
    let density: String
    let iosVer: String
    let device: String
    let manufacturer: String
    let model: String
    let batteryPct: Int
    let batteryTemp: Double
}

struct FpsState {
    let currentFps: Double
    let maxRefreshRate: Double
    let qualityLevel: QualityLevel
    let frameTimeMs: Double
}

enum QualityLevel {
    case ultra, high, medium, low

    var particleCount: Int {
        switch self {
        case .ultra: return 20
        case .high: return 14
        case .medium: return 9
        case .low: return 5
        }
    }

    var gridDetail: Int {
        switch self {
        case .ultra, .high: return 1
        case .medium: return 2
        case .low: return 3
        }
    }

    var animSpeed: Double {
        switch self {
        case .ultra: return 0.8
        case .high: return 0.7
        case .medium: return 0.6
        case .low: return 0.4
        }
    }

    static func fromFps(_ fps: Double) -> QualityLevel {
        if fps >= 90 { return .ultra }
        if fps >= 60 { return .high }
        if fps >= 45 { return .medium }
        return .low
    }
}

struct ModFeature: Identifiable {
    let id: String
    let name: String
    let description: String
    let defaultActive: Bool
    let isVipOnly: Bool
    let isProOnly: Bool

    static let all: [ModFeature] = [
        ModFeature(id: "SENSITIVITY", name: "SENSIVITY BOOSTER", description: "Nhạy Màn Hình Tối Đa", defaultActive: false, isVipOnly: false, isProOnly: false),
        ModFeature(id: "SCREEN", name: "SCREEN BOOSTER", description: "Buff FPS Siêu Mượt", defaultActive: false, isVipOnly: false, isProOnly: false),
        ModFeature(id: "BUFF_120HZ", name: "BUFF 120HZ SCREEN", description: "Tần Số Quét 120Hz Cao Cấp", defaultActive: false, isVipOnly: false, isProOnly: false),
        ModFeature(id: "FEATHER", name: "FEATHER AIM", description: "Nhẹ Tâm Nhắm FF", defaultActive: false, isVipOnly: false, isProOnly: false),
        ModFeature(id: "HEADSHOT", name: "HEADSHOT FIX", description: "Fix Lỗi Nhắm Headshot", defaultActive: false, isVipOnly: false, isProOnly: false),
        ModFeature(id: "CROSSHAIR", name: "CROSSHAIR OVERLAY 🎯", description: "Tâm Ảo Hỗ Trợ Bám Đầu Pro", defaultActive: false, isVipOnly: false, isProOnly: true),
        ModFeature(id: "LIGHT_RECOIL", name: "NHẸ TÂM GIẢM LỰC CẢN ⚡", description: "Giảm lực cản khi kéo tâm", defaultActive: false, isVipOnly: false, isProOnly: true),
        ModFeature(id: "HEADLOCK", name: "KHÓA CỨNG VÙNG ĐẦU ⚡", description: "Tự động khóa tâm vào vùng đầu", defaultActive: false, isVipOnly: false, isProOnly: true),
        ModFeature(id: "AIMLOCK", name: "AIMLOCK ULTRA 👑", description: "Khóa Tâm Bám Đầu [VIP Only]", defaultActive: false, isVipOnly: true, isProOnly: false),
        ModFeature(id: "CROSSHAIR_VIP", name: "CROSSHAIR PREMIUM 👑", description: "Tâm Ảo Hỗ Trợ Bám Đầu VIP", defaultActive: false, isVipOnly: true, isProOnly: false),
        ModFeature(id: "AIMLOCK_HEAD_CHECK", name: "AIMLOCK HEAD CÂN CHECK 👑", description: "Khóa đầu chống phát hiện [VIP Only]", defaultActive: false, isVipOnly: true, isProOnly: false)
    ]

    static var basic: [ModFeature] { all.filter { !$0.isProOnly && !$0.isVipOnly } }
    static var pro: [ModFeature] { all.filter { $0.isProOnly } }
    static var vip: [ModFeature] { all.filter { $0.isVipOnly } }
}
