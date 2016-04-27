//
//  PayInfoVC.swift
//  SVIP
//
//  Created by AlexBang on 16/3/19.
//  Copyright © 2016年 zkjinshi. All rights reserved.
//

import UIKit

/* 当前支付弹窗消失是被调用的闭包
 * 参数: true: 订单被处理（确认/拒绝）， false: 订单未处理(直接关闭窗口)
 */
typealias PayInfoDismissClosure = (Bool) ->Void

let FACEPAY_RESULT_NOTIFICATION = "FACEPAY_RESULT_NOTIFICATION"

class PayInfoVC: UIViewController {

  @IBOutlet weak var ordernoLabel: UILabel!
  @IBOutlet weak var payamountLabel: UILabel!
  @IBOutlet weak var shopnameLabel: UILabel!
  @IBOutlet weak var constraintCenterY: NSLayoutConstraint!
  @IBOutlet weak var rootView: UIView!
  private var blurView: UIVisualEffectView!
  
  var payInfo = PaylistmModel()
  
  var payInfoDismissClosure: PayInfoDismissClosure?
    
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let blur = UIBlurEffect(style: .Dark)
    blurView = UIVisualEffectView(effect: blur)
    blurView.frame = self.view.bounds
    blurView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
    blurView.translatesAutoresizingMaskIntoConstraints = true
    blurView.alpha = 0.8
    self.view.insertSubview(blurView, atIndex: 0)
    
    //constraintCenterY.constant = SCREEN_HEIGHT
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }

  override func loadView() {
    NSBundle.mainBundle().loadNibNamed("PayInfoVC", owner:self, options:nil)
  }

  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(true)
    ordernoLabel.text = "支付单号:\( payInfo.paymentno)"
    payamountLabel.text = payInfo.displayAmount
    shopnameLabel.text = payInfo.shopname
    animateView()
  }
  
  private func animateView() {
    rootView.frame = CGRectOffset(rootView.frame, 0, -ScreenSize.SCREEN_HEIGHT)
    UIView.animateWithDuration(0.5,
                        delay: 0.0,
       usingSpringWithDamping: 0.6,
        initialSpringVelocity: 0.0,
                      options: .CurveEaseInOut,
                   animations: {
        self.rootView.frame = CGRectOffset(self.rootView.frame, 0, +ScreenSize.SCREEN_HEIGHT)
        self.rootView.alpha = 1
      },completion: nil)
  }
    
  @IBAction func dismiss(sender: AnyObject) {
    if let closure = self.payInfoDismissClosure {
      closure(false)
    }
    UIView.animateKeyframesWithDuration(0.8,
                                 delay: 0.0,
                               options: [.CalculationModeCubic],
                            animations: {
        UIView.addKeyframeWithRelativeStartTime(0.0, relativeDuration: 0.4, animations: {
          self.rootView.transform = CGAffineTransformMakeScale(0.5, 0.5)
          self.rootView.alpha = 0.5
          self.blurView.alpha = 0.5
        })
        
        UIView.addKeyframeWithRelativeStartTime(0.5, relativeDuration: 0.5, animations: {
          self.rootView.frame = CGRectOffset(self.rootView.frame, 0, +ScreenSize.SCREEN_HEIGHT)
          self.blurView.alpha = 0
        })
      }, completion: { (finished) in
        self.dismissViewControllerAnimated(false, completion: nil)
    })
  }
  
  @IBAction func rejectpay(sender: AnyObject) {
    self.showHUDInView(view, withLoading: "")
    HttpService.sharedInstance.userPay(payInfo.orderno,action:-1) { (succ,error) -> Void in
      self.hideHUD()
      if succ {
        self.showHint("已拒绝支付")
        AccountManager.sharedInstance().savePayCreatetime("0")
        if let closure = self.payInfoDismissClosure {
          closure(true)
        }
        self.dismissViewControllerAnimated(true, completion: nil)
        NSNotificationCenter.defaultCenter().postNotificationName(FACEPAY_RESULT_NOTIFICATION, object: nil)
      } else {
        self.showErrorHint(error)
      }
    }
  }

  @IBAction func ensurePay(sender: AnyObject) {
      self.showHUDInView(view, withLoading: "")
      HttpService.sharedInstance.userPay(payInfo.orderno,action:1) { (succ,error) -> Void in
        self.hideHUD()
        if let error = error {
          self.showErrorHint(error)
          self.dismissViewControllerAnimated(true, completion: nil)
        } else {
          if succ {
            self.showHint("支付成功")
            if let closure = self.payInfoDismissClosure {
              closure(true)
            }
          }
          self.dismissViewControllerAnimated(true, completion: nil)
          NSNotificationCenter.defaultCenter().postNotificationName(FACEPAY_RESULT_NOTIFICATION, object: nil)
        }
      }
    }
  }
 

