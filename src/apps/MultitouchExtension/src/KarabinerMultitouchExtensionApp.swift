import Combine
import OSLog
import SettingsAccess
import SwiftUI

@main
struct KarabinerMultitouchExtensionApp: App {
  @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

  private let version =
    Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? ""

  init() {
    libkrbn_initialize()
    libkrbn_load_custom_environment_variables()
  }

  var body: some Scene {
    MenuBarExtra(
      "Karabiner-MultitouchExtension", systemImage: "rectangle.and.hand.point.up.left.filled",
    ) {
      Text("Karabiner-MultitouchExtension \(version)")

      Divider()

      SettingsLink {
        Label("Settings...", systemImage: "gear")
          .labelStyle(.titleAndIcon)
      } preAction: {
        NSApp.activate(ignoringOtherApps: true)
      } postAction: {
      }
    }

    Settings {
      SettingsView()
    }
  }
}

@MainActor
class AppDelegate: NSObject, NSApplicationDelegate {
  private let logger = Logger(
    subsystem: Bundle.main.bundleIdentifier ?? "unknown",
    category: String(describing: AppDelegate.self))

  private var activity: NSObjectProtocol?
  private var sleepCancellable: AnyCancellable?
  private var wakeCancellable: AnyCancellable?
  private var displaySleepCancellable: AnyCancellable?
  private var displayWakeCancellable: AnyCancellable?
  private var userSettingsCancellable: AnyCancellable?
  private var isDisplaySleeping = false

  public func applicationDidFinishLaunching(_: Notification) {
    //
    // Enable core_service_client
    //

    MECoreServiceClient.shared.start()
    MultitouchDeviceManager.shared.observeIONotification()

    observeUserInteractiveActivitySettings()

    observeSystemSleep()
    observeDisplaySleep()
  }

  public func applicationWillTerminate(_: Notification) {
    cancelSystemSleepObservers()
    cancelDisplaySleepObservers()

    stopActivity()
    userSettingsCancellable = nil

    MultitouchDeviceManager.shared.setCallback(false)

    libkrbn_terminate()
  }

  private func startActivity() {
    //
    // Disable App Nap
    //

    if UserSettings.shared.allowUserInteractiveActivity {
      if activity == nil {
        logger.info("beginActivity")

        activity = ProcessInfo.processInfo.beginActivity(
          options: .userInteractive,
          reason:
            "Disable App Nap in order to receive multitouch events even if this app is background"
        )
      }
    }
  }

  private func stopActivity() {
    if isDisplaySleeping && UserSettings.shared.keepUserInteractiveActivityDuringDisplaySleep {
      return
    }

    if let a = activity {
      logger.info("endActivity")

      ProcessInfo.processInfo.endActivity(a)
      activity = nil
    }
  }

  private func observeUserInteractiveActivitySettings() {
    userSettingsCancellable = UserSettings.shared.$allowUserInteractiveActivity
      .sink { [weak self] isAllowed in
        guard let self else { return }

        Task { @MainActor in
          if isAllowed {
            self.startActivity()
          } else {
            self.stopActivity()
          }
        }
      }
  }

  private func observeSystemSleep() {
    sleepCancellable = NSWorkspace.shared.notificationCenter.publisher(
      for: NSWorkspace.willSleepNotification,
      object: nil
    )
    .sink { [weak self] _ in
      guard let self else { return }

      Task { @MainActor in
        logger.info("NSWorkspace.willSleepNotification")

        self.stopActivity()
      }
    }

    wakeCancellable = NSWorkspace.shared.notificationCenter.publisher(
      for: NSWorkspace.didWakeNotification,
      object: nil
    )
    .sink { [weak self] _ in
      guard let self else { return }

      Task { @MainActor in
        logger.info("NSWorkspace.didWakeNotification")

        self.startActivity()
      }
    }
  }

  private func observeDisplaySleep() {
    displaySleepCancellable = NSWorkspace.shared.notificationCenter.publisher(
      for: NSWorkspace.screensDidSleepNotification,
      object: nil
    )
    .sink { [weak self] _ in
      guard let self else { return }

      Task { @MainActor in
        logger.info("NSWorkspace.screensDidSleepNotification")

        isDisplaySleeping = true

        self.stopActivity()
      }
    }

    displayWakeCancellable = NSWorkspace.shared.notificationCenter.publisher(
      for: NSWorkspace.screensDidWakeNotification,
      object: nil
    )
    .sink { [weak self] _ in
      guard let self else { return }

      Task { @MainActor in
        logger.info("NSWorkspace.screensDidWakeNotification")

        isDisplaySleeping = false

        self.startActivity()
      }
    }
  }

  private func cancelSystemSleepObservers() {
    sleepCancellable = nil

    wakeCancellable = nil
  }

  private func cancelDisplaySleepObservers() {
    displaySleepCancellable = nil

    displayWakeCancellable = nil
  }
}
