//
//  FloatingWindowVC.swift
//  SVIP
//
//  Created by AlexBang on 15/11/12.
//  Copyright © 2015年 zkjinshi. All rights reserved.
//

import UIKit
protocol refreshHomeVCDelegate{
  func refreshHomeVC(set:Bool)
}
class FloatingWindowVC: UIViewController, XLPagerTabStripViewControllerDelegate {
  var delegate:refreshHomeVCDelegate?
  var dataArray = Array<[String: String]>()
  var privilege = PrivilegeModel()
  
  @IBOutlet weak var floatView: UIView!

  
  override func viewDidLoad() {
    super.viewDidLoad()
    navigationController?.navigationBarHidden = true
    view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    let myView = NSBundle.mainBundle().loadNibNamed("FloatHeaderView", owner: self, options: nil).first as! FloatHeaderView
    myView.frame.origin = CGPointMake((UIScreen.mainScreen().bounds.size.width-300)/2, 80)
    myView.nameLabel.text = privilege.privilegeName
    myView.detailLabel.text = " \(privilege.privilegeDesc)"
    self.view.addSubview(myView)
  }
 
  override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?){
    view.endEditing(true)
    super.touchesBegan(touches, withEvent: event)
    self.delegate?.refreshHomeVC(true)
    self.view.removeFromSuperview()
  }

  override func loadView() {
    NSBundle.mainBundle().loadNibNamed("FloatingWindowVC", owner: self, options: nil)
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
   }
}
