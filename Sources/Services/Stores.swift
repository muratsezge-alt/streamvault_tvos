import SwiftUI

// MARK: - PlaylistStore

@MainActor
final class PlaylistStore: ObservableObject {
    @Published var data = ParsedPlaylist()
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published private(set) var savedURL: String? {
        didSet { UserDefaults.standard.set(savedURL, forKey: Keys.url) }
    }

    private enum Keys { static let url = "m3u_url" }

    init() {
        savedURL = UserDefaults.standard.string(forKey: Keys.url)
    }

    var hasPlaylist: Bool { savedURL != nil }

    func load(urlString: String) async {
        let trimmed = urlString.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let url = URL(string: trimmed) else {
            errorMessage = "Geçersiz URL."
            return
        }
        isLoading = true
        errorMessage = nil
        do {
            // Fetch + parse run OFF the main actor so a huge playlist never freezes the UI.
            let parsed = try await Self.fetchAndParse(url: url)
            if parsed.isEmpty {
                throw NSError(domain: "StreamVault", code: -2,
                              userInfo: [NSLocalizedDescriptionKey: "Liste boş ya da M3U formatında değil."])
            }
            data = parsed
            savedURL = trimmed
        } catch {
            errorMessage = "Liste yüklenemedi: \(error.localizedDescription)"
        }
        isLoading = false
    }

    /// nonisolated → executes on a background executor, keeping the main thread free.
    nonisolated static func fetchAndParse(url: URL) async throws -> ParsedPlaylist {
        var request = URLRequest(url: url)
        request.timeoutInterval = 30
        request.setValue("VLC/3.0 LibVLC/3.0", forHTTPHeaderField: "User-Agent")
        let (bytes, response) = try await URLSession.shared.data(for: request)
        if let http = response as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
            throw NSError(domain: "StreamVault", code: http.statusCode,
                          userInfo: [NSLocalizedDescriptionKey: "Sunucu \(http.statusCode) döndürdü."])
        }
        let text = String(decoding: bytes, as: UTF8.self)
        return M3UParser.parse(text)
    }

    func reloadSaved() async {
        if let saved = savedURL { await load(urlString: saved) }
    }

    func clear() {
        savedURL = nil
        data = ParsedPlaylist()
    }
}

// MARK: - FavoritesStore

@MainActor
final class FavoritesStore: ObservableObject {
    @Published private(set) var refs: Set<FavoriteRef> = []
    private let key = "favorites_v1"

    init() {
        if let data = UserDefaults.standard.data(forKey: key),
           let decoded = try? JSONDecoder().decode([FavoriteRef].self, from: data) {
            refs = Set(decoded)
        }
    }

    func isFavorite(_ kind: FavoriteKind, _ id: String) -> Bool {
        refs.contains(FavoriteRef(kind: kind, id: id))
    }

    func toggle(_ kind: FavoriteKind, _ id: String) {
        let ref = FavoriteRef(kind: kind, id: id)
        if refs.contains(ref) { refs.remove(ref) } else { refs.insert(ref) }
        persist()
    }

    private func persist() {
        if let data = try? JSONEncoder().encode(Array(refs)) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
}

// MARK: - ThemeStore

@MainActor
final class ThemeStore: ObservableObject {
    @Published var theme: AppTheme {
        didSet { UserDefaults.standard.set(theme.rawValue, forKey: key) }
    }
    private let key = "theme_v1"

    init() {
        let raw = UserDefaults.standard.string(forKey: key) ?? AppTheme.navy.rawValue
        theme = AppTheme(rawValue: raw) ?? .navy
    }
}
