import SwiftUI

/// Brand colors used across launch/onboarding (fixed, theme-independent).
enum Brand {
    static let navyTop = Color(hex: 0x112442)
    static let navyBottom = Color(hex: 0x0A172A)
    static let gold = Color(hex: 0xD4A838)
    static let goldSoft = Color(hex: 0xE8C66A)
    static let textPrimary = Color(hex: 0xF2EFE6)
    static let textSecondary = Color(hex: 0x9AA6BF)

    static var backgroundGradient: LinearGradient {
        LinearGradient(colors: [navyTop, navyBottom],
                       startPoint: .top, endPoint: .bottom)
    }
}

struct SplashView: View {
    @State private var appear = false
    @State private var glow = false

    var body: some View {
        ZStack {
            Brand.backgroundGradient.ignoresSafeArea()

            // Subtle radial glow behind the logo
            RadialGradient(colors: [Brand.gold.opacity(0.18), .clear],
                           center: .center, startRadius: 10, endRadius: 420)
                .scaleEffect(glow ? 1.1 : 0.9)
                .ignoresSafeArea()

            VStack(spacing: 28) {
                Image("AppLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 240, height: 240)
                    .clipShape(RoundedRectangle(cornerRadius: 44, style: .continuous))
                    .shadow(color: Brand.gold.opacity(0.35), radius: 40, y: 12)
                    .scaleEffect(appear ? 1 : 0.82)
                    .opacity(appear ? 1 : 0)

                VStack(spacing: 10) {
                    Text("StreamVault")
                        .font(.system(size: 64, weight: .bold, design: .rounded))
                        .foregroundStyle(Brand.textPrimary)
                    Text("ULTRA PREMIUM IPTV")
                        .font(.system(size: 20, weight: .semibold))
                        .tracking(8)
                        .foregroundStyle(Brand.gold)
                }
                .opacity(appear ? 1 : 0)
                .offset(y: appear ? 0 : 16)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.9)) { appear = true }
            withAnimation(.easeInOut(duration: 2.2).repeatForever(autoreverses: true)) { glow = true }
        }
    }
}
