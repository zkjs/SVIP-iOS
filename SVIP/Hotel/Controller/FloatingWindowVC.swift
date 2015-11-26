//
//  FloatingWindowVC.swift
//  SVIP
//
//  Created by AlexBang on 15/11/12.
//  Copyright © 2015年 zkjinshi. All rights reserved.
//

import UIKit

class FloatingWindowVC: UIViewController, XLPagerTabStripViewControllerDelegate {
  
  @IBOutlet weak var determineButton: UIButton!
  @IBOutlet weak var chooseTheirOwnButton: UIButton!
  @IBOutlet weak var highPraiseRateLabel: UILabel!
  @IBOutlet weak var customerNameLabel: UILabel!
  @IBOutlet weak var customerImageView: UIImageView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    navigationController?.navigationBarHidden = true
    view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
  }
  
  override func loadView() {
    NSBundle.mainBundle().loadNibNamed("FloatingWindowVC", owner: self, options: nil)
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    
  }
  
  @IBAction func callCustomer(sender: AnyObject) {
    
  }
  
  @IBAction func senderMessage(sender: AnyObject) {
    
  }
  
  @IBAction func chooseTheirOwn(sender: AnyObject) {
    let vc = HotelPageVC()
    vc.moveToViewControllerAtIndex(0)
    navigationController?.pushViewController(vc, animated: true)
    view.removeFromSuperview()
  }
  
  @IBAction func DeterminetheCustomerService(sender: AnyObject) {
    self.view.removeFromSuperview()
  }
  
}
