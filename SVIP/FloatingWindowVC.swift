//
//  FloatingWindowVC.swift
//  SVIP
//
//  Created by AlexBang on 15/11/12.
//  Copyright © 2015年 zkjinshi. All rights reserved.
//

import UIKit

class FloatingWindowVC: UIViewController,XLPagerTabStripViewControllerDelegate {

  @IBOutlet weak var determineButton: UIButton!
  @IBOutlet weak var chooseTheirOwnButton: UIButton!
//    {
//    didSet {
//      chooseTheirOwnButton.addTarget(self, action: "chooseTheirOwn", forControlEvents: UIControlEvents.TouchUpInside)
//    }
//  }

 
  @IBAction func callCustomer(sender: AnyObject) {
  }
  @IBAction func senderMessage(sender: AnyObject) {
  }
  @IBOutlet weak var highPraiseRateLabel: UILabel!
  @IBOutlet weak var customerNameLabel: UILabel!
  @IBOutlet weak var customerImageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
      
      navigationController?.navigationBarHidden = true
      self.view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)

        // Do any additional setup after loading the view.
    
    }
  override func loadView() {
    NSBundle.mainBundle().loadNibNamed("FloatingWindowVC", owner: self, options: nil)
  }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
      
    }
  
  
  @IBAction func chooseTheirOwn(sender: AnyObject) {
    let vc = HotelPageVC()
    vc.moveToViewControllerAtIndex(0)
    let nav = UINavigationController(rootViewController: vc)
    navigationController?.presentViewController(nav, animated: true,completion:nil)
    self.view.removeFromSuperview()
  }
  
 
  @IBAction func DeterminetheCustomerService(sender: AnyObject) {
    
    self.view.removeFromSuperview()
  }
  
  

}
