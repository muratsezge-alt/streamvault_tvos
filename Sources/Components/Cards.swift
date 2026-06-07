import SwiftUI

/// Poster-style card for movies and series (portrait).
struct PosterCard: View {
    let title: String
    let imageURL: String?
    let subtitle: String?
    var theme: AppTheme

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(theme.surface)
                AsyncImage(url: URL(string: imageURL ?? "")) { phase in
                    switch phase {
                    case .success(let img): img.resizable().scaledToFill()
                    default:
                        Image(systemName: "film")
                            .font(.system(size: 50))
                            .foregroundStyle(theme.textSecondary)
                    }
                }
            }
            .frame(width: 220, height: 320)
            .clipShape(RoundedRectangle(cornerRadius: 12))

            Text(title)
                .font(.caption)
                .foregroundStyle(theme.textPrimary)
                .lineLimit(1)
                .frame(width: 220, alignment: .leading)
            if let subtitle {
                Text(subtitle)
                    .font(.caption2)
                    .foregroundStyle(theme.textSecondary)
                    .frame(width: 220, alignment: .leading)
            }
        }
    }
}

/// Landscape-ish card for live channels.
struct ChannelCard: View {
    let name: String
    let logoURL: String?
    var theme: AppTheme

    var body: some View {
        VStack(spacing: 10) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(theme.surface)
                AsyncImage(url: URL(string: logoURL ?? "")) { phase in
                    switch phase {
                    case .success(let img): img.resizable().scaledToFit().padding(20)
                    default:
                        Image(systemName: "tv")
                            .font(.system(size: 44))
                            .foregroundStyle(theme.textSecondary)
                    }
                }
            }
            .frame(width: 260, height: 150)
            .clipShape(RoundedRectangle(cornerRadius: 12))

            Text(name)
                .font(.caption)
                .foregroundStyle(theme.textPrimary)
                .lineLimit(1)
                .frame(width: 260)
        }
    }
}

/// A horizontal/grid section header.
struct SectionTitle: View {
    let text: String
    var theme: AppTheme
    var body: some View {
        Text(text)
            .font(.title2.weight(.semibold))
            .foregroundStyle(theme.textPrimary)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}
