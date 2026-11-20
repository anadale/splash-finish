import Foundation
import XCTest
import BobukCore
@testable import SplashFinish

/// The resource bundle name must match what SwiftPM builds and `package_app.sh` copies.
final class AppBundleTests: XCTestCase {
    func testPackagedResourcesAndMissingBundle() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: root) }
        let app = root.appendingPathComponent("Splash Finish.app")
        let executable = app.appendingPathComponent("Contents/MacOS/SplashFinish")
        let resources = app.appendingPathComponent("Contents/Resources/SplashFinish_SplashFinish.bundle")
        XCTAssertNil(AppBundle.resourceBundle(named: CLI.resourceBundleName, executable: executable),
                     "An installed app must never use the developer's build resources")
        try FileManager.default.createDirectory(at: resources, withIntermediateDirectories: true)
        XCTAssertEqual(AppBundle.applicationURL(for: executable)?.path, app.path)
        XCTAssertEqual(AppBundle.resourceBundle(named: CLI.resourceBundleName, executable: executable)?.bundleURL.path,
                       resources.path)
    }

    func testSwiftPMResourcesBesideExecutable() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: root) }
        let resources = root.appendingPathComponent("SplashFinish_SplashFinish.bundle")
        try FileManager.default.createDirectory(at: resources, withIntermediateDirectories: true)
        let executable = root.appendingPathComponent("SplashFinish")
        XCTAssertNil(AppBundle.applicationURL(for: executable))
        XCTAssertEqual(AppBundle.resourceBundle(named: CLI.resourceBundleName, executable: executable)?.bundleURL.path,
                       resources.path)
    }
}
