//
//  SalesPageVC.swift
//  SVIP
//
//  Created by AlexBang on 15/11/12.
//  Copyright © 2015年 zkjinshi. All rights reserved.
//

import UIKit

class SalesPageVC: XLSegmentedPagerTabStripViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
      setupSubViews()


        // Do any additional setup after loading the view.
    }
  func popTotopView(sender:UIBarButtonItem) {
    dismissViewControllerAnimated(true, completion: nil)
  }
  
  func search(sender:UIBarButtonItem) {
    
  }
  func add(sender:UIBarButtonItem) {
    
  }
  // MARK: - Private
  
  private func setupSubViews() {
    segmentedControl.sizeToFit()
    let item1 = UIBarButtonItem(image: UIImage(named: "ic_fanhui"), style: UIBarButtonItemStyle.Plain, target: self, action: "popTotopView:")
    self.navigationItem.leftBarButtonItem = item1
    
    let item2 = UIBarButtonItem(image: UIImage(named: "ic_sousuo"), style: UIBarButtonItemStyle.Plain, target: self, action: "search:")
    let item3 = UIBarButtonItem(image: UIImage(named: "ic_tianjia"), style: UIBarButtonItemStyle.Plain, target: self, action: "add:")
    navigationItem.setRightBarButtonItems([item3,item2], animated: true)
    navigationController?.navigationBar.translucent = false
    navigationController?.navigationBar.barStyle = UIBarStyle.Black
    navigationController?.navigationBar.tintColor = UIColor.whiteColor()

  }
  func cancle(sender:UIBarButtonItem) {
    self.dismissViewControllerAnimated(true, completion: nil)
  }
  
  // MARK: - XLPagerTabStripViewControllerDataSource
  
  override func childViewControllersForPagerTabStripViewController(pagerTabStripViewController: XLPagerTabStripViewController!) -> [AnyObject]! {
    let child1 = ChatTVC()
    let child2 = MailListTVC()
    let child3 = FindListTVC()
    return [child1, child2,child3]
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
