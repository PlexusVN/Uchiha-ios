import Foundation
import UIKit
import CommonCrypto

actor AuthService {
    static let shared = AuthService()
    private let baseURL = "https://plexus-auth-api-o01h.onrender.com"
    private let secret = "adr-auth-key"
    private let session: URLSession

    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 15
        config.timeoutIntervalForResource = 30
        self.session = URLSession(configuration: config)
    }

    // MARK: - HWID
    func getHWID() -> String {
        let id = UIDevice.current.identifierForVendor?.uuidString ?? ""
        guard let data = id.data(using: .utf8) else { return id }
        var hash = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        data.withUnsafeBytes { buffer in
            _ = CC_SHA256(buffer.baseAddress, CC_LONG(data.count), &hash)
        }
        return hash.prefix(8).map { String(format: "%02x", $0) }.joined()
    }

    // MARK: - Verify License
    func verify(key: String) async throws -> AuthResult {
        let hwid = getHWID()
        var components = URLComponents(string: "\(baseURL)/api/verify")!
        components.queryItems = [
            URLQueryItem(name: "key", value: key),
            URLQueryItem(name: "hwid", value: hwid),
            URLQueryItem(name: "secret", value: secret)
        ]
        guard let url = components.url else {
            throw AuthError.invalidURL
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw AuthError.noResponse
        }
        if httpResponse.statusCode == 429 {
            throw AuthError.rateLimited
        }
        guard (200...299).contains(httpResponse.statusCode) else {
            throw AuthError.serverError(httpResponse.statusCode)
        }
        let decoder = JSONDecoder()
        let result = try decoder.decode(AuthResult.self, from: data)
        if result.success {
            await saveCredentials(key: key, result: result)
        }
        return result
    }

    // MARK: - Credentials Persistence
    private func saveCredentials(key: String, result: AuthResult) async {
        let prefs = PreferencesService.shared
        prefs.savedKey = key
        prefs.savedType = result.type ?? "basic"
        prefs.savedExpiry = result.expiresAt
        prefs.savedKeyType = result.type?.lowercased() ?? "basic"
        await KeychainService.shared.save(key: "license_key", value: key)
    }

    func loadSavedCredentials() -> SavedCredentials? {
        let prefs = PreferencesService.shared
        guard let key = prefs.savedKey, let type = prefs.savedType else { return nil }
        return SavedCredentials(key: key, type: type, expiresAt: prefs.savedExpiry)
    }

    func clearCredentials() {
        let prefs = PreferencesService.shared
        prefs.clearAuth()
        Task { await KeychainService.shared.delete(key: "license_key") }
    }

    // MARK: - Server Health
    func checkServerHealth() async -> Bool {
        guard let url = URL(string: "\(baseURL)/api/health") else { return false }
        do {
            let (_, response) = try await session.data(from: url)
            return (response as? HTTPURLResponse)?.statusCode == 200
        } catch {
            return false
        }
    }

    func isNetworkAvailable() -> Bool {
        // Simple reachability check
        return true // iOS handles this via NWPathMonitor in production
    }
}

enum AuthError: LocalizedError {
    case invalidURL
    case noResponse
    case rateLimited
    case serverError(Int)
    case invalidKey
    case expired
    case banned

    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Invalid request URL"
        case .noResponse: return "No response from server"
        case .rateLimited: return "Too many requests. Please wait."
        case .serverError(let code): return "Server error (\(code))"
        case .invalidKey: return "Invalid license key"
        case .expired: return "License key has expired"
        case .banned: return "License key has been banned"
        }
    }
}
