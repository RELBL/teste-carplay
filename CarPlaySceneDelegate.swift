import CarPlay
import UIKit

/// Cena da tela do carro. O sistema cria esta cena quando o iPhone conecta ao CarPlay
/// (ou quando você abre I/O > External Displays > CarPlay no Simulator).
///
/// No CarPlay você não desenha views: monta "templates" (lista, grade, abas, Now Playing...)
/// e entrega ao CPInterfaceController, que cuida de exibir na tela do carro.
final class CarPlaySceneDelegate: UIResponder, CPTemplateApplicationSceneDelegate {

    private var interfaceController: CPInterfaceController?

    // MARK: - Conexão / desconexão

    func templateApplicationScene(_ templateApplicationScene: CPTemplateApplicationScene,
                                  didConnect interfaceController: CPInterfaceController) {
        self.interfaceController = interfaceController
        interfaceController.setRootTemplate(makeTrackListTemplate(), animated: false, completion: nil)
    }

    func templateApplicationScene(_ templateApplicationScene: CPTemplateApplicationScene,
                                  didDisconnectInterfaceController interfaceController: CPInterfaceController) {
        self.interfaceController = nil
    }

    // MARK: - Templates

    /// Tela inicial: lista de faixas. Tocar numa faixa começa a reprodução e abre "Tocando agora".
    private func makeTrackListTemplate() -> CPListTemplate {
        let items = PlayerManager.shared.tracks.map { track -> CPListItem in
            let item = CPListItem(text: track.title, detailText: track.artist)
            item.handler = { [weak self] _, completion in
                PlayerManager.shared.play(track)
                self?.interfaceController?.pushTemplate(CPNowPlayingTemplate.shared,
                                                        animated: true,
                                                        completion: nil)
                completion()
            }
            return item
        }

        return CPListTemplate(title: "Faixas", sections: [CPListSection(items: items)])
    }
}
