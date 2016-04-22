//
//  AmountAndReasonVC.swift
//  SVIP
//
//  Created by AlexBang on 16/4/22.
//  Copyright © 2016年 zkjinshi. All rights reserved.
//

import UIKit

class AmountAndReasonVC: UIViewController {
  var reasonStr:String?
  var amountStr:String?
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
      
      }
    
    
  @IBAction func checkoutTip(sender: AnyObject) {
    print(reasonStr,amountStr)
    self.navigationController?.popViewControllerAnimated(true)
  }


    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
      if segue.identifier == "AmountSegue" {
        if let reasonVC = segue.destinationViewController as? AmountChooseVC {
          reasonVC.amountSelectedClourse = {(amount) -> Void in 
            self.amountStr = amount
          }
        }
      }
      if segue.identifier == "reasonSegue" {
        if let reasonVC = segue.destinationViewController as? ReasonCollectionVC {
          reasonVC.reasonSelectedClourse = {(reason) -> Void in 
            self.reasonStr = reason
          }
        }
      }
      

    }
}

