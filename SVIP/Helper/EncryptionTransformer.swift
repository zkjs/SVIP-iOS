//
//  EncryptionTransformer.swift
//  SVIP
//
//  Created by Hanton on 7/28/15.
//  Copyright (c) 2015 zkjinshi. All rights reserved.
//

import UIKit
import Foundation
import Security

class EncryptionTransformer: NSValueTransformer {
  let saltLength: UInt = 8
  
  override class func transformedValueClass() -> AnyClass {
    return NSData.self
  }
  
  override func transformedValue(value: AnyObject?) -> AnyObject? {
    // We're passed in a string (NSString) that we're going to encrypt. 
    // The format of the bytes we return is:
    // salt (16 bytes) | IV (16 bytes) | encrypted string
    
    let salt = randomDataOfLength(saltLength)
    let iv = randomDataOfLength(UInt(kCCBlockSizeAES128))
    
    let data = value?.dataUsingEncoding(NSUTF8StringEncoding)
    // Do the actual encryption
    let result = transform(data!, password: password()!, salt: salt, iv: iv, operation: UInt32(kCCEncrypt))
    
    // Build the response data
    let response = NSMutableData()
    response.appendData(salt)
    response.appendData(iv)
    response.appendData(result!)
    return response
  }
  
  func transform(value: NSData, password: String, salt: NSData, iv: NSData, operation: CCOperation) -> NSData? {
    // Get the key by salting the password
    let key = keyForPassword(password, salt: salt)
    
    var outputSize: Int = 0
    
    // Perform the operation (encryption or decryption)
    let outputData = NSMutableData(length: value.length + kCCBlockSizeAES128)
    let algorithm: CCAlgorithm = UInt32(kCCAlgorithmAES128)
    let options: CCOptions = UInt32(kCCOptionPKCS7Padding)
    let status = CCCrypt(operation, algorithm, options, key.bytes, key.length, iv.bytes, value.bytes, value.length, outputData!.mutableBytes, outputData!.length, &outputSize)
    
    // On success, set the size and return the data
    // On failure, return nil
    if UInt32(status) == UInt32(kCCSuccess) {
      outputData?.length = Int(outputSize)
      return outputData
    } else {
      return nil
    }
  }
  
  override func reverseTransformedValue(value: AnyObject?) -> AnyObject? {
    // We're passed in bytes (NSData) from Core Data that we're going to transform
    // into a string (NSString) and return to the application. 
    let data = value as! NSData?
    if let data = data {
      let salt = data.subdataWithRange(NSMakeRange(0, Int(saltLength)))
      let iv = data.subdataWithRange(NSMakeRange(Int(saltLength), kCCBlockSizeAES128))
      let text = data.subdataWithRange(NSMakeRange(Int(saltLength) + kCCBlockSizeAES128, data.length - Int(saltLength) - kCCBlockSizeAES128))
      
      // Get the decrypted data
      let decrypted = transform(text, password: password()!, salt: salt, iv: iv, operation: UInt32(kCCDecrypt))
      
      // Return only the decrypted data
      return NSString(data: decrypted!, encoding: NSUTF8StringEncoding)
    } else {
      return nil
    }
  }
  
  func sha1(data: NSData) -> NSData {
    // Get the SHA1 into an array
    var digest = [UInt8](count: Int(CC_SHA1_DIGEST_LENGTH), repeatedValue: 0)
    CC_SHA1(data.bytes, CC_LONG(data.length), &digest)
    
    // Create a formatted string with the SHA1
    let sha1 = NSMutableString(capacity: Int(CC_SHA1_DIGEST_LENGTH))
    for byte in digest {
      sha1.appendFormat("%02x", byte)
    }
    
    return sha1.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!
  }
  
  func keyForPassword(password: String, salt: NSData) -> NSData {
    // Append the salt to the password
    let passwordAndSalt = password.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)?.mutableCopy() as? NSMutableData
    passwordAndSalt?.appendData(salt)
    
    // Hash it
    let hash = sha1(passwordAndSalt!)
    
    // Create the key by using the hashed password and salt, making
    // it the proper size for AES128 (0-padding if necessary)
    let range = NSMakeRange(0, min(hash.length, kCCBlockSizeAES128))
    let key = NSMutableData(length: kCCBlockSizeAES128)
    key?.replaceBytesInRange(range, withBytes: hash.bytes)
    return key!
  }
  
  func randomDataOfLength(length: UInt) -> NSData {
    let data = NSMutableData(length: Int(length))
    let dataPointer = UnsafeMutablePointer<UInt8>(data!.mutableBytes)
    SecRandomCopyBytes(kSecRandomDefault, Int(length), dataPointer)
    return data!
  }
  
  func password() -> String? {
    let password = "zkjinshi^"
    return password
  }
   
}
