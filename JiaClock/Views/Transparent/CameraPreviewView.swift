import AVFoundation
import SwiftUI
import UIKit

struct CameraPreviewView: UIViewRepresentable {
    let session: AVCaptureSession
    var orientationToken: UIDeviceOrientation = .unknown

    func makeUIView(context: Context) -> CameraPreviewUIView {
        let view = CameraPreviewUIView()
        view.attach(session: session)
        return view
    }

    func updateUIView(_ uiView: CameraPreviewUIView, context: Context) {
        uiView.attach(session: session)
        uiView.updateVideoOrientation()
    }
}

final class CameraPreviewUIView: UIView {
    override class var layerClass: AnyClass { AVCaptureVideoPreviewLayer.self }

    private var previewLayer: AVCaptureVideoPreviewLayer {
        layer as! AVCaptureVideoPreviewLayer
    }

    private var orientationObserver: NSObjectProtocol?

    func attach(session: AVCaptureSession) {
        if previewLayer.session !== session {
            previewLayer.session = session
        }
        previewLayer.videoGravity = .resizeAspectFill
        updateVideoOrientation()
    }

    override func didMoveToWindow() {
        super.didMoveToWindow()
        if window != nil {
            UIDevice.current.beginGeneratingDeviceOrientationNotifications()
            if orientationObserver == nil {
                orientationObserver = NotificationCenter.default.addObserver(
                    forName: UIDevice.orientationDidChangeNotification,
                    object: nil,
                    queue: .main
                ) { [weak self] _ in
                    self?.updateVideoOrientation()
                }
            }
            updateVideoOrientation()
        } else {
            tearDownOrientationObserver()
        }
    }

    deinit {
        tearDownOrientationObserver()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        previewLayer.frame = bounds
        updateVideoOrientation()
    }

    func updateVideoOrientation() {
        guard let connection = previewLayer.connection else { return }
        let angle: CGFloat
        switch currentInterfaceOrientation() {
        case .portrait: angle = 90
        case .portraitUpsideDown: angle = 270
        case .landscapeLeft: angle = 180
        case .landscapeRight: angle = 0
        default: angle = 90
        }
        if connection.isVideoRotationAngleSupported(angle) { connection.videoRotationAngle = angle }
    }

    private func currentInterfaceOrientation() -> UIInterfaceOrientation {
        if let orientation = window?.windowScene?.interfaceOrientation {
            return orientation
        }
        switch UIDevice.current.orientation {
        case .portrait: return .portrait
        case .portraitUpsideDown: return .portraitUpsideDown
        case .landscapeLeft: return .landscapeRight
        case .landscapeRight: return .landscapeLeft
        default:
            if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                return scene.interfaceOrientation
            }
            return .portrait
        }
    }

    private func tearDownOrientationObserver() {
        if let orientationObserver {
            NotificationCenter.default.removeObserver(orientationObserver)
            self.orientationObserver = nil
        }
        UIDevice.current.endGeneratingDeviceOrientationNotifications()
    }
}
