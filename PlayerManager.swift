import AVFoundation
import Combine
import MediaPlayer

/// Uma "faixa" da demo. Aqui cada faixa é só um tom gerado em código (sem arquivos de música).
/// Para usar áudio de verdade, troque por AVAudioPlayer(contentsOf: url) com arquivos do app.
struct Track: Identifiable, Equatable {
    let id: Int
    let title: String
    let artist: String
    let frequency: Double   // Hz
}

/// Controla a reprodução e informa ao sistema o que está tocando (MPNowPlayingInfoCenter).
/// É isso que alimenta a tela "Tocando agora" do CarPlay, a tela de bloqueio e a Central de Controle.
final class PlayerManager: ObservableObject {
    static let shared = PlayerManager()

    let tracks: [Track] = [
        Track(id: 1, title: "Tom 1 – 440 Hz", artist: "Gerador de tons", frequency: 440),
        Track(id: 2, title: "Tom 2 – 528 Hz", artist: "Gerador de tons", frequency: 528),
        Track(id: 3, title: "Tom 3 – 660 Hz", artist: "Gerador de tons", frequency: 660)
    ]

    @Published private(set) var current: Track?
    @Published private(set) var isPlaying = false

    private var player: AVAudioPlayer?
    private var isPrepared = false

    private init() {}

    /// Chamado uma vez no launch (AppDelegate).
    func prepare() {
        guard !isPrepared else { return }
        isPrepared = true

        // Apps de áudio no CarPlay usam a categoria .playback.
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
        } catch {
            print("Erro ao configurar a sessão de áudio: \(error)")
        }

        // Botões de play/pause do CarPlay, da tela de bloqueio, de fones etc.
        let center = MPRemoteCommandCenter.shared()
        center.playCommand.addTarget { [weak self] _ in
            DispatchQueue.main.async { self?.resume() }
            return .success
        }
        center.pauseCommand.addTarget { [weak self] _ in
            DispatchQueue.main.async { self?.pause() }
            return .success
        }
        center.togglePlayPauseCommand.addTarget { [weak self] _ in
            DispatchQueue.main.async { self?.toggle() }
            return .success
        }
    }

    // MARK: - Controles

    func play(_ track: Track) {
        do {
            try AVAudioSession.sharedInstance().setActive(true)
            let newPlayer = try AVAudioPlayer(data: ToneWav.make(frequency: track.frequency, seconds: 10))
            newPlayer.numberOfLoops = -1   // repete até pausar
            newPlayer.prepareToPlay()
            newPlayer.play()

            player = newPlayer
            current = track
            isPlaying = true
            updateNowPlaying()
        } catch {
            print("Erro ao tocar: \(error)")
        }
    }

    func pause() {
        player?.pause()
        isPlaying = false
        updateNowPlaying()
    }

    func resume() {
        guard let player else { return }
        player.play()
        isPlaying = true
        updateNowPlaying()
    }

    func toggle() {
        isPlaying ? pause() : resume()
    }

    // MARK: - Now Playing

    private func updateNowPlaying() {
        guard let track = current else {
            MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
            return
        }
        MPNowPlayingInfoCenter.default().nowPlayingInfo = [
            MPMediaItemPropertyTitle: track.title,
            MPMediaItemPropertyArtist: track.artist,
            MPNowPlayingInfoPropertyPlaybackRate: isPlaying ? 1.0 : 0.0,
            MPNowPlayingInfoPropertyElapsedPlaybackTime: player?.currentTime ?? 0
        ]
    }
}

/// Gera um arquivo WAV (PCM 16 bits, mono) com um tom senoidal, só para a demo ter som sem assets.
enum ToneWav {
    static func make(frequency: Double, seconds: Double, sampleRate: Int = 44_100) -> Data {
        let frameCount = Int(Double(sampleRate) * seconds)
        var samples = [Int16](repeating: 0, count: frameCount)
        for i in 0..<frameCount {
            let t = Double(i) / Double(sampleRate)
            samples[i] = Int16(sin(2.0 * Double.pi * frequency * t) * 0.3 * Double(Int16.max))
        }

        func le16(_ value: UInt16) -> [UInt8] { withUnsafeBytes(of: value.littleEndian) { Array($0) } }
        func le32(_ value: UInt32) -> [UInt8] { withUnsafeBytes(of: value.littleEndian) { Array($0) } }

        let dataSize = UInt32(frameCount * MemoryLayout<Int16>.size)

        var wav = Data()
        wav.append(contentsOf: Array("RIFF".utf8))
        wav.append(contentsOf: le32(36 + dataSize))
        wav.append(contentsOf: Array("WAVE".utf8))
        wav.append(contentsOf: Array("fmt ".utf8))
        wav.append(contentsOf: le32(16))                      // tamanho do bloco fmt
        wav.append(contentsOf: le16(1))                       // formato PCM
        wav.append(contentsOf: le16(1))                       // 1 canal (mono)
        wav.append(contentsOf: le32(UInt32(sampleRate)))      // taxa de amostragem
        wav.append(contentsOf: le32(UInt32(sampleRate * 2)))  // bytes por segundo
        wav.append(contentsOf: le16(2))                       // bytes por frame
        wav.append(contentsOf: le16(16))                      // bits por amostra
        wav.append(contentsOf: Array("data".utf8))
        wav.append(contentsOf: le32(dataSize))
        samples.withUnsafeBytes { wav.append(contentsOf: $0) }
        return wav
    }
}
