# CarPlayDemo — projeto base para CarPlay (categoria Áudio)

Projeto mínimo em Swift que aparece no **CarPlay Simulator** do Xcode:
ícone do app na tela do CarPlay → lista de faixas → tela "Tocando agora".
O áudio é gerado no próprio código (tons), então não precisa de arquivos de música.

> **Aviso:** montei este projeto sem Xcode no meu ambiente, então **não consegui compilar**.
> O código segue a API padrão do CarPlay, mas pode precisar de pequenos ajustes.
> Veja "Problemas comuns" no final.

## O que tem aqui

| Arquivo | Para quê |
|---|---|
| `Sources/AppDelegate.swift` | Ponto de entrada (`@main`). Prepara o áudio. |
| `Sources/PhoneSceneDelegate.swift` | Cena da tela do iPhone (mostra a `ContentView`). |
| `Sources/CarPlaySceneDelegate.swift` | **Cena do CarPlay.** Monta os templates (lista + Now Playing). |
| `Sources/PlayerManager.swift` | Toca o áudio e informa o "Tocando agora" ao sistema. |
| `Sources/ContentView.swift` | Interface SwiftUI do iPhone. |
| `Config/Info.plist` | Declara as duas cenas (iPhone e CarPlay) + áudio em segundo plano. |
| `Config/CarPlayDemo.entitlements` | Entitlement `com.apple.developer.carplay-audio`. |

## Passo a passo

1. No Xcode: **File ▸ New ▸ Project ▸ iOS ▸ App**.
   Product Name: `CarPlayDemo` · Interface: **SwiftUI** · Language: **Swift**.
2. **Apague** os arquivos que o Xcode gerou: `CarPlayDemoApp.swift` e `ContentView.swift`
   (o `@main` agora está no `AppDelegate.swift`).
3. Arraste os 5 arquivos de `Sources/` para dentro do grupo `CarPlayDemo` no Xcode
   (marque *Copy items if needed* e o target `CarPlayDemo`).
4. No Finder, crie uma pasta `Config` **ao lado do `.xcodeproj`** e copie para lá o
   `Info.plist` e o `CarPlayDemo.entitlements`. (Fica fora da pasta do app para o Xcode
   não incluí-los como recursos.)
5. Selecione o target `CarPlayDemo` ▸ **Build Settings** ▸ *All* e ajuste:
   - **Generate Info.plist File** = `No`
   - **Info.plist File** = `Config/Info.plist`
   - **Code Signing Entitlements** = `Config/CarPlayDemo.entitlements`
6. Escolha um **simulador de iPhone** (de preferência com iOS 26.x, veja abaixo) e rode com `⌘R`.
7. Com o app aberto no Simulator, abra o CarPlay: menu **I/O ▸ External Displays ▸ CarPlay**
   (abre uma janela de 800×480 que se comporta como a tela do carro).
   Toque no ícone **CarPlay Demo**, escolha uma faixa e veja a tela "Tocando agora".

## Sobre o Xcode 27

- No Xcode 27 o app Simulator foi substituído pelo **Device Hub**. O caminho
  `I/O ▸ External Displays ▸ CarPlay` é o que a documentação da Apple descreve para o Simulator;
  não consegui confirmar onde fica essa opção no Device Hub.
- Um desenvolvedor relatou, em um beta do Xcode 27, **tela preta** na janela do CarPlay com
  simuladores iOS 27, funcionando normalmente no iOS 26.3. Se acontecer com você, rode o app
  num simulador **iOS 26.x** (instale o runtime em *Xcode ▸ Settings ▸ Components*).

## Problemas comuns

- **O app não aparece no CarPlay:** confira os 3 ajustes do passo 5 (caminhos certos), faça
  *Product ▸ Clean Build Folder*, apague o app do simulador e rode de novo.
- **Erro "Info.plist not found":** o caminho em *Info.plist File* está errado; ele é relativo
  à pasta do projeto (onde fica o `.xcodeproj`).
- **Erros de concorrência (Swift 6):** em Build Settings, coloque *Swift Language Mode* = `Swift 5`.
- **Sem som:** verifique o volume do Mac; o áudio do simulador sai pelo Mac.

## Simulador x carro de verdade

- No **simulador**, basta declarar o entitlement no projeto (como neste exemplo).
- Para rodar em **iPhone real com CarPlay, TestFlight ou App Store**, a Apple precisa **aprovar** o
  entitlement da categoria do seu app (pedido pelo formulário de entitlements de CarPlay, com
  conta do Apple Developer Program). Isso leva tempo, então, para trabalho de faculdade, o
  normal é demonstrar no simulador.

## Se o trabalho exigir outra categoria

- **Vídeo:** categoria nova do iOS 27, com entitlement próprio (`com.apple.developer.carplay-video`).
  Só funciona em carros que suportam o recurso "video in car" (em geral, com o carro parado).
  Esta base usa **Áudio**; para vídeo a estrutura (Info.plist, cena, templates) é a mesma, mas
  os templates e o entitlement mudam.
- Outras: comunicação, navegação, estacionamento, recarga de veículos elétricos, pedido rápido
  de comida, abastecimento, tarefas de direção, etc. — cada uma tem um entitlement diferente.

## Ideias do que mostrar/explicar na entrega

1. As três peças do CarPlay: **entitlement**, **cena no Info.plist** e **`CPTemplateApplicationSceneDelegate`**.
2. Que a interface do carro é feita de **templates** (`CPListTemplate`, `CPNowPlayingTemplate`...),
   não de views livres.
3. Como o "Tocando agora" funciona: `MPNowPlayingInfoCenter` + `MPRemoteCommandCenter`.
4. Por que um app só aparece num carro real depois que a Apple aprova o entitlement.

## Referências (Apple)

- Using the CarPlay Simulator: https://developer.apple.com/documentation/carplay/using-the-carplay-simulator
- Requesting CarPlay Entitlements: https://developer.apple.com/documentation/carplay/requesting-carplay-entitlements
