import UIKit
import SwiftUI

final class OverlayManager: ObservableObject {
    static let shared = OverlayManager()

    private var bubbleWindow: UIWindow?
    private var crosshairWindow: UIWindow?
    private var crosshairHosting: UIHostingController<CrosshairOverlayView>?

    private init() {}

    // MARK: - Bubble Menu
    func showBubbleMenu() {
        hideBubbleMenu()
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
        let window = UIWindow(windowScene: scene)
        window.windowLevel = .alert + 2
        window.isHidden = false
        window.backgroundColor = .clear

        let hosting = UIHostingController(rootView: BubbleMenuView())
        hosting.view.backgroundColor = .clear
        window.rootViewController = hosting
        bubbleWindow = window
    }

    func hideBubbleMenu() {
        bubbleWindow?.isHidden = true
        bubbleWindow = nil
    }

    // MARK: - Crosshair Overlay
    func showCrosshair(color: Color = .red, tier: String = "pro", offsetX: Int = 0, offsetY: Int = 0) {
        if crosshairWindow != nil {
            updateCrosshair(color: color, tier: tier, offsetX: offsetX, offsetY: offsetY)
            return
        }
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
        let window = UIWindow(windowScene: scene)
        window.windowLevel = .statusBar + 1
        window.isHidden = false
        window.backgroundColor = .clear

        let view = CrosshairOverlayView(color: color, tier: tier, offsetX: CGFloat(offsetX), offsetY: CGFloat(offsetY))
        let hosting = UIHostingController(rootView: view)
        hosting.view.backgroundColor = .clear
        hosting.view.isUserInteractionEnabled = false
        window.rootViewController = hosting
        crosshairHosting = hosting
        crosshairWindow = window
    }

    func updateCrosshair(color: Color = .red, tier: String = "pro", offsetX: Int = 0, offsetY: Int = 0) {
        if let hosting = crosshairHosting {
            hosting.rootView = CrosshairOverlayView(color: color, tier: tier, offsetX: CGFloat(offsetX), offsetY: CGFloat(offsetY))
        } else {
            showCrosshair(color: color, tier: tier, offsetX: offsetX, offsetY: offsetY)
        }
    }

    func hideCrosshair() {
        crosshairWindow?.isHidden = true
        crosshairWindow = nil
        crosshairHosting = nil
    }
}
