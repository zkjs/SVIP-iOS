//
//  PayInfoVC.swift
//  SVIP
//
//  Created by AlexBang on 16/3/19.
//  Copyright © 2016年 zkjinshi. All rights reserved.
//

import UIKit
typealias Closure = (Bool) ->Void
let FACEPAY_RESULT_NOTIFICATION = "FACEPAY_RESULT_NOTIFICATION"
class PayInfoVC: UIViewController {

  @IBOutlet weak var ordernoLabel: UILabel!
  @IBOutlet weak var payamountLabel: UILabel!
  @IBOutlet weak var shopnameLabel: UILabel!

  @IBOutlet weak var rootView: UIView!
  var payInfo = PaylistmModel()
  var closure: Closure!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
  
  func callBack(closure: Closure!) {
    self.closure = closure
  }
    
  @IBAction func dismiss(sender: AnyObject) {
    if let closure = self.closure {
      closure(true)
    }
    self.view.removeFromSuperview()
  }
  @IBAction func rejectpay(sender: AnyObject) {
    self.showHUDInView(view, withLoading: "")
    HttpService.sharedInstance.userPay(payInfo.orderno,action:2) { (json,error) -> Void in
            self.hideHUD()
      if let Json = json where Json == "success"{
        self.showHint("已拒绝支付")
        if let closure = self.closure {
          closure(true)
        }
        self.view.removeFromSuperview()
        NSNotificationCenter.defaultCenter().postNotificationName(FACEPAY_RESULT_NOTIFICATION, object: nil)
      }
    }
  }

  @IBAction func ensurePay(sender: AnyObject) {
      self.showHUDInView(view, withLoading: "")
      HttpService.sharedInstance.userPay(payInfo.orderno,action:1) { (json,error) -> Void in
        if let _ = error {
          self.hideHUD()
          self.showHint("支付失败")
          self.view.removeFromSuperview()
        }
        self.hideHUD()
        if let Json = json where Json == "success"{
          self.showHint("支付成功")
          if let closure = self.closure {
            closure(true)
          }
          
        }
          self.dismissViewControllerAnimated(true, completion: nil)
          self.view.removeFromSuperview()
          NSNotificationCenter.defaultCenter().postNotificationName(FACEPAY_RESULT_NOTIFICATION, object: nil)
          
        }
    }
  }
 

