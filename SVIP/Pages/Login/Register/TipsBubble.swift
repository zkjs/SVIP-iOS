//
//  PushMessageVC.swift
//  SVIP
//
//  Created by Qin Yejun on 4/5/16.
//  Copyright © 2016 zkjinshi. All rights reserved.
//

import UIKit

class TipsBubble: UIViewController {
  var tipsContent: String?
  var anglePoint: CGPoint?

  @IBOutlet weak var contentLabel: UILabel!
  @IBOutlet weak var containerView: UIView!
  @IBOutlet weak var angelImage: UIImage!
  @IBOutlet weak var topConstraint: NSLayoutConstraint!
  @IBOutlet weak var leadingConstraint: NSLayoutConstraint!
  @IBOutlet weak var widthConstraint: NSLayoutConstraint!
  
  lazy var blurView: UIVisualEffectView = {
    let blur = UIBlurEffect(style: .Dark)
    let blurView = UIVisualEffectView(effect: blur)
    blurView.frame = self.view.bounds
    blurView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
    blurView.translatesAutoresizingMaskIntoConstraints = true
    blurView.alpha = 0.6
    return blurView
  }()
  
  override func loadView() {
    NSBundle.mainBundle().loadNibNamed("TipsBubble", owner:self, options:nil)
  }
  
  override func viewDidLoad() {
    
    super.viewDidLoad()

    self.view.insertSubview(blurView, atIndex: 0)
    
    if let anglePoint = anglePoint {
      topConstraint.constant = anglePoint.y - 8
      leadingConstraint.constant = anglePoint.x - 26
    }
    
    contentLabel.text = tipsContent ?? "隐私信息未经本人许可严格保密"
    
    widthConstraint.constant = 1
    blurView.alpha = 0
  }
  
  override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
    super.touchesEnded(touches, withEvent: event)
    
    UIView.animateWithDuration(0.3, delay: 0, options: [.CurveEaseInOut], animations: {
      self.blurView.alpha = 0
      self.widthConstraint.constant = 1
      self.containerView.layoutIfNeeded()
      },completion: { (finished) -> Void in
      self.dismissViewControllerAnimated(false, completion: nil)
    })
  }
  
  override func viewDidAppear(animated: Bool) {
    widthConstraint.constant = 1
    UIView.animateWithDuration(0.3, delay: 0, options: [.CurveEaseInOut], animations: {
      self.blurView.alpha = 0.6
      self.widthConstraint.constant = 210
      self.containerView.layoutIfNeeded()
      },completion:  nil)
  }
  
}
