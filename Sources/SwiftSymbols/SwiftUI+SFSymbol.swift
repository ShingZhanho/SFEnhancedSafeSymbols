#if canImport(SwiftUI)
import SwiftUI

extension Image {
    public init(systemSymbol: SwiftSymbols) {
        self.init(systemName: systemSymbol.rawValue)
    }

    @available(iOS 16, macOS 13, tvOS 16, watchOS 9, *)
    public init(systemSymbol: SwiftSymbols, variableValue: Double?) {
        self.init(systemName: systemSymbol.rawValue, variableValue: variableValue)
    }
}

@available(iOS 14, macOS 11, tvOS 14, watchOS 7, *)
extension Label where Title == Text, Icon == Image {
    public init(_ titleKey: LocalizedStringKey, systemSymbol: SwiftSymbols) {
        self.init(titleKey, systemImage: systemSymbol.rawValue)
    }

    public init<S: StringProtocol>(_ title: S, systemSymbol: SwiftSymbols) {
        self.init(title, systemImage: systemSymbol.rawValue)
    }
}
#endif
