import Foundation
import Testing
import BobukCore
import BobukUpdates
@testable import SplashFinish

/// Splash Finish's side of BobukUpdates: names, the cask and the run folder of earlier versions.
/// The runner, the window and Homebrew detection are tested in the kit.
@MainActor
struct UpdateWiringTests {
    @Test func identityKeepsTheNamesOfEarlierVersions() {
        let app = AppUpdateIdentity.splashFinish
        #expect(app.displayName == "Splash Finish")
        #expect(app.executableName == "SplashFinish")
        #expect(app.cask.tap == "bobuk-io/tap/splash-finish")
        #expect(app.cask.appBundleName == "Splash Finish.app")
        #expect(app.runBase.lastPathComponent == "io.bobuk.splash-finish.homebrew-update")
        #expect(HomebrewUpdate.arguments(for: app.cask) == ["upgrade", "--cask", "--greedy", "bobuk-io/tap/splash-finish"])
    }

    @Test func menuTitlesAndNoSparkleForHomebrew() throws {
        var made = 0
        let none = UpdateService(app: .splashFinish, choice: .none, makeSparkle: { made += 1; return FakeSparkle() })
        #expect(none.menuTitle == nil)
        let sparkle = UpdateService(app: .splashFinish, choice: .sparkle, makeSparkle: { made += 1; return FakeSparkle() })
        #expect(sparkle.menuTitle == "Check for Updates…")
        #expect(made == 1)
    }

    @Test func updateLaunchesNeverRunTheCommandLine() {
        #expect(HomebrewLaunch.isUpdateLaunch(["--homebrew-update-log", "/tmp/run"]))
        #expect(HomebrewLaunch.isUpdateLaunch(["--homebrew-update-viewer", "/tmp/run"]))
        #expect(!HomebrewLaunch.isUpdateLaunch(["status"]))
        #expect(AppBundle.isProcessSerialNumber("-psn_0_12345"))
    }
}

@MainActor
private final class FakeSparkle: SparkleUpdating {
    var automaticallyChecks = true
    var canCheck = true
    func check() {}
}
