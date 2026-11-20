import AppKit
import XCTest
import BobukUI
@testable import SplashFinish

/// The inbox panel's key handling, checked on a panel that is never shown. Events are built and
/// passed to the panel directly; nothing is posted to the system.
@MainActor final class SplashPanelTests: XCTestCase {
    /// Records the edit actions that reach it as the panel's first responder.
    private final class EditTarget: NSView {
        var received = [String]()
        override var acceptsFirstResponder: Bool { true }
        @objc func paste(_ sender: Any?) { received.append("paste") }
        @objc func copy(_ sender: Any?) { received.append("copy") }
        @objc override func selectAll(_ sender: Any?) { received.append("selectAll") }
    }

    private func command(_ characters: String, keyCode: UInt16) throws -> NSEvent {
        try XCTUnwrap(NSEvent.keyEvent(with: .keyDown, location: .zero, modifierFlags: .command, timestamp: 0,
                                       windowNumber: 0, context: nil, characters: characters,
                                       charactersIgnoringModifiers: characters, isARepeat: false, keyCode: keyCode))
    }

    func testInboxNeverDismissesItself() {
        let panel = SplashPanel(size: CGSize(width: 470, height: 350))
        XCTAssertFalse(panel.dismissesOnResignKey)
        XCTAssertFalse(panel.dismissesOnEscape)
        XCTAssertFalse(panel.dismissesOnCommandW)
        XCTAssertTrue(panel.routesEditCommands)
        XCTAssertFalse(panel.swallowsOtherCommandKeys)
        XCTAssertTrue(panel.canBecomeKey)
        XCTAssertFalse(panel.canBecomeMain)
        XCTAssertEqual(panel.level, .floating)
        XCTAssertTrue(panel.styleMask.contains(.nonactivatingPanel))
    }

    func testEditCommandsAreRoutedAndInboxShortcutsReachSwiftUI() throws {
        let panel = SplashPanel(size: CGSize(width: 470, height: 350))
        let target = EditTarget(frame: NSRect(x: 0, y: 0, width: 10, height: 10))
        panel.contentView = NSView(frame: NSRect(x: 0, y: 0, width: 470, height: 350))
        panel.contentView?.addSubview(target)
        XCTAssertTrue(panel.makeFirstResponder(target))
        // ⌘V, ⌘C and ⌘A reach the focused field: there is no Edit menu in this accessory app.
        for (key, code) in [("v", UInt16(9)), ("c", 8), ("a", 0)] {
            XCTAssertTrue(panel.performKeyEquivalent(with: try command(key, keyCode: code)), "⌘\(key)")
        }
        XCTAssertEqual(target.received, ["paste", "copy", "selectAll"])
        // ⌘W (Clear all), ⌘1 (an option) and ⌘↩ (Submit) are SwiftUI shortcuts of the content:
        // the panel must neither swallow them nor dismiss itself.
        for (key, code) in [("w", UInt16(13)), ("1", 18), ("\r", 36)] {
            XCTAssertFalse(panel.performKeyEquivalent(with: try command(key, keyCode: code)), "⌘\(key) must not be swallowed")
        }
    }
}
