//
//  HotelPageVC.swift
//  SVIP
//
//  Created by AlexBang on 15/11/10.
//  Copyright © 2015年 zkjinshi. All rights reserved.
//

import UIKit

class HotelPageVC: XLSegmentedPagerTabStripViewController {
  override func viewDidLoad() {
     super.viewDidLoad()
    let item1 = UIBarButtonItem(image: UIImage(named: "ic_fanhui"), style: UIBarButtonItemStyle.Plain, target: self, action: "popTotopView:")
    self.navigationItem.leftBarButtonItem = item1
    
    let item2 = UIBarButtonItem(image: UIImage(named: "ic_sousuo"), style: UIBarButtonItemStyle.Plain, target: self, action: "search:")
    navigationItem.rightBarButtonItem = item2
    navigationController?.navigationBar.translucent = false
    navigationController?.navigationBar.barStyle = UIBarStyle.Black
    navigationController?.navigationBar.tintColor = UIColor.whiteColor()

    setupSubViews()
  }
  
  func popTotopView(sender:UIBarButtonItem) {
    dismissViewControllerAnimated(true, completion: nil)
  }
  
  func search(sender:UIBarButtonItem) {
    let vc = SearchTVC()
    navigationController?.pushViewController(vc, animated: true)
  }
  // MARK: - Private
  
  private func setupSubViews() {
    segmentedControl.sizeToFit()
  }
  func cancle(sender:UIBarButtonItem) {
    self.dismissViewControllerAnimated(true, completion: nil)
  }
  
  // MARK: - XLPagerTabStripViewControllerDataSource
  
  override func childViewControllersForPagerTabStripViewController(pagerTabStripViewController: XLPagerTabStripViewController!) -> [AnyObject]! {
    let child1 = HotelTVC()
    let child2 = RestaurantTVC()
    let child3 = LeisureTVC()
    return [child1, child2,child3]
  }


}
