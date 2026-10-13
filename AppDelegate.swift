import UIKit

/// Ponto de entrada do app (ciclo de vida UIKit).
/// As cenas (iPhone e CarPlay) são declaradas no Info.plist; o sistema escolhe
/// qual delegate usar conforme o "papel" da cena (tela do iPhone x tela do carro).
@main
final class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Configura a sessão de áudio e os controles remotos (play/pause) uma única vez.
        PlayerManager.shared.prepare()
        return true
    }
}
