//
//  BalancePopoverVC.swift
//  SVIP
//
//  Created by Qin Yejun on 5/24/16.
//  Copyright © 2016 zkjinshi. All rights reserved.
//

import UIKit

class BalancePopoverVC: UIViewController {
  var balance:Double = 0
  @IBOutlet weak var balanceLabel: UILabel!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.balanceLabel.text = (balance / 100).formattedCash
    getBalance()
  }
  
  // 账户余额
  func getBalance() {
    HttpService.sharedInstance.getBalance { (balance, error) -> Void in
      if error == nil {
        self.balanceLabel.text = (balance / 100).formattedCash
      }
    }
  }
  
}