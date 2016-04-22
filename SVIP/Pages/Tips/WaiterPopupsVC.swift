//
//  WaiterPopupsVC.swift
//  SVIP
//
//  Created by Qin Yejun on 4/22/16.
//  Copyright © 2016 zkjinshi. All rights reserved.
//

import UIKit

class WaiterPopupsVC: UIViewController {
  @IBOutlet weak var containerView: UIView!
  @IBOutlet weak var avatarImageView: UIImageView!
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var tipsButtonLeft: UIButton!
  @IBOutlet weak var tipsButtonRight: UIButton!
  
  var waiterData = WaitersData()
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    let blur = UIBlurEffect(style: .Dark)
    let blurView = UIVisualEffectView(effect: blur)
    blurView.frame = self.view.bounds
    blurView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
    blurView.translatesAutoresizingMaskIntoConstraints = true
    blurView.alpha = 0.6
    self.view.insertSubview(blurView, atIndex: 0)
    
    containerView.alpha = 0
    
    addGuestures()
    
    if let waiter = waiterData.next() {
      updateViewWithWaiter(waiter)
    }
  }
  
  override func viewDidAppear(animated: Bool) {
    animateView()
  }
  
  private func animateView() {
    containerView.frame = CGRectOffset(containerView.frame, 0, ScreenSize.SCREEN_HEIGHT)
    UIView.animateWithDuration(0.5, delay: 0.0,
                               usingSpringWithDamping: 0.6,
                               initialSpringVelocity: 0.0,
                               options: .CurveEaseInOut,
                               animations: {
                                self.containerView.frame = CGRectOffset(self.containerView.frame, 0, -ScreenSize.SCREEN_HEIGHT)
                                self.containerView.alpha = 1
      },completion: { (finished) in
        
    })
  }
  
  func addGuestures() {
    let tap = UITapGestureRecognizer(target: self, action: "dismiss")
    tap.numberOfTapsRequired = 1
    self.view.addGestureRecognizer(tap)
    
    let swipeGesture = UISwipeGestureRecognizer(target: self, action: "pickNextWaiter:")
    swipeGesture.direction = .Up
    self.view.addGestureRecognizer(swipeGesture)
    
  }
  
  func dismiss() {
    UIView.animateWithDuration(0.5, delay: 0.0,
                               usingSpringWithDamping: 0.6,
                               initialSpringVelocity: 0.0,
                               options: .CurveEaseInOut,
                               animations: {
        self.containerView.frame = CGRectOffset(self.containerView.frame, 0, -ScreenSize.SCREEN_HEIGHT)
        self.containerView.alpha = 0
      },completion: { (finished) in
        self.dismissViewControllerAnimated(false, completion: nil)
    })
    
  }
  
  func pickNextWaiter(gestureRecognizer:UISwipeGestureRecognizer) {
    if let waiter = waiterData.next() {
      let originFrame = self.containerView.frame

      UIView.animateWithDuration(0.5, delay: 0.0,
                                 usingSpringWithDamping: 0.6,
                                 initialSpringVelocity: 0.0,
                                 options: .CurveEaseInOut,
                                 animations: {
                                  self.containerView.frame = CGRectOffset(originFrame, 0, -ScreenSize.SCREEN_HEIGHT)
        },completion: { (finished) in
      })
      
      updateViewWithWaiter(waiter)
    } else {
      dismiss()
    }
  }
  
  func updateViewWithWaiter(waiter:Waiter) {
    nameLabel.text = waiter.name
    avatarImageView.sd_setImageWithURL(NSURL(string: waiter.avatar.fullImageUrl))
  }
  
  @IBAction func leftButtonPressed(sender: UIButton) {
    showSuccessWithAmount(10, waiter: waiterData.currentWaiter())
  }
  
  @IBAction func rightButtonPressed(sender: UIButton) {
    showSuccessWithAmount(20, waiter: waiterData.currentWaiter())
  }
  
  func showSuccessWithAmount(amount:Double, waiter:Waiter) {
    let presentingVC =  self.presentingViewController
    dismissViewControllerAnimated(false) {
      
      let storyBoard = UIStoryboard(name: "TipsSuccessVC", bundle: nil)
      let vc = storyBoard.instantiateViewControllerWithIdentifier("TipsSuccessVC") as! TipsSuccessVC
      vc.amount = amount
      vc.waiter = waiter
      vc.modalPresentationStyle = .Custom
      presentingVC?.presentViewController(vc, animated: false, completion: nil)
    }
    
  }
  
}
