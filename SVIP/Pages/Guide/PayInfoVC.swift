//
//  PayInfoVC.swift
//  SVIP
//
//  Created by AlexBang on 16/3/19.
//  Copyright © 2016年 zkjinshi. All rights reserved.
//

import UIKit

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
    payamountLabel.text = String(payInfo.amount)
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
      }
    }
  }

  @IBAction func ensurePay(sender: AnyObject) {
      self.showHUDInView(view, withLoading: "")
      HttpService.sharedInstance.userPay(payInfo.orderno,action:1) { (json,error) -> Void in
        if let _ = error {
          self.hideHUD()
          self.showHint("支付失败")
        }
        self.hideHUD()
        if let Json = json where Json == "success"{
          self.showHint("支付成功")
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
