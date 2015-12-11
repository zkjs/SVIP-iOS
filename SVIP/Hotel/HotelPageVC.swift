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
    let rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "ic_sousuo"), style: UIBarButtonItemStyle.Plain, target: self, action: "search:")
    navigationItem.rightBarButtonItem = rightBarButtonItem
    navigationController?.navigationBar.translucent = false
    navigationController?.navigationBar.barStyle = UIBarStyle.Black
    navigationController?.navigationBar.tintColor = UIColor.whiteColor()
    
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
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(true)
    navigationController?.navigationBarHidden = false
  }
  
  private func showLogin() {
    let vc = LoginVC()
    navigationController?.presentViewController(vc, animated: true, completion: nil)
  }


}

// MARK: - HTTPSessionManagerDelegate

extension HotelPageVC: HTTPSessionManagerDelegate {
  
  func didReceiveInvalidToken() {
    showLogin()
    ZKJSTool.showMsg("账号在别处登录，请重新重录")
  }
  
}
