# SwiftSymbols

A standalone, generated SF Symbols catalog for SwiftUI, with typed symbol names and metadata for building symbol choosers. No package dependencies, runtime font parsing, or test target.

## Installation

Add `https://github.com/ShingZhanho/SwiftSymbols` in Xcode, or declare:

```swift
.package(url: "https://github.com/ShingZhanho/SwiftSymbols", from: "7.0.0")
```

Add `.product(name: "SwiftSymbols", package: "SwiftSymbols")` to your target dependencies. Requires Swift 5.9 and iOS 13, macOS 11, tvOS 13, watchOS 6, or visionOS 1 or later. Individual symbol properties carry their own availability annotations.

```swift
import SwiftUI
import SwiftSymbols

let symbol: SwiftSymbols = .heartFill
Image(systemSymbol: symbol)
Label("Favorite", systemSymbol: .heartFill) // iOS 14 or later

if let symbol = SwiftSymbols(tryFromRawValue: userInput) {
    print(symbol.searchKeywords)
}
```

The module and main value type are both named `SwiftSymbols`. Named constants use lower camel case, such as `.personFillBadgePlus`; names starting with a number have an underscore prefix. `rawValue` preserves Apple's exact name. Values are hashable, sendable, and Codable as a single string.

## Symbol metadata

| API | Meaning |
| --- | --- |
| `rawValue` | Exact system symbol name |
| `isKnown` | Present in this snapshot |
| `availability` | Optional introduction and inferred rename-deprecation versions for iOS, macOS, tvOS, watchOS, and visionOS |
| `isAvailableOnCurrentOS` | Snapshot-based OS availability check |
| `canonicalSymbol`, `isAlias`, `aliases` | Current rename relationships |
| `categories` | Content categories in Apple's app |
| `searchKeywords` | Basic, enhanced, embedded search terms and **Functions**, trimmed and deduplicated case-insensitively |
| `accessLevel` | `.publicModifiable`, `.publicNonmodifiable`, an unrecognized source value, or no classification |
| `usageRestriction`, `hasKnownUsageRestriction` | Symbol-specific warning message, when known |
| `localization`, `baseLocalizationSymbol` | Explicit script/direction suffix and its known base |
| `availableLocalizations`, `localized(to:)` | Available explicit localization variants |
| `group`, `grouping`, `isBaseSymbol` | Apple group-map membership and whether this exact name is a real group key |

```swift
let symbol = SwiftSymbols.heartFill
let keywords = symbol.searchKeywords // Includes function tags such as "love".
let introduced = symbol.availability?.iOS?.introduced
let warning = symbol.usageRestriction?.message
let arabic = SwiftSymbols.character.localized(to: .arabic)
```

`SwiftSymbols(rawValue:)` accepts any string without validation. `SwiftSymbols(tryFromRawValue:)` requires an exact known name available on the running OS; it does not normalize spelling or reject restricted symbols. Decoding behaves like `rawValue:`. Unknown values have empty metadata collections and nil optional metadata. Availability is not a live rendering probe. Deprecation does not imply removal. macOS introduction dates have a minimum of 11 for this SwiftUI package.

No known restriction is **not** a grant of unrestricted usage. Access classifications and warning text preserve the captured metadata; consult Apple's applicable terms for usage permission.

## Categories and chooser groups

```swift
let categories = SFSymbolCategory.allCases
let weather = SFSymbolCategory.weather
let title = weather.displayName
let frenchTitle = weather.displayName(locale: Locale(identifier: "fr"))
let weatherSymbols = weather.symbols
let items = SwiftSymbols.browserItems

for item in items {
    switch item {
    case .group(let group):
        // Present its representative; offer availableMembers after selection.
        print(group.representativeSymbol?.rawValue ?? group.id)
    case .standalone(let symbol):
        print(symbol.rawValue)
    }
}
```

There are 27 content categories with labels in 39 localizations. Special sidebar filters such as All, New, Draw, Variable, and Multicolor are not content categories. A category also exposes its `icon`.

`allKnownSymbols` includes all 9,524 names across OS releases, aliases, and localizations. `allSymbols` contains current-OS canonical names without explicit localization suffixes. These collections are sets; sort them for a stable UI order.

`SFSymbolGroup.allCases` contains 1,841 Apple group-map entries. `baseSymbol` is present only when the group ID is itself a known symbol name. Two captured group keys have no matching symbol. `members` contains exact known members, including a valid base; `availableMembers` filters by current OS. `representativeSymbol` prefers an available base, then an available member. Groups can contain symbols that cannot be obtained through SwiftUI modifiers, and a group key is not necessarily an outline symbol.

`browserItems` gives a deterministic list of groups and remaining standalone symbols, covering the default chooser catalog. Grouping is not exhaustive in Apple's source, so ungrouped symbols remain visible. This release does not infer arbitrary outline/fill or enclosure transformations from string suffixes.

## Snapshot and generation

**Package release `7.0.0` is the requested replacement release. Its captured source is SF Symbols app `27.0` (build `140`), not an SF Symbols 7-only catalog.** `SwiftSymbolsMetadata` exposes `sourceVersion`, `sourceBuild`, `catalogVersion`, `symbolCount`, and `snapshotSHA256` separately.

`Metadata/Snapshot` includes the normalized app metadata, category translations, decoded fallback-font symbol metadata, and input provenance. The full symbol declarations and lookup records are generated Swift source, compiled with your application. Only category translations are runtime resources; there is no runtime JSON lookup or dependency on SFSafeSymbols.

Regenerate using Python 3, without an installed SF Symbols app or network access:

```sh
python3 Tools/generate_catalog.py
swift build
swift build -c release
```

To recapture the reviewed source on an Apple silicon Mac with the matching app installed:

```sh
python3 Tools/capture_snapshot.py
python3 Tools/generate_catalog.py
```

The development-only extractor uses the app's bundled internal table decoder. It is version-gated to the reviewed app build, is not part of the Swift package target, and is not called by consumer apps. Fonts and symbol artwork are not bundled. Updating the app build requires reviewing its decoder and metadata before changing the capture guard.

The generator validates duplicate Swift identifiers and overlapping groups. Current aliases are resolved independently of historical aliases because combining both generations can create cycles. Metadata falls back through verified canonical and base-localization names when exact-name metadata is absent. Search terms merge all available sources. No separate Functions property is exposed.

## Migration and licensing

This replaces the former `SFEnhancedSafeSymbols` package and its `7.0.0` tag with a new standalone history. Update the repository/product/import to `SwiftSymbols`, and replace the former `SFSymbol` value type with `SwiftSymbols`. Consumers of the previous tag must clear their old resolution and resolve the replacement deliberately.

Original package code is MIT licensed. Captured Apple data, translations, and symbol names retain their original ownership and are excluded from that license grant; see `THIRD_PARTY_NOTICES.md`.
