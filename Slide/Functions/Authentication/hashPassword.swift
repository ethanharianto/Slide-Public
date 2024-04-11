////
////  hashPassword.swift
////  Slide
////
////  Created by Thomas on 8/30/23.
////
//
//import Foundation
//import CommonCrypto
//
//import Foundation
//import CommonCrypto
//
//func generateSaltedHash(for string: String, cycles: Int = 1) -> (hashedValue: Data, salt: Data, cycles: Int)? {
//    var salt = Data(count: 8)
//    
//    _ = salt.withUnsafeMutableBytes { mutableBytes in
//        SecRandomCopyBytes(kSecRandomDefault, salt.count, mutableBytes.baseAddress!)
//    }
//    
//    let localSalt = Data(salt) // Create a local copy of salt
//    
//    let saltedData = salt + Data(string.utf8)
//    
//    var hash = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
//    _ = saltedData.withUnsafeBytes { dataBytes in
//        CC_SHA256(dataBytes.baseAddress, CC_LONG(saltedData.count), &hash)
//    }
//    let hashData = Data(hash)
//    
//    return (hashData, localSalt, cycles)
//}
//
//// Example usage
//// if let result = generateSaltedHash(for: "your_input_string", cycles: 1) {
////     let (hashedValue, salt, cycles) = result
////     print("Hashed value: \(hashedValue.map { String(format: "%02hhx", $0) }.joined())")
////     print("Salt value: \(salt.map { String(format: "%02hhx", $0) }.joined())")
////     print("Cycles: \(cycles)")
//// } else {
////     print("Hash generation failed.")
//// }
