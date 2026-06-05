import AVFoundation
import SwiftUI
import UIKit

struct CameraPreviewView: UIViewRepresentable {
    let session: AVCaptureSession

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

    func attach(session: AVCaptureSession) {
        previewLayer.session = session
        previewLayer.videoGravity = .resizeAspectFill
        updateVideoOrientation()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        previewLayer.frame = bounds
        updateVideoOrientation()
    }

    func updateVideoOrientation() {
        guard let connection = previewLayer.connection else { return }
        if #available(iOS 17.0, *) {
            let angle: CGFloat
            switch window?.windowScene?.interfaceOrientation {
            case .portrait: angle = 90
            case .portraitUpsideDown: angle = 270
            case .landscapeLeft: angle = 0
            case .landscapeRight: angle = 180
            default: angle = 90
            }
            if connection.isVideoRotationAngleSupported(angle) {
                connection.videoRotationAngle = angle
            }
        } else if connection.isVideoOrientationSupported {
            let orientation: AVCaptureVideoOrientation
            switch window?.windowScene?.interfaceOrientation {
            case .portrait: orientation = .portrait
            case .portraitUpsideDown: orientation = .portraitUpsideDown
            case .landscapeLeft: orientation = .landscapeLeft
            case .landscapeRight: orientation = .landscapeRight
            default: orientation = .portrait
            }
            connection.videoOrientation = orientation
        }
    }
}
