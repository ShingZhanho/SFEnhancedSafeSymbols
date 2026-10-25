# SwiftSymbols

Typed SF Symbols for SwiftUI, with categories, search keywords, availability, and metadata for building symbol choosers. No package dependencies.

## Installation

Add this package in Xcode using `https://github.com/ShingZhanho/SwiftSymbols`, or add it to your `Package.swift`:

```swift
.package(url: "https://github.com/ShingZhanho/SwiftSymbols", from: "7.0.0")
```

Add `.product(name: "SwiftSymbols", package: "SwiftSymbols")` to your target's dependencies.

Requires Swift 5.9 and iOS 13, macOS 11, tvOS 13, watchOS 6, or visionOS 1 or later. Individual symbols carry availability annotations.

## Usage

```swift
import SwiftUI
import SwiftSymbols

let symbol: SwiftSymbols = .heartFill

Image(systemSymbol: symbol)
Label("Favorite", systemSymbol: .heartFill) // iOS 14 or later

print(symbol.rawValue) // "heart.fill"
```

Symbol names use lower camel case: `person.fill.badge.plus` becomes `.personFillBadgePlus`. Names starting with a number have an underscore prefix. Values conform to `Hashable`, `Sendable`, and `Codable`.

For names supplied at runtime:

```swift
if let symbol = SwiftSymbols(tryFromRawValue: "heart.fill") {
    Image(systemSymbol: symbol)
}
```

The failable initializer requires an exact catalog name available on the current OS. `SwiftSymbols(rawValue:)` accepts any string without validation. Availability checks use the bundled catalog rather than attempting to render an image.

## Metadata

```swift
let symbol = SwiftSymbols.heartFill

symbol.categories
symbol.searchKeywords
symbol.availability?.iOS?.introduced
symbol.usageRestriction?.message

let arabic = SwiftSymbols.character.localized(to: .arabic)
```

| Properties | Information |
| --- | --- |
| `isKnown`, `isAvailableOnCurrentOS` | Catalog membership and OS availability |
| `availability` | Per-platform introduction and inferred rename-deprecation versions |
| `categories`, `searchKeywords` | Content categories and deduplicated search terms |
| `accessLevel`, `usageRestriction` | Apple's access classification and known usage warning |
| `canonicalSymbol`, `isAlias`, `aliases` | Symbol rename relationships |
| `localization`, `baseLocalizationSymbol`, `availableLocalizations` | Explicit script and direction variants |
| `group`, `grouping`, `isBaseSymbol` | Group membership and base-symbol status |

Missing metadata is returned as `nil` or an empty collection. A missing usage warning does not imply unrestricted permission to use a symbol; Apple's terms still apply.

## Building a symbol chooser

Use `SwiftSymbols.allSymbols` for current-OS canonical symbols without explicit localization variants. `allKnownSymbols` includes every catalog name, including aliases, localizations, and symbols requiring newer OS versions. Both are sets; sort them when displaying a list.

Categories include localized names, sidebar icons, and their symbols:

```swift
let categories = SFSymbolCategory.allCases
let weather = SFSymbolCategory.weather

weather.displayName
weather.icon
weather.symbols
```

To show related symbols together, use `browserItems`:

```swift
for item in SwiftSymbols.browserItems {
    switch item {
    case .group(let group):
        // Display representativeSymbol; offer availableMembers for selection.
        print(group.representativeSymbol?.rawValue ?? group.id)
    case .standalone(let symbol):
        print(symbol.rawValue)
    }
}
```

Groups expose `baseSymbol`, `members`, and `availableMembers`. Some groups have no matching base symbol, so `baseSymbol` is optional. Group members are related symbols, not necessarily variants obtainable through SwiftUI modifiers. Ungrouped symbols remain available as standalone entries.

## Catalog coverage

Includes 9,524 names, 27 categories, and category labels in 39 languages, captured from SF Symbols app 27.0 (build 140). The package version and source-app version are separate; inspect `SwiftSymbolsMetadata` for catalog provenance. macOS introduction versions are floored at 11 for SwiftUI support.

## License

Original package code is [MIT licensed](LICENSE). Apple-origin metadata and translations are excluded from that grant. See [third-party notices](THIRD_PARTY_NOTICES.md).
