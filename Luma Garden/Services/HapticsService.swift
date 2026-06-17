import UIKit

final class HapticsService {
    var enabled = true

    private let light = UIImpactFeedbackGenerator(style: .light)
    private let soft = UIImpactFeedbackGenerator(style: .soft)
    private let medium = UIImpactFeedbackGenerator(style: .medium)
    private let notification = UINotificationFeedbackGenerator()

    func prepare() {
        light.prepare()
        soft.prepare()
        medium.prepare()
    }

    func tap() {
        guard enabled else { return }
        light.impactOccurred(intensity: 0.5)
    }

    func wire() {
        guard enabled else { return }
        soft.impactOccurred(intensity: 0.4)
    }

    func bloom() {
        guard enabled else { return }
        soft.impactOccurred(intensity: 0.8)
    }

    func solved() {
        guard enabled else { return }
        notification.notificationOccurred(.success)
    }

    func unlock() {
        guard enabled else { return }
        medium.impactOccurred(intensity: 0.7)
    }
}
