import Foundation

enum FeatureGate: String, Codable, CaseIterable {
    case basic
    case pro
    case vip
}

struct ModFeature: Identifiable, Codable {
    let id: String
    let title: String
    let icon: String
    let gate: FeatureGate
    var isEnabled: Bool = false
    var isAvailableOniOS: Bool = true

    static let all: [ModFeature] = Self.basicFeatures + Self.proFeatures + Self.vipFeatures

    // BASIC (5) — always available
    static let basicFeatures: [ModFeature] = [
        ModFeature(id: "SENSITIVITY",   title: "Sensitivity", icon: "eye",                   gate: .basic),
        ModFeature(id: "SCREEN",        title: "Screen",      icon: "rectangle",             gate: .basic),
        ModFeature(id: "BUFF_120HZ",    title: "120Hz Buff",  icon: "bolt",                  gate: .basic),
        ModFeature(id: "FEATHER",       title: "Feather",     icon: "circle.hexagongrid",     gate: .basic),
        ModFeature(id: "HEADSHOT",      title: "Headshot",    icon: "target",                gate: .basic),
    ]

    // PRO (3) — requires PRO/VIP key
    static let proFeatures: [ModFeature] = [
        ModFeature(id: "CROSSHAIR",        title: "Crosshair",       icon: "circle.dotted",     gate: .pro, isAvailableOniOS: false),
        ModFeature(id: "LIGHT_RECOIL",     title: "Light Recoil",    icon: "bolt.fill",         gate: .pro),
        ModFeature(id: "HEADLOCK",         title: "Headlock",        icon: "lock.shield",       gate: .pro),
    ]

    // VIP (3) — requires VIP key
    static let vipFeatures: [ModFeature] = [
        ModFeature(id: "AIMLOCK",             title: "Aimlock",            icon: "scope",               gate: .vip),
        ModFeature(id: "CROSSHAIR_VIP",       title: "VIP Crosshair",     icon: "crown",               gate: .vip, isAvailableOniOS: false),
        ModFeature(id: "AIMLOCK_HEAD_CHECK",  title: "Aimlock HeadCheck", icon: "person.crop.circle",  gate: .vip),
    ]

    static func byId(_ id: String) -> ModFeature? { all.first { $0.id == id } }

    static var availableOniOS: [ModFeature] { all.filter { $0.isAvailableOniOS } }

    static func features(for gate: FeatureGate) -> [ModFeature] {
        switch gate {
        case .basic: return basicFeatures
        case .pro:   return proFeatures
        case .vip:   return vipFeatures
        }
    }
}
