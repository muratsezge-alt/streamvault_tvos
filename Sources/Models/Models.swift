import Foundation

// MARK: - Content models (ported from lib/domain/entities/entities.dart)

struct Channel: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let logoURL: String?
    let streamURL: String
    let groupTitle: String?
    let tvgID: String?

    init(id: String = UUID().uuidString,
         name: String,
         logoURL: String? = nil,
         streamURL: String,
         groupTitle: String? = nil,
         tvgID: String? = nil) {
        self.id = id
        self.name = name
        self.logoURL = logoURL
        self.streamURL = streamURL
        self.groupTitle = groupTitle
        self.tvgID = tvgID
    }
}

struct Movie: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let coverURL: String?
    let streamURL: String
    let groupTitle: String?
    var year: String?

    init(id: String = UUID().uuidString,
         name: String,
         coverURL: String? = nil,
         streamURL: String,
         groupTitle: String? = nil,
         year: String? = nil) {
        self.id = id
        self.name = name
        self.coverURL = coverURL
        self.streamURL = streamURL
        self.groupTitle = groupTitle
        self.year = year
    }
}

struct Episode: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let streamURL: String
    let season: Int
    let number: Int
}

struct Series: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let coverURL: String?
    let groupTitle: String?
    var episodes: [Episode]

    var seasons: [Int] { Array(Set(episodes.map { $0.season })).sorted() }
    func episodes(inSeason s: Int) -> [Episode] {
        episodes.filter { $0.season == s }.sorted { $0.number < $1.number }
    }
}

/// A parsed M3U list split into the three content kinds the app shows.
struct ParsedPlaylist {
    var channels: [Channel] = []
    var movies: [Movie] = []
    var series: [Series] = []

    var isEmpty: Bool { channels.isEmpty && movies.isEmpty && series.isEmpty }
}

// MARK: - Favorite reference (kind + id so we can resolve across lists)

enum FavoriteKind: String, Codable { case channel, movie, series }

struct FavoriteRef: Codable, Hashable {
    let kind: FavoriteKind
    let id: String
}
