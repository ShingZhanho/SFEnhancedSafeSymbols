/// An explicit script or direction suffix from Apple's metadata, not the UI language.
public struct SFSymbolLocalization: RawRepresentable, Hashable, Sendable, CaseIterable {
    public let rawValue: String
    public init(rawValue: String) { self.rawValue = rawValue }
    public static var allCases: [Self] {
        GeneratedCatalog.localizationSuffixes.map(Self.init(rawValue:))
    }
}

extension SFSymbol {
    public var localization: SFSymbolLocalization? {
        record?.localization.map(SFSymbolLocalization.init(rawValue:))
    }

    /// Returns self for an already-unlocalized known name, nil if no known base exists.
    public var baseLocalizationSymbol: SFSymbol? {
        guard let record else { return nil }
        if record.localization == nil { return self }
        return record.baseLocalizationName.map(SFSymbol.init(rawValue:))
    }

    public var availableLocalizations: [SFSymbolLocalization] {
        guard let base = baseLocalizationSymbol else { return [] }
        return (Catalog.localizations[base.rawValue] ?? [:]).compactMap { locale, name in
            SFSymbol(rawValue: name).isAvailableOnCurrentOS ? SFSymbolLocalization(rawValue: locale) : nil
        }.sorted { $0.rawValue < $1.rawValue }
    }

    /// Returns the available exact localized variant, replacing an existing explicit locale.
    public func localized(to localization: SFSymbolLocalization) -> SFSymbol? {
        guard let base = baseLocalizationSymbol,
              let name = Catalog.localizations[base.rawValue]?[localization.rawValue] else { return nil }
        return SFSymbol(tryFromRawValue: name)
    }
}
