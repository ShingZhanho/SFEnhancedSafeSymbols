import Foundation

/// Content categories only; special sidebar filters are not categories.
public struct SFSymbolCategory: RawRepresentable, Hashable, Sendable, CaseIterable {
    public let rawValue: String
    public init(rawValue: String) { self.rawValue = rawValue }

    public static var allCases: [Self] {
        GeneratedCatalog.categories.map { Self(rawValue: $0.id) }
    }

    private var record: CategoryRecord? {
        GeneratedCatalog.categories.first { $0.id == rawValue }
    }

    public var displayName: String {
        Bundle.module.localizedString(forKey: "category." + rawValue,
                                      value: record?.label ?? rawValue, table: "Categories")
    }

    public func displayName(locale: Locale) -> String {
        let preferred = Bundle.preferredLocalizations(from: Bundle.module.localizations,
            forPreferences: [locale.identifier.replacingOccurrences(of: "_", with: "-"), "en"])
        guard let language = preferred.first,
              let path = Bundle.module.path(forResource: language, ofType: "lproj"),
              let bundle = Bundle(path: path) else { return record?.label ?? rawValue }
        return bundle.localizedString(forKey: "category." + rawValue,
                                      value: record?.label ?? rawValue, table: "Categories")
    }

    /// The sidebar icon. Unknown categories use a generic grid; availability is not implied.
    public var icon: SwiftSymbols { SwiftSymbols(rawValue: record?.icon ?? "square.grid.2x2") }

    public var symbols: Set<SwiftSymbols> {
        SwiftSymbols.allSymbols.filter { $0.categories.contains(self) }
    }
}
