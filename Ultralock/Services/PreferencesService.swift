import Foundation

final class PreferencesService {
    static let shared = PreferencesService()
    private let defaults = UserDefaults.standard
    private let suite = "ultralock_prefs"

    private init() {}

    // MARK: - Auth
    var savedKey: String? {
        get { defaults.string(forKey: "\(suite)_saved_key") }
        set { defaults.set(newValue, forKey: "\(suite)_saved_key") }
    }
    var savedType: String? {
        get { defaults.string(forKey: "\(suite)_saved_type") }
        set { defaults.set(newValue, forKey: "\(suite)_saved_type") }
    }
    var savedExpiry: String? {
        get { defaults.string(forKey: "\(suite)_saved_expiry") }
        set { defaults.set(newValue, forKey: "\(suite)_saved_expiry") }
    }

    var isLoggedIn: Bool {
        savedKey != nil && savedType != nil
    }

    func clearAuth() {
        savedKey = nil
        savedType = nil
        savedExpiry = nil
    }

    // MARK: - Bubble
    var bubbleEnabled: Bool {
        get { defaults.bool(forKey: "\(suite)_bubble_enabled") }
        set { defaults.set(newValue, forKey: "\(suite)_bubble_enabled") }
    }
    var bubbleX: Int {
        get { defaults.integer(forKey: "\(suite)_bubble_x") }
        set { defaults.set(newValue, forKey: "\(suite)_bubble_x") }
    }
    var bubbleY: Int {
        get { defaults.integer(forKey: "\(suite)_bubble_y") }
        set { defaults.set(newValue, forKey: "\(suite)_bubble_y") }
    }
    var savedKeyType: String {
        get { defaults.string(forKey: "\(suite)_saved_keytype") ?? "basic" }
        set { defaults.set(newValue, forKey: "\(suite)_saved_keytype") }
    }

    // MARK: - Features
    var activeFeatures: [String] {
        get {
            defaults.stringArray(forKey: "\(suite)_active_features") ?? []
        }
        set {
            defaults.set(newValue, forKey: "\(suite)_active_features")
        }
    }

    func isFeatureActive(_ id: String) -> Bool {
        activeFeatures.contains(id)
    }

    func toggleFeature(_ id: String) {
        var features = activeFeatures
        if let idx = features.firstIndex(of: id) {
            features.remove(at: idx)
        } else {
            features.append(id)
        }
        activeFeatures = features
    }

    // MARK: - HWID
    var savedHWID: String? {
        get { defaults.string(forKey: "\(suite)_hwid") }
        set { defaults.set(newValue, forKey: "\(suite)_hwid") }
    }

    func clearAll() {
        let dict = defaults.dictionaryRepresentation()
        for key in dict.keys where key.hasPrefix(suite) {
            defaults.removeObject(forKey: key)
        }
    }
}
