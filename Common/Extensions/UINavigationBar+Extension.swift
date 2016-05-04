//
//  UINavigationBar+Extension.swift
//  SVIP
//
//  Created by Qin Yejun on 5/4/16.
//  Copyright © 2016 zkjinshi. All rights reserved.
//

import UIKit

extension UINavigationBar {
  private struct AssociatedKeys {
    static var NavigationOverlay = "yj_navigation_overlay"
  }
  
  var overlay:UIView? {
    get {
      return objc_getAssociatedObject(self,  &AssociatedKeys.NavigationOverlay) as? UIView
    }
    set {
      objc_setAssociatedObject(
        self,
        &AssociatedKeys.NavigationOverlay,
        newValue as UIView?,
        .OBJC_ASSOCIATION_RETAIN_NONATOMIC
      )
    }
  }
  
  func yj_setBackgroundColor(color:UIColor) {
    if self.overlay == nil {
      setBackgroundImage(UIImage(), forBarMetrics: .Default)
      overlay = UIView(frame: CGRectMake(0,-20,CGRectGetWidth(bounds),CGRectGetHeight(bounds) + 20))
      overlay!.userInteractionEnabled = false
      overlay!.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
      insertSubview(overlay!, atIndex: 0)
    }
    overlay!.backgroundColor = color
  }
}