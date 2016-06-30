//
//  PushMessageVC.swift
//  SVIP
//
//  Created by Qin Yejun on 4/5/16.
//  Copyright © 2016 zkjinshi. All rights reserved.
//

import UIKit

class PushMessageVC: UIViewController {
  var pushInfo: PushMessage?

  @IBOutlet weak var contentLabel: UILabel!
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var imageView: UIImageView!
  @IBOutlet weak var linkButton: UIButton!
  @IBOutlet weak var pushView: UIView!
  @IBOutlet weak var linkButtonHeightConstraint: NSLayoutConstraint!
  @IBOutlet weak var seperator: UIView!
  @IBOutlet weak var constraintLinkBottom: NSLayoutConstraint!
  @IBOutlet weak var attendButton: UIButton!
  
  private var blurView: UIVisualEffectView!
  
  override func loadView() {
    NSBundle.mainBundle().loadNibNamed("PushMessageVC", owner:self, options:nil)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    let blur = UIBlurEffect(style: .Dark)
    blurView = UIVisualEffectView(effect: blur)
    blurView.frame = self.view.bounds
    blurView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
    blurView.translatesAutoresizingMaskIntoConstraints = true
    blurView.alpha = 0.8
    self.view.insertSubview(blurView, atIndex: 0)
    
    titleLabel.text = pushInfo?.title ?? ""
    contentLabel.text = pushInfo?.content ?? ""
    if let imgUrl = pushInfo?.imgUrl, url = NSURL(string: imgUrl.fittedImageUrl) {
      imageView.sd_setImageWithURL(url)
    }
    if let linkTitle = pushInfo?.linkTitle, link =  pushInfo?.link, _ = NSURL(string: link)
      where !link.isEmpty && !linkTitle.isEmpty {
      linkButton.setTitle(linkTitle, forState: .Normal)
    } else {
      linkButtonHeightConstraint.constant = 0
      seperator.hidden = true
      linkButton.hidden = true
    }
    if let _ = pushInfo?.actid {
      constraintLinkBottom.constant = 50
      linkButtonHeightConstraint.constant = 50
      linkButton.setTitle("查看详情", forState: .Normal)
      linkButton.hidden = false
      attendButton.hidden = false
    }
    
    pushView.alpha = 0
  }
  
  override func viewDidAppear(animated: Bool) {
    animateView()
  }

  
  override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
    super.touchesEnded(touches, withEvent: event)
    dismiss()
  }
  
  private func animateView() {
    pushView.frame = CGRectOffset(pushView.frame, 0, -ScreenSize.SCREEN_HEIGHT)
    UIView.animateWithDuration(0.5, delay: 0.0,
                   usingSpringWithDamping: 0.6,
                    initialSpringVelocity: 0.0,
                                  options: .CurveEaseInOut,
                               animations: {
        self.pushView.frame = CGRectOffset(self.pushView.frame, 0, +ScreenSize.SCREEN_HEIGHT)
        self.pushView.alpha = 1
      },completion: nil)
  }
  
  private func dismiss() {
    UIView.animateKeyframesWithDuration(0.8,
                                 delay: 0.0,
                               options: [.CalculationModeCubic],
                            animations: {
        UIView.addKeyframeWithRelativeStartTime(0.0, relativeDuration: 0.4, animations: {
          self.pushView.transform = CGAffineTransformMakeScale(0.5, 0.5)
          self.pushView.alpha = 0.5
          self.blurView.alpha = 0.5
        })
        
        UIView.addKeyframeWithRelativeStartTime(0.5, relativeDuration: 0.5, animations: {
          self.pushView.frame = CGRectOffset(self.pushView.frame, 0, +ScreenSize.SCREEN_HEIGHT)
          self.blurView.alpha = 0
        })
      }, completion: { (finished) in
        self.dismissViewControllerAnimated(false, completion: { 
          NSNotificationCenter.defaultCenter().postNotificationName(KNOTIFICATION_WELCOME_DISMISS, object: nil)
        })
    })
  }
  
  @IBAction func linkButtonPressed(sender: UIButton) {
    guard let link =  pushInfo?.link, url = NSURL(string: link) where !link.isEmpty else {
      return
    }
    dismissViewControllerAnimated(false) { 
      let vc = WebViewVC()
      vc.url = link
      if let rootVC = UIApplication.sharedApplication().keyWindow?.rootViewController as? BaseNC {
        rootVC.pushViewController(vc, animated: true)
      } else {
        UIApplication.sharedApplication().openURL(url)
      }
    }
  }
  
  @IBAction func attendButtonPressed(sender: AnyObject) {
    if let actid = pushInfo?.actid {
      dismissViewControllerAnimated(false) {
        let storyboard = UIStoryboard(name:"Activity",bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier("AttendActivityVC") as! AttendActivityVC
        let max = self.pushInfo?.maxtake?.intValue ?? 0
        vc.actid = actid
        vc.startTime = self.pushInfo?.startdate ?? ""
        vc.endTime = self.pushInfo?.enddate ?? ""
        vc.maxMemberCount = Int(max)
        if let rootVC = UIApplication.sharedApplication().keyWindow?.rootViewController as? BaseNC {
          rootVC.pushViewController(vc, animated: true)
        }
      }
    }
  }
  
}
