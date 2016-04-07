//
//  RegisterAlertVC.swift
//  SVIP
//
//  Created by Qin Yejun on 4/7/16.
//  Copyright © 2016 zkjinshi. All rights reserved.
//

import UIKit

class RegisterAlertVC: UIViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let blur = UIBlurEffect(style: .Dark)
    let blurView = UIVisualEffectView(effect: blur)
    blurView.frame = self.view.bounds
    blurView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
    blurView.translatesAutoresizingMaskIntoConstraints = true
    blurView.alpha = 0.8
    self.view.insertSubview(blurView, atIndex: 0)
    
    let tap = UITapGestureRecognizer(target: self, action: "dismiss")
    view.addGestureRecognizer(tap)
  }
  
  @IBAction func registerAction(sender: UIButton) {
    dismissViewControllerAnimated(true) { 
      let vc = WebViewVC()
      vc.url = ZKJSConfig.sharedInstance.RegisterURL
      if let rootVC = UIApplication.sharedApplication().keyWindow?.rootViewController as? BaseNC {
        rootVC.pushViewController(vc, animated: true)
      } else {
        UIApplication.sharedApplication().openURL(NSURL(string: ZKJSConfig.sharedInstance.RegisterURL)!)
      }
    }
  }
  
  func dismiss() {
    dismissViewControllerAnimated(true, completion: nil)
  }
}
