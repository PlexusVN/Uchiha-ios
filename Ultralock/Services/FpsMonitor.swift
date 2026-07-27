import SwiftUI
import QuartzCore

final class FpsMonitor: ObservableObject {
    static let shared = FpsMonitor()

    @Published var state = FpsState(currentFps: 60, maxRefreshRate: 60, qualityLevel: .high, frameTimeMs: 16.67)

    private var displayLink: CADisplayLink?
    private var lastTimestamp: CFTimeInterval = 0
    private var frameCount: UInt = 0
    private var fpsAccumulator: Double = 0

    private init() {}

    func start() {
        stop()
        displayLink = CADisplayLink(target: self, selector: #selector(tick))
        displayLink?.add(to: .main, forMode: .common)
    }

    func stop() {
        displayLink?.invalidate()
        displayLink = nil
    }

    @objc private func tick(link: CADisplayLink) {
        if lastTimestamp == 0 {
            lastTimestamp = link.timestamp
            return
        }
        frameCount += 1
        let elapsed = link.timestamp - lastTimestamp
        if elapsed >= 1.0 {
            let fps = Double(frameCount) / elapsed
            let maxRate = max(link.preferredFrameRateRange.maximum, 60)
            let quality = QualityLevel.fromFps(fps)
            let frameTime = (elapsed / Double(frameCount)) * 1000
            DispatchQueue.main.async { [weak self] in
                self?.state = FpsState(
                    currentFps: fps,
                    maxRefreshRate: Double(maxRate),
                    qualityLevel: quality,
                    frameTimeMs: frameTime
                )
            }
            frameCount = 0
            lastTimestamp = link.timestamp
        }
    }
}
