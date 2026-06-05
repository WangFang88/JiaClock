import AVFoundation
import Foundation
import UIKit

@MainActor
final class CameraPermissionService: ObservableObject {
    enum Status: Equatable {
        case notDetermined
        case authorized
        case denied
        case restricted
        case unavailable
    }

    @Published private(set) var status: Status = .notDetermined

    init() {
        refreshStatus()
    }

    func refreshStatus() {
        if isSimulatorOrNoCamera {
            status = .unavailable
            return
        }

        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .notDetermined: status = .notDetermined
        case .authorized: status = .authorized
        case .denied: status = .denied
        case .restricted: status = .restricted
        @unknown default: status = .denied
        }
    }

    func requestAccessIfNeeded() async -> Status {
        refreshStatus()
        switch status {
        case .authorized: return .authorized
        case .denied, .restricted, .unavailable: return status
        case .notDetermined:
            let granted = await AVCaptureDevice.requestAccess(for: .video)
            refreshStatus()
            return granted ? .authorized : status
        }
    }

    var canOpenSettings: Bool { status == .denied }

    func openSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }

    var isSimulatorOrNoCamera: Bool {
        #if targetEnvironment(simulator)
        return true
        #else
        return AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) == nil
        #endif
    }
}
