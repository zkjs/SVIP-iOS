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
  }

  @IBAction func confirmPayment(sender: UIButton) {
    print(amount)
    showHint("打赏成功")
    navigationController?.popToRootViewControllerAnimated(true)
  }
  
}

extension AmountAndReasonVC: AmountChooseDelegate {
  func didSelectAmount(amount: Double) {
    self.amount = amount
  }
}