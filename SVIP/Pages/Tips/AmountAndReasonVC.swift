//
//  AmountAndReasonVC.swift
//  SVIP
//
//  Created by AlexBang on 16/4/22.
//  Copyright © 2016年 zkjinshi. All rights reserved.
//

import UIKit

class AmountAndReasonVC: UIViewController {
  var amount = 0.0
  var reason = ""
  

  override func viewDidLoad() {
    super.viewDidLoad()

    // Do any additional setup after loading the view.
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  

  // MARK: - Navigation

  // In a storyboard-based application, you will often want to do a little preparation before navigation
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "AmountSegue" {
      let vc = segue.destinationViewController as! AmountChooseVC
      vc.delegate = self
    }
    
    if segue.identifier == "reasonSegue" {
      let vc = segue.destinationViewController as! ReasonCollectionVC
      vc.Delegate = self
    }
  }

  @IBAction func confirmPayment(sender: UIButton) {
    if amount == 0.0 {
      showHint("未选择打赏金额")
      return
    }
    var cash = StorageManager.sharedInstance().curentCash()
    if cash < amount {
      showHint("余额不足")
      return
    } else {
      cash -= amount
      StorageManager.sharedInstance().saveCash(cash)
      NSNotificationCenter.defaultCenter().postNotificationName(KNOTIFICATION_BALANCECHANGE, object: nil)
      showHint("打赏成功")
    }
    navigationController?.popViewControllerAnimated(true)
  }
  
}

extension AmountAndReasonVC: AmountChooseDelegate {
  func didSelectAmount(amount: Double) {
    self.amount = amount
  }
}

extension AmountAndReasonVC: ReasonChooseDelegate {
  func didSelectReason(reason: String) {
    self.reason = reason
  }
}