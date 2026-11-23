import Foundation

// The language the interface is in.
//
// English is the source: each string in the code is its own key, and
// Localization/<language>.lproj/Localizable.strings holds the other
// languages (build.sh copies them into the app). Text("…") and
// String(localized: "…") look there by themselves; this is for the few places
// that have to say the language out loud.
enum Wording {
    /// The first of the Mac's languages the app has words for, else English
    /// (CFBundleDevelopmentRegion). "zh-Hant" for a Mac in Traditional Chinese.
    static let language = Bundle.main.preferredLocalizations.first ?? "en"

    /// The interface's language with the person's own region, for views that
    /// set a locale of their own: dates and numbers stay theirs, the words
    /// and the symbols drawn per language (textformat.size) match.
    static var locale: Locale {
        var parts = Locale.Language.Components(identifier: language)
        parts.region = Locale.current.region
        return Locale(languageComponents: parts)
    }

    /// English kept where it is stored or handed on, translated only where
    /// it is drawn: a tab's failure, which an agent also reads.
    static func shown(_ english: String) -> String {
        Bundle.main.localizedString(forKey: english, value: nil, table: nil)
    }
}
