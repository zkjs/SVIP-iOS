//
//  PayInfoVC.swift
//  SVIP
//
//  Created by AlexBang on 16/3/19.
//  Copyright © 2016年 zkjinshi. All rights reserved.
//

import UIKit

typealias PayInfoDismissClosure = (Bool) ->Void
let FACEPAY_RESULT_NOTIFICATION = "FACEPAY_RESULT_NOTIFICATION"

class PayInfoVC: UIViewController {

  @IBOutlet weak var ordernoLabel: UILabel!
  @IBOutlet weak var payamountLabel: UILabel!
  @IBOutlet weak var shopnameLabel: UILabel!

  @IBOutlet weak var rootView: UIView!
  var payInfo = PaylistmModel()
  //
  var payInfoDismissClosure: PayInfoDismissClosure?
    
  override func viewDidLoad() {
    super.viewDidLoad()
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }

  override func loadView() {
    NSBundle.mainBundle().loadNibNamed("PayInfoVC", owner:self, options:nil)
  }

  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(true)
    ordernoLabel.text = "支付单号:\( payInfo.orderno)"
    payamountLabel.text = payInfo.displayAmount
    shopnameLabel.text = payInfo.shopname
  }
    
  @IBAction func dismiss(sender: AnyObject) {
    if let closure = self.payInfoDismissClosure {
      closure(false)
    }
    self.view.removeFromSuperview()
  }
  @IBAction func rejectpay(sender: AnyObject) {
    self.showHUDInView(view, withLoading: "")
    HttpService.sharedInstance.userPay(payInfo.orderno,action:2) { (json,error) -> Void in
            self.hideHUD()
      if let Json = json where Json == "success"{
        self.showHint("已拒绝支付")
        if let closure = self.payInfoDismissClosure {
          closure(true)
        }
        self.dismissViewControllerAnimated(true, completion: nil)
        self.view.removeFromSuperview()
        NSNotificationCenter.defaultCenter().postNotificationName(FACEPAY_RESULT_NOTIFICATION, object: nil)
      }
    }
  }

  @IBAction func ensurePay(sender: AnyObject) {
      self.showHUDInView(view, withLoading: "")
      HttpService.sharedInstance.userPay(payInfo.orderno,action:1) { (json,error) -> Void in
        self.hideHUD()
        if let _ = error {
          self.showHint("支付失败")
          self.view.removeFromSuperview()
        } else {
          if let Json = json where Json == "success"{
            self.showHint("支付成功")
            if let closure = self.payInfoDismissClosure {
              closure(true)
            }
            
          }
          self.dismissViewControllerAnimated(true, completion: nil)
          self.view.removeFromSuperview()
          NSNotificationCenter.defaultCenter().postNotificationName(FACEPAY_RESULT_NOTIFICATION, object: nil)
        }
        
      }
    }
  }
 

