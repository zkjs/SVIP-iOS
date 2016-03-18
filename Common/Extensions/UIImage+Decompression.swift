//
//  UIImage+Decompression.swift
//  SVIP
//
//  Created by Hanton on 8/31/15.
//  Copyright (c) 2015 zkjinshi. All rights reserved.
//

import Foundation

extension UIImage {
  
  var decompressedImage: UIImage {
    UIGraphicsBeginImageContextWithOptions(size, true, 0)
    drawAtPoint(CGPointZero)
    let decompressedImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return decompressedImage
  }
  
}
