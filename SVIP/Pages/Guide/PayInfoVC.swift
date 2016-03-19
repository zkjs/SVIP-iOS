//
//  PayInfoVC.swift
//  SVIP
//
//  Created by AlexBang on 16/3/19.
//  Copyright © 2016年 zkjinshi. All rights reserved.
//

import UIKit

let FACEPAY_RESULT_NOTIFICATION = "FACEPAY_RESULT_NOTIFICATION"
class PayInfoVC: UIViewController {

  @IBOutlet weak var ordernoLabel: UILabel!
  @IBOutlet weak var payamountLabel: UILabel!
  @IBOutlet weak var shopnameLabel: UILabel!

  @IBOutlet weak var rootView: UIView!
  var payInfo = PaylistmModel()
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
    
  @IBAction func dismiss(sender: AnyObject) {
    self.view.removeFromSuperview()
  }
  @IBAction func rejectpay(sender: AnyObject) {
    self.showHUDInView(view, withLoading: "")
    HttpService.sharedInstance.userPay(payInfo.orderno,action:2) { (json,error) -> Void in
            self.hideHUD()
      if let Json = json where Json == "success"{
        self.showHint("已拒绝支付")
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
          self.view.removeFromSuperview()
          NSNotificationCenter.defaultCenter().postNotificationName(FACEPAY_RESULT_NOTIFICATION, object: nil)
        }
    }
  }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
