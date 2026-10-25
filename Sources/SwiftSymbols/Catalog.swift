/// Generated values are compiled into the library. No runtime catalog file or decoder.
internal enum Catalog {
    static let byName: [String: Int] = Dictionary(uniqueKeysWithValues:
        GeneratedCatalog.records.enumerated().map { ($0.element.name, $0.offset) })

    static func record(_ name: String) -> SymbolRecord? {
        byName[name].map { GeneratedCatalog.records[$0] }
    }

    static let aliases: [String: [String]] = {
        var result: [String: [String]] = [:]
        for record in GeneratedCatalog.records where record.canonicalName != nil {
            result[record.canonicalName!, default: []].append(record.name)
        }
        return result
    }()

    static let localizations: [String: [String: String]] = {
        var result: [String: [String: String]] = [:]
        for record in GeneratedCatalog.records {
            if let base = record.baseLocalizationName, let locale = record.localization {
                result[base, default: [:]][locale] = record.name
            }
        }
        return result
    }()

    static let groupByID: [String: GroupRecord] = Dictionary(uniqueKeysWithValues:
        GeneratedCatalog.groups.map { ($0.id, $0) })
}

internal struct SymbolRecord: Sendable {
    let name: String
    let availabilityIndex: Int
    let categories: [String]
    let searchKeywords: [String]
    let accessLevel: String?
    let restrictionIndex: Int?
    let canonicalName: String?
    let baseLocalizationName: String?
    let localization: String?
    let groupID: String?
}

internal struct CategoryRecord: Sendable {
    let id: String
    let label: String
    let icon: String
}

internal struct GroupRecord: Sendable {
    let id: String
    let members: [String]
}
