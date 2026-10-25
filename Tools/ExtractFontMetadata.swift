// Development-only extraction tool, verified with SF Symbols 27.0 (140) on arm64 macOS.
// Uses the installed app's undocumented decoder; not compiled into SwiftSymbols.
// The Swift ABI entry point is version-specific. Review it before using another app build.
import Foundation
import CoreText
import Darwin

guard CommandLine.arguments.count == 3 else { fatalError("Usage: extract /path/to/SF-Symbols.app /path/to/output.csv") }
let app = URL(fileURLWithPath: CommandLine.arguments[1])
let framework = app.appendingPathComponent("Contents/Frameworks/CoreGlyphsLib.framework/Versions/A/CoreGlyphsLib").path
guard let library = dlopen(framework, RTLD_NOW | RTLD_LOCAL) else { fatalError(String(cString: dlerror())) }
let symbol = "$s13CoreGlyphsLib7CryptonV26decryptObfuscatedFontTable8tableTag4from10Foundation4DataVSgs6UInt32V_So9CTFontRefatFZ"
guard let address = dlsym(library, symbol) else { fatalError("Missing reader") }
let read = unsafeBitCast(address, to: (@convention(thin) (UInt32, CTFont) -> Data?).self)
let url = app.appendingPathComponent("Contents/Resources/Fonts/SFSymbolsFallback.otf")
guard let descriptors = CTFontManagerCreateFontDescriptorsFromURL(url as CFURL) as? [CTFontDescriptor], let descriptor = descriptors.first else { fatalError("Missing font") }
let font = CTFontCreateWithFontDescriptor(descriptor, 16, nil)
let tag = "symp".utf8.reduce(UInt32(0)) { ($0 << 8) | UInt32($1) }
guard let data = read(tag, font) else { fatalError("No metadata") }
try data.write(to: URL(fileURLWithPath: CommandLine.arguments[2]), options: .withoutOverwriting)
print("Decoded metadata bytes:", data.count)

