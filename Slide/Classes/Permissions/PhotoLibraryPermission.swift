//
//  PhotoLibraryPermission.swift
//  Slide
//
//  Created by Ethan Harianto on 8/10/23.
//

import Foundation
import PhotosUI

class PhotoLibraryPermission: NSObject, ObservableObject {
    @Published var isPhotoLibraryPermission: Bool = false
    @Published var authorizationStatus: PHAuthorizationStatus = .notDetermined
    
    override init() {
        super.init()
        self.authorizationStatus = checkPhotoLibraryPermission()
    }
    
    func checkPhotoLibraryPermission() -> PHAuthorizationStatus {
        let status = PHPhotoLibrary.authorizationStatus()
        return status
    }

//    func requestPhotoLibraryPermission() {
//        PHPhotoLibrary.requestAuthorization { status in
//            DispatchQueue.main.async {
//                self.handlePhotoLibraryPermissionStatus(status ? .authorized : .denied)
//            }
//        }
//    }
    
    private func handlePhotoLibraryPermissionStatus(_ status: PHAuthorizationStatus) {
        switch status {
        case .authorized:
            isPhotoLibraryPermission = true
        case .notDetermined:
            isPhotoLibraryPermission = false
        case .denied, .restricted:
            isPhotoLibraryPermission = false
        case .limited:
            isPhotoLibraryPermission = false
        @unknown default:
            isPhotoLibraryPermission = false
        }
    }
}
