//
//  RatingVC.swift
//  SVIP
//
//  Created by Qin Yejun on 6/22/16.
//  Copyright © 2016 zkjinshi. All rights reserved.
//

import UIKit
import Cosmos

class RatingVC: UIViewController {
  var order:PushOrderStatus!
  
  @IBOutlet weak var pushView: UIView!
  @IBOutlet weak var avatarImageView: UIImageView!
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var ServiceLabel: UILabel!
  @IBOutlet weak var ratingView: CosmosView!
  @IBOutlet weak var submitButton: UIButton!
  
  private var blurView: UIVisualEffectView!
  
  private var taskID = ""
  private var ratingValue = 0.0

  override func viewDidLoad() {
    super.viewDidLoad()
    
    let blur = UIBlurEffect(style: .Dark)
    blurView = UIVisualEffectView(effect: blur)
    blurView.frame = self.view.bounds
    blurView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
    blurView.translatesAutoresizingMaskIntoConstraints = true
    blurView.alpha = 0.8
    self.view.insertSubview(blurView, atIndex: 0)
    
    pushView.alpha = 0
    
    ratingView.didTouchCosmos = didTouchCosmos
    ratingView.didFinishTouchingCosmos = didFinishTouchingCosmos
    
    setupView()
  }

  override func viewDidAppear(animated: Bool) {
    animateView()
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
  
  @IBAction func dismissVC(sender: AnyObject) {
    dismiss()
  }
  
  func setupView() {
    nameLabel.text = order.waitername
    ServiceLabel.text = order.srvname
    avatarImageView.sd_setImageWithURL(
      NSURL(string: order.waiterimage.fullImageUrlWith(width: 120, height: 120, scale: false))
      , placeholderImage: UIImage(named: "logo_white"))
  }
  
  private func didTouchCosmos(rating: Double) {
    ratingValue = rating
  }
  
  private func didFinishTouchingCosmos(rating: Double) {
    ratingValue = rating
    submitButton.hidden = false
  }
  
  @IBAction func submitRating(sender: AnyObject) {
    showHudInView(view, hint: "")
    HttpService.sharedInstance.ratingService(order.taskid, ratingValue: ratingValue, operationseq: order.operationseq) {[weak self] (json, err) in
      guard let strongSelf = self else { return }
      strongSelf.hideHUD()
      //strongSelf.showHint("评价成功")
      strongSelf.dismiss()
    }
  }

}
