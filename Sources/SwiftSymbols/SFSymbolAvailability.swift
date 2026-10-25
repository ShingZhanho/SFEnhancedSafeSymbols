import Foundation

/// A numeric OS version, ordered by major, minor, then patch.
public struct SFSymbolOSVersion: Hashable, Comparable, Sendable, Codable, CustomStringConvertible {
    public let major: Int
    public let minor: Int
    public let patch: Int

    public init(major: Int, minor: Int = 0, patch: Int = 0) {
        precondition(major >= 0 && minor >= 0 && patch >= 0)
        self.major = major
        self.minor = minor
        self.patch = patch
    }

    public static func < (lhs: Self, rhs: Self) -> Bool {
        (lhs.major, lhs.minor, lhs.patch) < (rhs.major, rhs.minor, rhs.patch)
    }

    public var description: String {
        patch == 0 ? "\(major).\(minor)" : "\(major).\(minor).\(patch)"
    }
}

/// Deprecation records a later replacement name, not symbol removal.
public struct SFSymbolPlatformAvailability: Hashable, Sendable {
    public let introduced: SFSymbolOSVersion
    public let deprecated: SFSymbolOSVersion?
}

/// Availability of an exact raw name, including its localization suffix.
public struct SFSymbolAvailability: Hashable, Sendable {
    public let iOS: SFSymbolPlatformAvailability?
    public let macOS: SFSymbolPlatformAvailability?
    public let tvOS: SFSymbolPlatformAvailability?
    public let watchOS: SFSymbolPlatformAvailability?
    public let visionOS: SFSymbolPlatformAvailability?

    internal var supportsCurrentOS: Bool {
        let platform: SFSymbolPlatformAvailability?
        #if targetEnvironment(macCatalyst)
        platform = macOS
        #elseif os(visionOS)
        platform = visionOS
        #elseif os(iOS)
        platform = iOS
        #elseif os(macOS)
        platform = macOS
        #elseif os(tvOS)
        platform = tvOS
        #elseif os(watchOS)
        platform = watchOS
        #else
        platform = nil
        #endif
        guard let platform else { return false }
        let version = ProcessInfo.processInfo.operatingSystemVersion
        return SFSymbolOSVersion(major: version.majorVersion, minor: version.minorVersion,
                                 patch: version.patchVersion) >= platform.introduced
    }
}
