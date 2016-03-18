//
//  BluetoothDescriptionVC.swift
//  SVIP
//
//  Created by AlexBang on 16/1/5.
//  Copyright © 2016年 zkjinshi. All rights reserved.
//

import UIKit

class BluetoothDescriptionVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
      title = "请打开您的蓝牙"
//      navigationController?.navigationBar.tintColor = UIColor.ZKJS_navTitleColor()
      let image = UIImage(named: "ic_fanhui_orange")
      let  item1 = UIBarButtonItem(image: image, style:.Done, target: self, action: "back")
      self.navigationItem.leftBarButtonItem = item1

    }
  
  override func loadView() {
    NSBundle.mainBundle().loadNibNamed("BluetoothDescriptionVC", owner:self, options:nil)
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    navigationController?.navigationBar.translucent = false
  }
  
  override func viewWillDisappear(animated: Bool) {
    super.viewWillDisappear(animated)
    navigationController?.navigationBar.translucent = true
    self.hidesBottomBarWhenPushed = false
  }
  
  func back() {
    navigationController?.popViewControllerAnimated(true)
  }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
