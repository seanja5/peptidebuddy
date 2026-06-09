import SwiftUI

extension Color {
    static let primaryBlue    = Color(hex: "2563EB")
    static let lightBlue      = Color(hex: "3B82F6")
    static let appBackground  = Color(hex: "FFFFFF")
    static let appSurface     = Color(hex: "F8FAFC")
    static let appBorder      = Color(hex: "E2E8F0")
    static let textPrimary    = Color(hex: "1E293B")
    static let textSecondary  = Color(hex: "64748B")
    static let textTertiary   = Color(hex: "94A3B8")
    static let splashBG       = Color(hex: "1D4ED8")
    static let splashText     = Color(hex: "E2E8F0")
    static let chipActive     = Color(hex: "2563EB")
    static let chipInactive   = Color(hex: "F1F5F9")

    init(hex: String) {
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r = Double((int >> 16) & 0xFF) / 255
        let g = Double((int >> 8)  & 0xFF) / 255
        let b = Double( int        & 0xFF) / 255
        self.init(.sRGB, red: r, green: g, blue: b, opacity: 1)
    }
}

enum DS {
    enum Radius {
        static let card: CGFloat    = 12
        static let chip: CGFloat    = 20
        static let avatar: CGFloat  = 40
        static let button: CGFloat  = 12
    }
    enum Spacing {
        static let xs: CGFloat  =  4
        static let sm: CGFloat  =  8
        static let md: CGFloat  = 16
        static let lg: CGFloat  = 24
        static let xl: CGFloat  = 32
    }
    enum Avatar {
        static let feed: CGFloat    = 40
        static let profile: CGFloat = 96
    }
}
