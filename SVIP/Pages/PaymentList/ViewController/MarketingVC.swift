//
//  MarketingVC.swift
//  SVIP
//
//  Created by AlexBang on 16/4/19.
//  Copyright © 2016年 zkjinshi. All rights reserved.
//

import UIKit

class MarketingVC: UIViewController {

  @IBOutlet weak var marketTitleLabel: UILabel!
  @IBOutlet weak var marketImageView: UIImageView!
  @IBOutlet weak var marketContentLabel: UILabel!
  @IBOutlet weak var activateButtonConstraint: NSLayoutConstraint!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
  
    override func loadView() {
        NSBundle.mainBundle().loadNibNamed("MarketingVC", owner:self, options:nil)
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
