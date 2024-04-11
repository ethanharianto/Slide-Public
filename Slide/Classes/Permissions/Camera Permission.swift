//
//  Camera Permission.swift
//  Slide
//
//  Created by Ethan Harianto on 7/21/23.
//

import Foundation
import PhotosUI

class CameraPermission: NSObject, ObservableObject {
    
    @Published var isCameraPermission: Bool = false
    @Published var authorizationStatus: AVAuthorizationStatus = .notDetermined
    
    override init() {
        super.init()
        self.authorizationStatus = checkCameraPermission()
    }
    
    func checkCameraPermission() -> AVAuthorizationStatus {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        return status
    }
    
    func requestCameraPermission() {
        AVCaptureDevice.requestAccess(for: .video) { [weak self] accessGranted in
            DispatchQueue.main.async {
                self?.handleCameraPermissionStatus(accessGranted ? .authorized : .denied)
            }
        }
    }
    
    private func handleCameraPermissionStatus(_ status: AVAuthorizationStatus) {
        switch status {
        case .authorized:
            isCameraPermission = true
        case .notDetermined:
            isCameraPermission = false
        case .denied, .restricted:
            isCameraPermission = false
        @unknown default:
            isCameraPermission = false
        }
    }
}
