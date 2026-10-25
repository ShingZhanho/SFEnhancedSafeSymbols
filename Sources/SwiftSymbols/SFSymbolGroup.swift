/// One Apple group-map entry. The ID need not itself be a valid symbol name.
public struct SFSymbolGroup: Hashable, Sendable, Identifiable, CaseIterable {
    public let id: String

    public init?(id: String) {
        guard Catalog.groupByID[id] != nil else { return nil }
        self.id = id
    }

    internal init(knownID: String) { self.id = knownID }

    public static var allCases: [Self] {
        GeneratedCatalog.groups.map { Self(knownID: $0.id) }
    }

    /// A known symbol matching the group key, whether or not it is available on this OS.
    public var baseSymbol: SFSymbol? {
        Catalog.record(id) == nil ? nil : SFSymbol(rawValue: id)
    }

    /// Exact known members recorded by Apple, including the base if it exists.
    public var members: [SFSymbol] {
        (Catalog.groupByID[id]?.members ?? []).map(SFSymbol.init(rawValue:))
    }

    public var availableMembers: [SFSymbol] { members.filter(\.isAvailableOnCurrentOS) }

    /// Nil when this OS has no known available member.
    public var representativeSymbol: SFSymbol? {
        if let base = baseSymbol, base.isAvailableOnCurrentOS { return base }
        return availableMembers.first
    }
}

public enum SFSymbolGrouping: Hashable, Sendable {
    case base(SFSymbolGroup)
    case variant(SFSymbolGroup)
    case ungrouped
}

public enum SFSymbolBrowserItem: Hashable, Sendable {
    case group(SFSymbolGroup)
    case standalone(SFSymbol)
}

extension SFSymbol {
    /// Exact membership, then verified canonical/base-localization membership.
    public var group: SFSymbolGroup? {
        record?.groupID.map(SFSymbolGroup.init(knownID:))
    }

    /// True only when this exact known name is a group-map key.
    public var isBaseSymbol: Bool { isKnown && Catalog.groupByID[rawValue] != nil }

    public var grouping: SFSymbolGrouping {
        guard let group else { return .ungrouped }
        return isBaseSymbol ? .base(group) : .variant(group)
    }

    /// Every default-catalog symbol is represented by one group or a standalone entry.
    public static let browserItems: [SFSymbolBrowserItem] = {
        var seen: Set<String> = []
        var items: [SFSymbolBrowserItem] = []
        for symbol in allSymbols.sorted(by: { $0.rawValue < $1.rawValue }) {
            if let group = symbol.group {
                if seen.insert(group.id).inserted { items.append(.group(group)) }
            } else {
                items.append(.standalone(symbol))
            }
        }
        return items
    }()
}
