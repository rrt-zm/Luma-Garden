import Foundation

final class GameClock {
    private var timer: Timer?
    private var lastTick: Date?
    private let interval: TimeInterval
    var onTick: ((Double) -> Void)?

    init(interval: TimeInterval = 1.0 / 20.0) {
        self.interval = interval
    }

    func start() {
        stop()
        lastTick = Date()
        let timer = Timer(timeInterval: interval, repeats: true) { [weak self] _ in
            self?.fire()
        }
        RunLoop.main.add(timer, forMode: .common)
        self.timer = timer
    }

    func stop() {
        timer?.invalidate()
        timer = nil
        lastTick = nil
    }

    private func fire() {
        let now = Date()
        let delta = now.timeIntervalSince(lastTick ?? now)
        lastTick = now
        guard delta > 0 else { return }
        onTick?(min(delta, 1.0))
    }
}
