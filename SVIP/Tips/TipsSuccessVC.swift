//
//  TipsSuccessVC.swift
//  SVIP
//
//  Created by Qin Yejun on 4/22/16.
//  Copyright © 2016 zkjinshi. All rights reserved.
//

import UIKit

class TipsSuccessVC: UIViewController {
  var waiter:Waiter!
  var amount:Double = 0
  
  @IBOutlet weak var amountLabel: UILabel!
  @IBOutlet weak var avatarImageView: UIImageView!
  @IBOutlet weak var nameLabel: UILabel!
  

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
      avatarImageView.sd_setImageWithURL(NSURL(string:waiter.avatar.fullImageUrl))
      nameLabel.text = waiter.name
      amountLabel.text = "￥" + amount.format("0.0")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
  @IBAction func finishButtonPressed(sender: UIButton) {
    dismissViewControllerAnimated(true, completion: nil)
  }

}
