//
//  PushMessageVC.swift
//  SVIP
//
//  Created by Qin Yejun on 4/5/16.
//  Copyright © 2016 zkjinshi. All rights reserved.
//

import UIKit

class PushMessageVC: UIViewController {
  var alertTitle: String?
  var alertContent: String?

  @IBOutlet weak var contentLabel: UILabel!
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var pushView: UIView!
  
  override func loadView() {
    NSBundle.mainBundle().loadNibNamed("PushMessageVC", owner:self, options:nil)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    let blur = UIBlurEffect(style: .Dark)
    let blurView = UIVisualEffectView(effect: blur)
    blurView.frame = self.view.bounds
    blurView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
    blurView.translatesAutoresizingMaskIntoConstraints = true
    blurView.alpha = 0.8
    self.view.insertSubview(blurView, atIndex: 0)
    
    titleLabel.text = alertTitle ?? ""
    contentLabel.text = alertContent ?? ""
  }
  
  override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
    super.touchesEnded(touches, withEvent: event)
    dismissViewControllerAnimated(true, completion: nil)
  }
  
}
