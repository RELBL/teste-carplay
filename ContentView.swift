import SwiftUI

/// Tela que aparece no iPhone. O CarPlay usa os mesmos dados (PlayerManager), mas outra interface.
struct ContentView: View {
    @ObservedObject private var player = PlayerManager.shared

    var body: some View {
        NavigationStack {
            List(player.tracks) { track in
                Button {
                    player.play(track)
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(track.title)
                            Text(track.artist)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        if player.current == track {
                            Image(systemName: player.isPlaying ? "speaker.wave.2.fill" : "pause.fill")
                                .foregroundStyle(.tint)
                        }
                    }
                }
            }
            .navigationTitle("CarPlay Demo")
            .safeAreaInset(edge: .bottom) {
                if player.current != nil {
                    Button(player.isPlaying ? "Pausar" : "Continuar") {
                        player.toggle()
                    }
                    .buttonStyle(.borderedProminent)
                    .padding()
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
