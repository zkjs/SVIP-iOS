//
//  PushMessageVC.swift
//  SVIP
//
//  Created by Qin Yejun on 4/5/16.
//  Copyright © 2016 zkjinshi. All rights reserved.
//

import UIKit

class PushMessageVC: UIViewController {

  @IBOutlet weak var pushContens: UILabel!
  @IBOutlet weak var pushTitle: UIButton!
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
    self.view.insertSubview(blurView, atIndex: 0)
  }
  override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
    super.touchesBegan(touches, withEvent: event)
    self.view.removeFromSuperview()
  }
  
}
