//
//  UIView.swift
//  SuperService
//
//  Created by Hanton on 11/12/15.
//  Copyright © 2015 ZKJS. All rights reserved.
//

import Foundation

extension UIView {

  @IBInspectable var cornerRadius: CGFloat {
    get {
      return layer.cornerRadius
    }
    set {
      layer.cornerRadius = newValue
      layer.masksToBounds = newValue > 0
    }
  }

}
