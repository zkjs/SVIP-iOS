//
//  RegisterAlertVC.swift
//  SVIP
//
//  Created by Qin Yejun on 4/7/16.
//  Copyright © 2016 zkjinshi. All rights reserved.
//

import UIKit

class RegisterAlertVC: UIViewController {
  
  @IBOutlet weak var containerView: UIView!
  
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
    containerView.alpha = 0
  }
  
  override func viewDidAppear(animated: Bool) {
    animateView()
  }
  
  private func animateView() {
    containerView.frame = CGRectOffset(containerView.frame, 0, -ScreenSize.SCREEN_HEIGHT)
    UIView.animateWithDuration(0.5, delay: 0.0,
                   usingSpringWithDamping: 0.6,
                    initialSpringVelocity: 0.0,
                                  options: .CurveEaseInOut,
                               animations: {
        self.containerView.frame = CGRectOffset(self.containerView.frame, 0, +ScreenSize.SCREEN_HEIGHT)
        self.containerView.alpha = 1
      },completion: { (finished) in
        
    })
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
