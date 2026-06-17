import Foundation
import AVFoundation

final class AudioService {
    private let engine = AVAudioEngine()
    private let chimePlayer = AVAudioPlayerNode()
    private let ambiencePlayer = AVAudioPlayerNode()
    private let format = AVAudioFormat(standardFormatWithSampleRate: 44_100, channels: 1)
    private var started = false

    var soundEnabled = true
    var musicEnabled = true
    var ambienceEnabled = true

    func configure() {
        guard let format else { return }
        engine.attach(chimePlayer)
        engine.attach(ambiencePlayer)
        engine.connect(chimePlayer, to: engine.mainMixerNode, format: format)
        engine.connect(ambiencePlayer, to: engine.mainMixerNode, format: format)
        engine.mainMixerNode.outputVolume = 0.7
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
            try engine.start()
            started = true
        } catch {
            started = false
        }
    }

    func applySettings(_ settings: GameSettings) {
        soundEnabled = settings.soundEnabled
        musicEnabled = settings.musicEnabled
        ambienceEnabled = settings.ambienceEnabled
        if ambienceEnabled && musicEnabled {
            startAmbience()
        } else {
            ambiencePlayer.stop()
        }
    }

    func startAmbience() {
        guard started, let format, musicEnabled, ambienceEnabled else { return }
        guard let buffer = makeAmbienceBuffer(format: format) else { return }
        ambiencePlayer.stop()
        ambiencePlayer.scheduleBuffer(buffer, at: nil, options: [.loops])
        ambiencePlayer.volume = 0.18
        ambiencePlayer.play()
    }

    func playTap() { play(frequencies: [523.25], duration: 0.10, volume: 0.12, attack: 0.005) }
    func playWire() { play(frequencies: [392.0], duration: 0.08, volume: 0.10, attack: 0.004) }
    func playBloom() { play(frequencies: [523.25, 659.25, 783.99], duration: 1.1, volume: 0.22, attack: 0.02) }
    func playSolve() { play(frequencies: [392.0, 523.25, 659.25, 880.0], duration: 1.4, volume: 0.25, attack: 0.02) }
    func playUnlock() { play(frequencies: [659.25, 987.77], duration: 0.9, volume: 0.2, attack: 0.01) }
    func playPrestige() { play(frequencies: [261.63, 392.0, 523.25, 659.25, 783.99], duration: 2.2, volume: 0.28, attack: 0.05) }

    private func play(frequencies: [Double], duration: Double, volume: Float, attack: Double) {
        guard started, soundEnabled, let format else { return }
        guard let buffer = makeChimeBuffer(format: format, frequencies: frequencies, duration: duration, attack: attack) else { return }
        chimePlayer.volume = volume
        if !chimePlayer.isPlaying { chimePlayer.play() }
        chimePlayer.scheduleBuffer(buffer, at: nil, options: [])
    }

    private func makeChimeBuffer(format: AVAudioFormat, frequencies: [Double], duration: Double, attack: Double) -> AVAudioPCMBuffer? {
        let sampleRate = format.sampleRate
        let frameCount = AVAudioFrameCount(sampleRate * duration)
        guard frameCount > 0, let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else { return nil }
        buffer.frameLength = frameCount
        guard let channel = buffer.floatChannelData?[0] else { return nil }
        let release = duration - attack
        for frame in 0..<Int(frameCount) {
            let t = Double(frame) / sampleRate
            var envelope = 1.0
            if t < attack {
                envelope = t / attack
            } else {
                envelope = exp(-(t - attack) / max(0.0001, release) * 3.2)
            }
            var sample = 0.0
            for (index, frequency) in frequencies.enumerated() {
                let delay = Double(index) * 0.06
                guard t >= delay else { continue }
                sample += sin(2 * Double.pi * frequency * (t - delay)) / Double(frequencies.count)
            }
            channel[frame] = Float(sample * envelope)
        }
        return buffer
    }

    private func makeAmbienceBuffer(format: AVAudioFormat) -> AVAudioPCMBuffer? {
        let sampleRate = format.sampleRate
        let duration = 8.0
        let frameCount = AVAudioFrameCount(sampleRate * duration)
        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else { return nil }
        buffer.frameLength = frameCount
        guard let channel = buffer.floatChannelData?[0] else { return nil }
        let partials: [(Double, Double)] = [(130.81, 0.5), (196.0, 0.3), (261.63, 0.22), (329.63, 0.16)]
        for frame in 0..<Int(frameCount) {
            let t = Double(frame) / sampleRate
            var sample = 0.0
            for (frequency, amplitude) in partials {
                let lfo = 0.5 + 0.5 * sin(2 * Double.pi * 0.05 * t + frequency)
                sample += sin(2 * Double.pi * frequency * t) * amplitude * lfo
            }
            let fade = min(1, min(t, duration - t) / 1.5)
            channel[frame] = Float(sample * 0.2 * fade)
        }
        return buffer
    }
}
