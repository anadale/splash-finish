import AppKit
import BobukUI
import SplashFinishCore

/// The inbox: a floating, non-activating `BobukPanel` that stays up while the person works in
/// another app. It never dismisses itself: Esc snoozes, Backspace and ⌘W clear all (the SwiftUI
/// "Clear all" button owns ⌘W), and the menu or a new event shows it again.
final class SplashPanel: BobukPanel {
    var onKeyAction: ((PanelKeyAction) -> Bool)?

    init(size: CGSize) {
        super.init(contentRect: NSRect(origin: .zero, size: size), kind: .floating)
        title = "Splash Finish"
        isMovableByWindowBackground = true
        dismissesOnResignKey = false
        dismissesOnEscape = false
        dismissesOnCommandW = false
        // This accessory app has no Edit menu: ⌘C/⌘V/⌘X/⌘A/⌘Z go to the pi question fields by the
        // Latin key. Other ⌘ shortcuts are not swallowed: ⌘W, ⌘1…⌘9 and ⌘↩ are SwiftUI
        // `.keyboardShortcut`s of the content.
        routesEditCommands = true
        swallowsOtherCommandKeys = false
    }

    override func sendEvent(_ event: NSEvent) {
        guard event.type == .keyDown, isKeyWindow else { super.sendEvent(event); return }
        // Text editing must never trigger inbox-wide shortcuts or navigation.
        if firstResponder is NSTextView { super.sendEvent(event); return }
        let modifiers = event.modifierFlags.intersection([.command, .control, .option, .shift])
        // Swallow repeats of destructive or one-shot shortcuts rather than passing
        // them to another responder; arrow-key repeats still navigate normally.
        if modifiers.isEmpty, event.isARepeat, PanelKeyAction.isOneShot(keyCode: event.keyCode) { return }
        if let action = PanelKeyAction.from(keyCode: event.keyCode, hasCommandModifiers: !modifiers.isEmpty,
                                            isRepeat: event.isARepeat),
           onKeyAction?(action) == true {
            return
        }
        super.sendEvent(event)
    }
}
