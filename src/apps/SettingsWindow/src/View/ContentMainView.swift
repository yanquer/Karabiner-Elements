import SwiftUI

enum SidebarItem: String, CaseIterable, Identifiable, Hashable {
  case simpleModifications
  case functionKeys
  case complexModifications
  case complexModificationsAdvanced
  case devices
  case virtualKeyboard
  case profiles
  case ui
  case update
  case misc
  case uninstall
  case expert
  case action
  case log
  case systemExtensions
  case setup

  var id: Self { self }

  var title: String {
    switch self {
    case .simpleModifications: return String(localized: "Simple Modifications")
    case .functionKeys: return String(localized: "Function Keys")
    case .complexModifications: return String(localized: "Complex Modifications")
    case .complexModificationsAdvanced: return String(localized: "Parameters")
    case .devices: return String(localized: "Devices")
    case .virtualKeyboard: return String(localized: "Virtual Keyboard")
    case .profiles: return String(localized: "Profiles")
    case .ui: return String(localized: "UI")
    case .update: return String(localized: "Update")
    case .misc: return String(localized: "Misc")
    case .uninstall: return String(localized: "Uninstall")
    case .expert: return String(localized: "Expert")
    case .action: return String(localized: "Quit, Restart")
    case .log: return String(localized: "Log")
    case .systemExtensions: return String(localized: "System Extensions")
    case .setup: return String(localized: "Setup")
    }
  }

  var systemImage: String {
    switch self {
    case .simpleModifications: return "gearshape"
    case .functionKeys: return "speaker.wave.2.circle"
    case .complexModifications: return "gearshape.2"
    case .complexModificationsAdvanced: return "dial.min"
    case .devices: return "keyboard"
    case .virtualKeyboard: return "puzzlepiece"
    case .profiles: return "person.3"
    case .ui: return "switch.2"
    case .update: return "network"
    case .misc: return "leaf"
    case .uninstall: return "trash"
    case .expert: return "flame"
    case .action: return "xmark.rectangle"
    case .log: return "doc.plaintext"
    case .systemExtensions: return "puzzlepiece.extension"
    case .setup: return "checklist"
    }
  }
}

struct ContentMainView: View {
  @ObservedObject private var contentViewStates = ContentViewStates.shared
  @ObservedObject private var settings = LibKrbn.Settings.shared
  @ObservedObject private var settingsCoreServiceClient = SettingsCoreServiceClient.shared
  @ObservedObject private var systemPreferences = SystemPreferences.shared

  @State private var selectedSidebarItem: SidebarItem = .simpleModifications

  struct SidebarSection {
    let title: String
    let items: [SidebarItem]
  }

  let sections: [SidebarSection] = [
    SidebarSection(
      title: String(localized: "Modifications"),
      items: [
        .simpleModifications,
        .functionKeys,
        .complexModifications,
        .complexModificationsAdvanced,
      ]
    ),
    SidebarSection(
      title: String(localized: "Configurations"),
      items: [
        .devices,
        .virtualKeyboard,
        .profiles,
        .ui,
      ]
    ),
    SidebarSection(
      title: String(localized: "Maintenance"),
      items: [
        .update,
        .misc,
        .uninstall,
        .expert,
        .action,
      ]
    ),
    SidebarSection(
      title: String(localized: "Diagnostic"),
      items: [
        .log,
        .systemExtensions,
        .setup,
      ]
    ),
  ]

  var body: some View {
    NavigationSplitView(
      sidebar: {
        List(selection: $selectedSidebarItem) {
          ForEach(sections.indices, id: \.self) { section in
            Section {
              ForEach(sections[section].items) { item in
                sidebarRow(item)
              }
            } header: {
              Text(sections[section].title)
            }
          }
        }
        .onAppear {
          selectedSidebarItem = contentViewStates.navigationSelection
        }
        .onChange(of: selectedSidebarItem) { newValue in
          if contentViewStates.navigationSelection != newValue {
            contentViewStates.userSelectedNavigationItem(newValue)
          }
        }
        .onChange(of: contentViewStates.navigationSelection) { newValue in
          if selectedSidebarItem != newValue {
            selectedSidebarItem = newValue
          }
        }
        .navigationSplitViewColumnWidth(250)
        .listStyle(.sidebar)
      },
      detail: {
        VStack(alignment: .leading, spacing: 0) {
          if settings.unsafeUI {
            Button(
              action: {
                selectedSidebarItem = .expert
              },
              label: {
                Label(
                  "The unsafe configuration is enabled, so the foolproof feature is currently inactive.",
                  systemImage: "exclamationmark.triangle"
                )
              }
            )
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(8.0)
            .buttonStyle(PlainButtonStyle())
            .background(Color.red)
            .foregroundColor(.white)
          }

          if settingsCoreServiceClient.temporarilyIgnoreAllDevices {
            Label(
              "All Karabiner-Elements modifications are temporarily disabled by EventViewer.",
              systemImage: WarningBorder.icon
            )
            .frame(maxWidth: .infinity, alignment: .leading)
            .modifier(WarningBorder())
            .padding()
          }

          if systemPreferences.virtualHIDKeyboardModifierMappingsExists {
            VStack(alignment: .leading) {
              Label(
                """
                macOS also remaps modifier keys. It's recommended to restore defaults and configure them via Karabiner-Elements.

                You can reset the macOS setting by following steps:
                1. Open System Settings and go to Keyboard Shortcuts... > Modifier Keys.
                2. Choose Karabiner DriverKit VirtualHIDKeyboard.
                3. Click the Restore Defaults button.
                """,
                systemImage: WarningBorder.icon
              )

              OpenSystemSettingsButton(
                url: "x-apple.systempreferences:com.apple.preference.keyboard",
                label: {
                  Label(
                    "Open System Settings...",
                    systemImage: "arrow.up.forward.app"
                  )
                }
              )
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .modifier(WarningBorder())
            .padding()
          }

          if settings.saveErrorMessage != "" {
            VStack(alignment: .leading) {
              Label(
                "Save failed:\n\(settings.saveErrorMessage)",
                systemImage: ErrorBorder.icon
              )
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .modifier(ErrorBorder())
            .padding()
          }

          switch selectedSidebarItem {
          case .simpleModifications:
            SimpleModificationsView()
          case .functionKeys:
            FunctionKeysView()
          case .complexModifications:
            ComplexModificationsView()
          case .complexModificationsAdvanced:
            ComplexModificationsAdvancedView()
          case .devices:
            DevicesView()
          case .virtualKeyboard:
            VirtualKeyboardView()
          case .profiles:
            ProfilesView()
          case .ui:
            UIView()
          case .update:
            UpdateView()
          case .misc:
            MiscView()
          case .uninstall:
            UninstallView()
          case .expert:
            ExpertView()
          case .action:
            ActionView()
          case .log:
            LogView()
          case .systemExtensions:
            SystemExtensionsView()
          case .setup:
            SetupView()
          }
        }
      }
    )
  }

  @ViewBuilder
  private func sidebarRow(_ item: SidebarItem) -> some View {
    HStack(spacing: 8.0) {
      Image(systemName: item.systemImage)
        .frame(width: 18.0)

      Text(item.title)
    }
    .padding(.vertical, 2.0)
    .tag(item)
  }
}
