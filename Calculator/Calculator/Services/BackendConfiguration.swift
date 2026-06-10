//
//  BackendConfiguration.swift
//  Calculator
//
//  Connection settings for the backend, sourced from the app's Info.plist so the
//  base URL and credentials aren't hardcoded in the networking layer. Falls back to
//  local-development defaults when a key is absent (e.g. in unit tests or previews).
//

import Foundation

struct BackendConfiguration {
    let baseURL: URL
    let username: String
    let password: String

    /// The configuration baked into the running app's Info.plist.
    static let current = BackendConfiguration(bundle: .main)

    init(baseURL: URL, username: String, password: String) {
        self.baseURL = baseURL
        self.username = username
        self.password = password
    }

    init(bundle: Bundle) {
        let fallbackURL = URL(string: "http://localhost:3000")!
        let baseURLString = bundle.infoString(forKey: "BackendBaseURL")
        baseURL = baseURLString.flatMap(URL.init(string:)) ?? fallbackURL
        username = bundle.infoString(forKey: "BackendUsername") ?? "admin"
        password = bundle.infoString(forKey: "BackendPassword") ?? "calculator123"
    }

    /// The full URL for the session POST endpoint.
    var sessionEndpoint: URL {
        baseURL.appendingPathComponent("api/session")
    }

    /// The HTTP Basic auth header value, or `nil` when no username is configured.
    var basicAuthHeaderValue: String? {
        guard !username.isEmpty else { return nil }
        let credentials = "\(username):\(password)"
        guard let data = credentials.data(using: .utf8) else { return nil }
        return "Basic \(data.base64EncodedString())"
    }
}

private extension Bundle {
    /// Returns a non-empty Info.plist string for `key`, or `nil`.
    func infoString(forKey key: String) -> String? {
        guard let value = object(forInfoDictionaryKey: key) as? String, !value.isEmpty else {
            return nil
        }
        return value
    }
}
