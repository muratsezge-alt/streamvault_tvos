import SwiftUI

extension Color {
    init(hex: UInt32) {
        self.init(.sRGB,
                  red: Double((hex >> 16) & 0xFF) / 255,
                  green: Double((hex >> 8) & 0xFF) / 255,
                  blue: Double(hex & 0xFF) / 255,
                  opacity: 1)
    }
}

/// 4 dark theme variants, ported from app_theme_variants.dart.
enum AppTheme: String, CaseIterable, Identifiable {
    case navy, obsidian, forest, bordeaux
    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .navy: return "Navy"
        case .obsidian: return "Obsidian"
        case .forest: return "Orman"
        case .bordeaux: return "Bordo"
        }
    }

    var description: String {
        switch self {
        case .navy: return "Varsayılan lacivert, premium his"
        case .obsidian: return "Saf siyah, AMOLED için ideal"
        case .forest: return "Derin yeşil, doğal tonlar"
        case .bordeaux: return "Şarap kırmızısı, sinematik"
        }
    }

    var background: Color {
        switch self {
        case .navy: return Color(hex: 0x050B18)
        case .obsidian: return Color(hex: 0x000000)
        case .forest: return Color(hex: 0x0A1410)
        case .bordeaux: return Color(hex: 0x140509)
        }
    }

    var backgroundSecondary: Color {
        switch self {
        case .navy: return Color(hex: 0x0A1628)
        case .obsidian: return Color(hex: 0x0A0A0A)
        case .forest: return Color(hex: 0x0F1F18)
        case .bordeaux: return Color(hex: 0x1C0910)
        }
    }

    var surface: Color {
        switch self {
        case .navy: return Color(hex: 0x0D2347)
        case .obsidian: return Color(hex: 0x1A1A1A)
        case .forest: return Color(hex: 0x163A28)
        case .bordeaux: return Color(hex: 0x2D0E16)
        }
    }

    var ambient: Color {
        switch self {
        case .navy: return Color(hex: 0x4A90E2)
        case .obsidian: return Color(hex: 0xD4AF37)
        case .forest: return Color(hex: 0x2E8B57)
        case .bordeaux: return Color(hex: 0x8B2635)
        }
    }

    /// Shared premium gold accent across all themes.
    var gold: Color { Color(hex: 0xD4AF37) }
    var textPrimary: Color { Color(hex: 0xE8E4D8) }
    var textSecondary: Color { Color(hex: 0xB8B0A0) }
}
