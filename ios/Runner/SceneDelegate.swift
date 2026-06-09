import Flutter
import UIKit

class SceneDelegate: FlutterSceneDelegate {
  // Flutter's scene lifecycle only forwards URL events to scene-aware plugins.
  // Plugins that register as UIApplicationDelegate handlers (e.g. app_links)
  // never see them under the UIScene lifecycle. Bridge the scene URL events to
  // the application delegate so those plugins receive deep links again.

  // Cold start: the launching URL arrives in the scene connection options.
  override func scene(
    _ scene: UIScene,
    willConnectTo session: UISceneSession,
    options connectionOptions: UIScene.ConnectionOptions
  ) {
    super.scene(scene, willConnectTo: session, options: connectionOptions)
    forward(connectionOptions.urlContexts)
  }

  // Warm: a URL opened while the app is already running.
  override func scene(
    _ scene: UIScene,
    openURLContexts URLContexts: Set<UIOpenURLContext>
  ) {
    super.scene(scene, openURLContexts: URLContexts)
    forward(URLContexts)
  }

  private func forward(_ contexts: Set<UIOpenURLContext>) {
    guard let url = contexts.first?.url else { return }
    let app = UIApplication.shared
    // Defer so the engine and plugins are ready (important on cold start).
    DispatchQueue.main.async {
      _ = app.delegate?.application?(app, open: url, options: [:])
    }
  }
}
