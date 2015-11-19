//
//  UIViewController+HUD.swift
//  SuperService
//
//  Created by Hanton on 11/11/15.
//  Copyright © 2015 ZKJS. All rights reserved.
//

import Foundation

extension UIViewController {

  func showAlertWithTitle(title: String, message: String) {
    let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
    let okAction = UIAlertAction(title: NSLocalizedString("OK", comment: "OK action"), style: .Default, handler: nil)
    alertController.addAction(okAction)
    presentViewController(alertController, animated: true, completion: nil)
  }
  
}

extension UIViewController {
  
  public override class func initialize() {
    struct Static {
      static var token: dispatch_once_t = 0
    }
    
    // make sure this isn't a subclass
    if self !== UIViewController.self {
      return
    }
    
    dispatch_once(&Static.token) {
      let originalSelector = Selector("viewWillAppear:")
      let swizzledSelector = Selector("ZKJS_viewWillAppear:")
      
      let originalMethod = class_getInstanceMethod(self, originalSelector)
      let swizzledMethod = class_getInstanceMethod(self, swizzledSelector)
      
      let didAddMethod = class_addMethod(self, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod))
      
      if didAddMethod {
        class_replaceMethod(self, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod))
      } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
      }
    }
  }
  
  // MARK: - Method Swizzling
  
  func ZKJS_viewWillAppear(animated: Bool) {
    self.ZKJS_viewWillAppear(animated)
    print(NSStringFromClass(self.dynamicType))
//    if let name = self.descriptiveName {
//      print("viewWillAppear: \(name)")
//    } else {
//      print("viewWillAppear: \(self)")
//    }
  }
}
