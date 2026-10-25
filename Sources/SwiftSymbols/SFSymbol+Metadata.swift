/// Apple's access classification. Public status is not blanket usage permission.
public enum SFSymbolAccessLevel: Hashable, Sendable {
    case publicModifiable
    case publicNonmodifiable
    case unrecognized(String)

    internal init(source: String) {
        switch source {
        case "Public": self = .publicModifiable
        case "Public - Non Modifiable": self = .publicNonmodifiable
        default: self = .unrecognized(source)
        }
    }
}

public struct SFSymbolUsageRestriction: Hashable, Sendable {
    public let message: String
}

extension SFSymbol {
    internal var record: SymbolRecord? { Catalog.record(rawValue) }

    public var isKnown: Bool { record != nil }
    public var availability: SFSymbolAvailability? {
        record.map { GeneratedCatalog.availabilities[$0.availabilityIndex] }
    }

    /// Catalog-based validation, not a live image-rendering probe.
    public var isAvailableOnCurrentOS: Bool { availability?.supportsCurrentOS ?? false }

    /// Accepts exact, known, current-OS names. Does not normalize spelling or reject restrictions.
    public init?(tryFromRawValue rawValue: String) {
        self.init(rawValue: rawValue)
        guard isAvailableOnCurrentOS else { return nil }
    }

    /// Returns self for canonical known names, nil for unknown names.
    public var canonicalSymbol: SFSymbol? {
        guard let record else { return nil }
        let name = record.canonicalName ?? rawValue
        return Catalog.record(name) == nil ? nil : SFSymbol(rawValue: name)
    }

    public var isAlias: Bool { record?.canonicalName != nil }

    /// Other alias names resolving to the same canonical symbol; excludes self.
    public var aliases: [SFSymbol] {
        guard let canonical = canonicalSymbol else { return [] }
        return (Catalog.aliases[canonical.rawValue] ?? [])
            .filter { $0 != rawValue }.map(SFSymbol.init(rawValue:))
    }

    public var categories: [SFSymbolCategory] {
        (record?.categories ?? []).map(SFSymbolCategory.init(rawValue:))
    }

    /// Deduplicated basic, enhanced, embedded, and function search terms.
    /// Function tags are merged here, not exposed as a separate property.
    public var searchKeywords: [String] { record?.searchKeywords ?? [] }

    /// Nil means the snapshot has no classification for this name.
    public var accessLevel: SFSymbolAccessLevel? {
        record?.accessLevel.map(SFSymbolAccessLevel.init(source:))
    }

    /// Nil means no known symbol-specific warning, not unrestricted permission.
    public var usageRestriction: SFSymbolUsageRestriction? {
        record?.restrictionIndex.map { SFSymbolUsageRestriction(message: GeneratedCatalog.restrictions[$0]) }
    }

    public var hasKnownUsageRestriction: Bool { usageRestriction != nil }

    /// All recognized names, including aliases and explicit localizations, on every OS version.
    public static let allKnownSymbols: Set<SFSymbol> = Set(
        GeneratedCatalog.records.map { SFSymbol(rawValue: $0.name) })

    /// Current-OS, canonical, base-localization names for the default chooser catalog.
    public static let allSymbols: Set<SFSymbol> = Set(GeneratedCatalog.records.compactMap { record in
        guard record.canonicalName == nil, record.localization == nil,
              GeneratedCatalog.availabilities[record.availabilityIndex].supportsCurrentOS else { return nil }
        return SFSymbol(rawValue: record.name)
    })
}
