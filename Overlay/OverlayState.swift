import SwiftUI
internal import Combine

class OverlayState: ObservableObject {
    @Published var isActive: Bool = true       // overlay runs on launch by default
    @Published var speed: Double = 0.3         // Hz (cycles per second) — slow by default
    @Published var shape: String = "pig"        // triangle, circle, diamond, pig
    @Published var lettersEnabled: Bool = true
    @Published var objectColor: Color = .green
    @Published var overlayOpacity: Double = 0.12
}
