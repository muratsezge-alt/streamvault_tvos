import SwiftUI

/// Poster-style card for movies and series (portrait) — larger, premium.
struct PosterCard: View {
    let title: String
    let imageURL: String?
    let subtitle: String?
    var theme: AppTheme

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 16, style: .continuous).fill(theme.surface)
                AsyncImage(url: URL(string: imageURL ?? "")) { phase in
                    switch phase {
                    case .success(let img): img.resizable().scaledToFill()
                    default:
                        Image(systemName: "film").font(.system(size: 60)).foregroundStyle(theme.textSecondary)
                    }
                }
            }
            .frame(width: 280, height: 400)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(theme.gold.opacity(0.18), lineWidth: 1))

            Text(title).font(.headline).foregroundStyle(theme.textPrimary)
                .lineLimit(1).frame(width: 280, alignment: .leading)
            if let subtitle {
                Text(subtitle).font(.subheadline).foregroundStyle(theme.textSecondary)
                    .frame(width: 280, alignment: .leading)
            }
        }
    }
}

/// Landscape card for live channels — larger, premium.
struct ChannelCard: View {
    let name: String
    let logoURL: String?
    var theme: AppTheme

    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(LinearGradient(colors: [theme.surface, theme.backgroundSecondary],
                                         startPoint: .top, endPoint: .bottom))
                AsyncImage(url: URL(string: logoURL ?? "")) { phase in
                    switch phase {
                    case .success(let img): img.resizable().scaledToFit().padding(24)
                    default:
                        Image(systemName: "tv").font(.system(size: 52)).foregroundStyle(theme.textSecondary)
                    }
                }
            }
            .frame(width: 320, height: 190)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(theme.gold.opacity(0.18), lineWidth: 1))

            Text(name).font(.headline).foregroundStyle(theme.textPrimary)
                .lineLimit(1).frame(width: 320)
        }
    }
}

struct SectionTitle: View {
    let text: String
    var theme: AppTheme
    var body: some View {
        Text(text).font(.title2.weight(.semibold))
            .foregroundStyle(theme.textPrimary)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}
