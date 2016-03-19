//
//  RoundedImageView.swift
//  SVIP
//
//  Created by Qin Yejun on 3/19/16.
//  Copyright © 2016 zkjinshi. All rights reserved.
//

import UIKit

@IBDesignable
class RoundedImageView: UIImageView {
  
  @IBInspectable
  override var cornerRadius: CGFloat {
    get {
      return layer.cornerRadius
    }
    set {
      layer.cornerRadius = newValue
      layer.masksToBounds = newValue > 0
    }
  }
  
  @IBInspectable
  var borderColor: UIColor {
    get {
      if let color = layer.borderColor {
        return UIColor(CGColor: color)
      }
      return UIColor.clearColor()
    }
    set {
      layer.borderColor = newValue.CGColor
    }
  }

  @IBInspectable
  var borderWidth:Float {
    get {
      return Float(layer.borderWidth)
    }
    set {
      layer.borderWidth = CGFloat(newValue)
    }
  }
  
}
