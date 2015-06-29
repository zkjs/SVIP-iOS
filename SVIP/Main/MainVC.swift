//
//  MainVC.swift
//  SVIP
//
//  Created by Hanton on 6/27/15.
//  Copyright (c) 2015 zkjinshi. All rights reserved.
//

import UIKit

class MainVC: UIViewController {
  
  @IBOutlet weak var mainButton: UIButton!
  @IBOutlet weak var leftButton: UIButton!
  @IBOutlet weak var rightButton: UIButton!
  
  override func loadView() {
    NSBundle.mainBundle().loadNibNamed("MainVC", owner:self, options:nil)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let motionView = YXTMotionView(frame: self.view.bounds, image: UIImage(named: "星空中心"))
    motionView.motionEnabled = true
    motionView.scrollIndicatorEnabled = false
    motionView.zoomEnabled = false
    motionView.scrollDragEnabled = false
    motionView.scrollBounceEnabled = false
    self.view.addSubview(motionView)
    self.view.sendSubviewToBack(motionView)
  }
  
  @IBAction func didSelectMainButton(sender: AnyObject) {
    
  }
  
  @IBAction func didSelectLeftButton(sender: AnyObject) {
    let navController = UINavigationController(rootViewController: OrderListTVC())
    navController.navigationBar.tintColor = UIColor.blackColor()
    self.presentViewController(navController, animated: true, completion: nil)
  }
  
  @IBAction func didSelectRightButton(sender: AnyObject) {
    
  }
  
}
