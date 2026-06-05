import AVFoundation

final class CameraSessionController: ObservableObject {
    let session = AVCaptureSession()

    private let sessionQueue = DispatchQueue(label: "com.jiaclock.camera.session", qos: .userInitiated)
    private var isConfigured = false
    private(set) var isRunning = false

    var isCameraAvailable: Bool {
        #if targetEnvironment(simulator)
        return false
        #else
        return AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) != nil
        #endif
    }

    func prepareIfNeeded() {
        sessionQueue.async { [weak self] in
            self?.configureSessionIfNeeded()
        }
    }

    func start() {
        guard isCameraAvailable else { return }
        prepareIfNeeded()
        sessionQueue.async { [weak self] in
            guard let self, !self.session.isRunning else { return }
            self.session.startRunning()
            DispatchQueue.main.async { self.isRunning = true }
        }
    }

    func stop() {
        sessionQueue.async { [weak self] in
            guard let self, self.session.isRunning else { return }
            self.session.stopRunning()
            DispatchQueue.main.async { self.isRunning = false }
        }
    }

    private func configureSessionIfNeeded() {
        guard !isConfigured, isCameraAvailable else { return }
        session.beginConfiguration()
        defer { session.commitConfiguration() }
        session.sessionPreset = .high
        for input in session.inputs { session.removeInput(input) }
        guard
            let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
            let input = try? AVCaptureDeviceInput(device: device),
            session.canAddInput(input)
        else { return }
        session.addInput(input)
        isConfigured = true
    }
}
