import AppKit
import XCTest
import BobukUI
@testable import SplashFinish

final class AppearanceTests: XCTestCase {
    private func red(of color: NSColor, in name: NSAppearance.Name) throws -> Double {
        var red = -1.0
        try XCTUnwrap(NSAppearance(named: name)).performAsCurrentDrawingAppearance {
            red = Double(color.usingColorSpace(.sRGB)?.redComponent ?? -1)
        }
        return red
    }

    func testSplashInkStaysWhiteInTheDarkTheme() throws {
        XCTAssertEqual(try red(of: .panelInk, in: .aqua), Double(0x22) / 255, accuracy: 0.001)
        XCTAssertEqual(try red(of: .panelInk, in: .darkAqua), 1, accuracy: 0.001)
        let palette = PickerPalette.splash(increasedContrast: true)
        XCTAssertEqual(try red(of: palette.border, in: .darkAqua), Double(0xA0) / 255, accuracy: 0.001)
    }

    func testSavedThemeKeepsKeyValuesAndTheDarkDefault() throws {
        let suite = "io.bobuk.splash-finish.tests.\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }
        func stored() -> AppearanceChoice { .stored(in: defaults, key: AppearanceChoice.defaultsKey, fallback: .dark) }
        XCTAssertEqual(AppearanceChoice.defaultsKey, "appTheme")
        XCTAssertEqual(stored(), .dark)
        defaults.set("light", forKey: "appTheme")
        XCTAssertEqual(stored(), .light)
        defaults.set("invalid", forKey: "appTheme")
        XCTAssertEqual(stored(), .dark)
        XCTAssertEqual(AppearanceChoice.offered.map(\.rawValue), ["light", "dark"])
    }
}
