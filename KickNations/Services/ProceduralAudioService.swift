import AVFoundation
import Foundation

enum ProceduralSoundEffect {
    case crowdLoop
    case kick
    case bounce
    case goal
    case roar
    case boo
}

final class ProceduralAudioService {
    static let shared = ProceduralAudioService()

    private let engine = AVAudioEngine()
    private let player = AVAudioPlayerNode()
    private let sampleRate: Double = 44_100
    private let format: AVAudioFormat
    private var isConfigured = false

    private init() {
        format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1)!
    }

    func play(_ effect: ProceduralSoundEffect) {
        guard !ProcessInfo.processInfo.arguments.contains("-disableAudio") else { return }

        do {
            try configureIfNeeded()
        } catch {
            return
        }

        let buffer = makeBuffer(for: effect)
        player.scheduleBuffer(buffer, completionHandler: nil)
        if !player.isPlaying {
            player.play()
        }
    }

    private func configureIfNeeded() throws {
        guard !isConfigured else { return }

        #if os(iOS)
        try? AVAudioSession.sharedInstance().setCategory(.ambient, options: [.mixWithOthers])
        try? AVAudioSession.sharedInstance().setActive(true)
        #endif

        engine.attach(player)
        engine.connect(player, to: engine.mainMixerNode, format: format)
        try engine.start()
        isConfigured = true
    }

    private func makeBuffer(for effect: ProceduralSoundEffect) -> AVAudioPCMBuffer {
        let duration = duration(for: effect)
        let frameCount = AVAudioFrameCount(sampleRate * duration)
        let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount)!
        buffer.frameLength = frameCount

        guard let channel = buffer.floatChannelData?[0] else { return buffer }

        for frame in 0..<Int(frameCount) {
            let t = Double(frame) / sampleRate
            channel[frame] = sample(effect: effect, t: t, duration: duration)
        }

        return buffer
    }

    private func duration(for effect: ProceduralSoundEffect) -> Double {
        switch effect {
        case .crowdLoop: 0.72
        case .kick: 0.10
        case .bounce: 0.08
        case .goal: 0.58
        case .roar: 0.34
        case .boo: 0.42
        }
    }

    private func sample(effect: ProceduralSoundEffect, t: Double, duration: Double) -> Float {
        let progress = min(1, max(0, t / duration))
        let noise = pseudoNoise(t: t)

        switch effect {
        case .crowdLoop:
            let swell = envelope(progress: progress, attack: 0.18, release: 0.18)
            let hum = sin(2 * Double.pi * 118 * t) * 0.10 + sin(2 * Double.pi * 176 * t) * 0.06
            return clamp(Float((noise * 0.24 + hum) * Double(swell)))

        case .kick:
            let env = pow(1 - progress, 2.4)
            let tone = sin(2 * Double.pi * (120 - 45 * progress) * t)
            return clamp(Float((tone * 0.44 + noise * 0.16) * env))

        case .bounce:
            let env = pow(1 - progress, 2.8)
            let tone = sin(2 * Double.pi * (420 - 180 * progress) * t)
            return clamp(Float((tone * 0.32 + noise * 0.10) * env))

        case .goal:
            let swell = envelope(progress: progress, attack: 0.08, release: 0.28)
            let chord = sin(2 * Double.pi * 262 * t) + sin(2 * Double.pi * 330 * t) + sin(2 * Double.pi * 392 * t)
            return clamp(Float((chord * 0.12 + noise * 0.26) * Double(swell)))

        case .roar:
            let swell = envelope(progress: progress, attack: 0.05, release: 0.20)
            let wave = sin(2 * Double.pi * (90 + 180 * progress) * t)
            return clamp(Float((wave * 0.18 + noise * 0.30) * Double(swell)))

        case .boo:
            let env = envelope(progress: progress, attack: 0.10, release: 0.16)
            let wobble = sin(2 * Double.pi * 92 * t + sin(2 * Double.pi * 8 * t) * 0.7)
            return clamp(Float((wobble * 0.26 + noise * 0.08) * Double(env)))
        }
    }

    private func envelope(progress: Double, attack: Double, release: Double) -> Float {
        if progress < attack {
            return Float(progress / attack)
        }
        if progress > 1 - release {
            return Float(max(0, (1 - progress) / release))
        }
        return 1
    }

    private func pseudoNoise(t: Double) -> Double {
        let value = sin(t * 12_989.8) * 43_758.5453
        return (value - floor(value)) * 2 - 1
    }

    private func clamp(_ value: Float) -> Float {
        min(0.85, max(-0.85, value))
    }
}
