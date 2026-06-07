import Foundation

/// Parses raw M3U text into channels, then classifies entries into
/// Live / Movies / Series — mirroring the structure of the Flutter app,
/// which separated content by group-title and stream type.
///
/// Classification is heuristic (single-M3U lists have no formal type field).
/// Tune the keyword lists below as we see real data from your playlists.
enum M3UParser {

    // Raw entry straight off the #EXTINF line.
    private struct Entry {
        let name: String
        let logo: String?
        let group: String?
        let tvgID: String?
        let url: String
    }

    static func parse(_ content: String) -> ParsedPlaylist {
        let entries = rawEntries(from: content)
        return classify(entries)
    }

    // MARK: - Raw line parsing (ported from _parseM3UContent)

    private static func rawEntries(from content: String) -> [Entry] {
        var result: [Entry] = []
        var name: String?
        var logo: String?
        var group: String?
        var tvgID: String?

        for rawLine in content.components(separatedBy: "\n") {
            let line = rawLine.trimmingCharacters(in: .whitespacesAndNewlines)
            if line.hasPrefix("#EXTINF:") {
                name = attribute(line, "tvg-name") ?? displayName(line)
                logo = attribute(line, "tvg-logo")
                group = attribute(line, "group-title")
                tvgID = attribute(line, "tvg-id")
            } else if !line.isEmpty, !line.hasPrefix("#"), let n = name {
                result.append(Entry(name: n, logo: logo, group: group, tvgID: tvgID, url: line))
                name = nil; logo = nil; group = nil; tvgID = nil
            }
        }
        return result
    }

    private static func attribute(_ line: String, _ attr: String) -> String? {
        guard let regex = try? NSRegularExpression(pattern: "\(attr)=\"([^\"]*)\"") else { return nil }
        let range = NSRange(line.startIndex..., in: line)
        guard let m = regex.firstMatch(in: line, range: range),
              let r = Range(m.range(at: 1), in: line) else { return nil }
        let value = String(line[r])
        return value.isEmpty ? nil : value
    }

    private static func displayName(_ line: String) -> String {
        if let idx = line.lastIndex(of: ","), idx < line.index(before: line.endIndex) {
            return String(line[line.index(after: idx)...]).trimmingCharacters(in: .whitespaces)
        }
        return "Unknown"
    }

    // MARK: - Classification

    private static let movieKeywords = ["movie", "film", "vod", "cinema", "sinema"]
    private static let seriesKeywords = ["series", "dizi", "serie", "tv show", "show"]
    private static let movieExtensions = [".mp4", ".mkv", ".avi", ".mov"]

    // Matches "S01E02", "1x02", " S1 E2" style episode markers.
    private static let episodeRegex = try? NSRegularExpression(
        pattern: "[sS]\\s?(\\d{1,2})\\s?[eExX]\\s?(\\d{1,3})", options: [])

    private static func classify(_ entries: [Entry]) -> ParsedPlaylist {
        var out = ParsedPlaylist()
        var seriesBuckets: [String: Series] = [:]

        for e in entries {
            let g = (e.group ?? "").lowercased()
            let lowerName = e.name.lowercased()
            let lowerURL = e.url.lowercased()
            let looksLikeFile = movieExtensions.contains { lowerURL.contains($0) }
            let groupIsSeries = seriesKeywords.contains { g.contains($0) }
            let groupIsMovie = movieKeywords.contains { g.contains($0) }

            if let ep = episodeInfo(e.name), (groupIsSeries || looksLikeFile || groupIsMovie) {
                // Series episode → bucket by show name (text before the SxxExx marker)
                let showName = showTitle(from: e.name)
                let key = showName.lowercased()
                var series = seriesBuckets[key] ?? Series(
                    id: UUID().uuidString, name: showName,
                    coverURL: e.logo, groupTitle: e.group, episodes: [])
                series.episodes.append(Episode(
                    id: UUID().uuidString, name: e.name, streamURL: e.url,
                    season: ep.season, number: ep.episode))
                seriesBuckets[key] = series
            } else if groupIsMovie || (looksLikeFile && !groupIsSeries) {
                out.movies.append(Movie(
                    name: e.name, coverURL: e.logo, streamURL: e.url,
                    groupTitle: e.group, year: yearIn(e.name)))
            } else {
                out.channels.append(Channel(
                    name: e.name, logoURL: e.logo, streamURL: e.url,
                    groupTitle: e.group, tvgID: e.tvgID))
            }
        }
        out.series = Array(seriesBuckets.values).sorted { $0.name < $1.name }
        return out
    }

    private static func episodeInfo(_ name: String) -> (season: Int, episode: Int)? {
        guard let regex = episodeRegex else { return nil }
        let range = NSRange(name.startIndex..., in: name)
        guard let m = regex.firstMatch(in: name, range: range),
              let sR = Range(m.range(at: 1), in: name),
              let eR = Range(m.range(at: 2), in: name),
              let s = Int(name[sR]), let ep = Int(name[eR]) else { return nil }
        return (s, ep)
    }

    private static func showTitle(from name: String) -> String {
        guard let regex = episodeRegex else { return name }
        let range = NSRange(name.startIndex..., in: name)
        if let m = regex.firstMatch(in: name, range: range),
           let r = Range(m.range, in: name) {
            let prefix = String(name[..<r.lowerBound])
            let cleaned = prefix.trimmingCharacters(in: CharacterSet(charactersIn: " -_.|"))
            return cleaned.isEmpty ? name : cleaned
        }
        return name
    }

    private static func yearIn(_ name: String) -> String? {
        guard let regex = try? NSRegularExpression(pattern: "(19|20)\\d{2}") else { return nil }
        let range = NSRange(name.startIndex..., in: name)
        guard let m = regex.firstMatch(in: name, range: range),
              let r = Range(m.range, in: name) else { return nil }
        return String(name[r])
    }
}
