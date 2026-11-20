import AppKit
import SwiftUI
import BobukSystem
import BobukUI

extension AppearanceChoice {
    /// Kept from earlier versions, which saved "light" or "dark" here.
    static let defaultsKey = "appTheme"
    /// Settings offers Light and Dark only.
    static let offered: [AppearanceChoice] = [.light, .dark]
    /// The saved choice; the inbox stays dark until the user chooses Light.
    static var saved: AppearanceChoice { stored(key: defaultsKey, fallback: .dark) }
}

extension NSColor {
    /// Splash Finish's ink is pure white in the dark theme, unlike `BobukColors.ink`.
    static let panelInk = NSColor.dynamic(light: 0x222A2E, dark: 0xFFFFFF)
}

extension Color {
    static var panelInk: Color { Color(nsColor: .panelInk) }
    static var panelMuted: Color { Color(nsColor: BobukColors.muted) }
    static var panelAccent: Color { Color(nsColor: BobukColors.amber) }
}

extension PickerPalette {
    /// The inbox palette: the shared graphite and amber with Splash Finish's ink and a stronger
    /// border when the system asks for more contrast.
    static func splash(increasedContrast: Bool) -> PickerPalette {
        PickerPalette(surface: BobukColors.panel, text: .panelInk, secondary: BobukColors.muted,
                      accent: BobukColors.amber,
                      border: increasedContrast ? .dynamic(light: 0x46545B, dark: 0xA0B0B4) : BobukColors.stroke,
                      badgeInk: .textColor)
    }

    /// The palette for the current accessibility setting (update window).
    @MainActor static var splash: PickerPalette {
        splash(increasedContrast: NSWorkspace.shared.accessibilityDisplayShouldIncreaseContrast)
    }
}

extension ChromeStyle {
    /// Settings and Integrations hold native forms: system chrome with the Splash Finish accent.
    static var splashWindow: ChromeStyle {
        var style = ChromeStyle.system
        style.accent = BobukColors.amber
        return style
    }
}

struct SettingsView: View {
    let model: AppModel
    let installSkills: () -> Void
    let uninstallSkills: () -> Void
    @AppStorage(AppearanceChoice.defaultsKey) private var theme = AppearanceChoice.dark.rawValue
    @State private var startsAtLogin = LoginItem.isEnabled

    var body: some View {
        Form {
            Picker("Appearance", selection: $theme) {
                ForEach(AppearanceChoice.offered) { choice in
                    Text(choice.title).tag(choice.rawValue)
                }
            }
            .pickerStyle(.segmented)

            Section("General") {
                Toggle("Start at Login", isOn: Binding(
                    get: { startsAtLogin },
                    set: { value in
                        // Opens Login Items in System Settings when macOS asks for approval.
                        do { try LoginItem.set(value) } catch { model.report(error); model.show() }
                        startsAtLogin = LoginItem.isEnabled
                    }
                ))
                Toggle("Respect Do Not Disturb", isOn: Binding(
                    get: { model.respectFocus },
                    set: { value in
                        model.respectFocus = value
                        UserDefaults.standard.set(value, forKey: "respectFocus")
                    }
                ))
            }

            Section("Agent Skills") {
                HStack {
                    Button("Install Agent Skills…", action: installSkills)
                    Button("Uninstall Agent Skills…", action: uninstallSkills)
                }
            }
        }
        .formStyle(.grouped)
        .frame(width: 440, height: 300)
        .onChange(of: theme) { _, _ in AppearanceChoice.saved.apply() }
        .onReceive(NotificationCenter.default.publisher(for: NSApplication.didBecomeActiveNotification)) { _ in
            startsAtLogin = LoginItem.isEnabled
        }
    }
}
