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

  @IBOutlet weak var rootView: UIView!
  var payInfo = PaylistmModel()
  
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
    HttpService.sharedInstance.userPay(payInfo.orderno,action:2) { (succ,error) -> Void in
      self.hideHUD()
      if succ {
        self.showHint("已拒绝支付")
        AccountManager.sharedInstance().savePayCreatetime("0")
        if let closure = self.payInfoDismissClosure {
          closure(true)
        }
        self.dismissViewControllerAnimated(true, completion: nil)
        self.view.removeFromSuperview()
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
          self.view.removeFromSuperview()
        } else {
          if succ {
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
 

