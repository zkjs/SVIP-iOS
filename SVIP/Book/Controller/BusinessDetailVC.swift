//
//  BusinessDetailVC.swift
//  SVIP
//
//  Created by AlexBang on 15/12/31.
//  Copyright © 2015年 zkjinshi. All rights reserved.
//

import UIKit

class BusinessDetailVC: UIViewController,PhotoViewerDelegate,CommentsViewerDelegate {

  var shopid: NSNumber!
  var shopName: String!
  var saleid: String!
  var shopDetail : ShopDetailModel!
  var childDetailTVC: BusinessDetailTVC?
  
  override func viewDidLoad() {
    super.viewDidLoad()
        
    self.navigationController!.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
    self.navigationController!.navigationBar.shadowImage = UIImage()
    
    let image = UIImage(named: "ic_fanhui_orange")
    let item1 = UIBarButtonItem(image: image, style:.Done, target: self, action: "pop:")
    self.navigationItem.leftBarButtonItem = item1
    if let nc = childViewControllers[0] as? UINavigationController {
      if let vc = nc.topViewController as? BusinessDetailTVC {
        vc.delegate = self
        vc.Delegate = self
        vc.shopid = shopid
        vc.shopName = shopName
        vc.saleid = self.saleid
        self.childDetailTVC = vc
      }
    }
    navigationController?.navigationBar.translucent = true
    loadData()
    
  }
  
  func loadData() {
    showHUDInView(view, withLoading: "")
    
    HttpService.sharedInstance.getShopDetail(String(shopid)) { (shop, error) -> Void in
      self.hideHUD()
      if let shop = shop {
        self.shopDetail = shop
        self.addNextStepButton()
        self.childDetailTVC?.shopDetail = shop
      }
    }
  }
  
  func addNextStepButton() {
    //暂时屏蔽预定功能 [commented at 2016-03-14]
    /*let frame = CGRectMake(0, view.bounds.size.height-48, view.bounds.size.width, 48)
    let button = UIButton(frame: frame)
    button.backgroundColor = UIColor.ZKJS_mainColor()
    if shopDetail.shopstatus == 0 {
      button.setTitle("即将入驻", forState: .Normal)
      button.backgroundColor = UIColor.lightGrayColor()
      button.enabled = false
    } else {
      button.setTitle("立即预订", forState: .Normal)
    }
    
    button.addTarget(self, action: "nextStep", forControlEvents: .TouchUpInside)
    view.addSubview(button)
    */
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    navigationController?.navigationBar.translucent = true
  }
  
  override func viewWillDisappear(animated: Bool) {
    super.viewWillDisappear(animated)
    navigationController?.navigationBar.translucent = false
  }
  
  func pop(sender:UIBarButtonItem) {
    self.navigationController?.popViewControllerAnimated(true)
  }
  
  func nextStep() {
    
    if AccountManager.sharedInstance().isLogin() == false {
      let nc = BaseNC(rootViewController: LoginVC())
      presentViewController(nc, animated: true, completion: nil)
      return
    }
    
    /*print(self.shopDetail.category)
    if self.shopDetail.category == "50" {
      let storyboard = UIStoryboard(name: "HotelOrderTVC", bundle: nil)
      let vc = storyboard.instantiateViewControllerWithIdentifier("HotelOrderTVC") as! HotelOrderTVC
      vc.shopName = self.shopDetail.shopName
      vc.shopid = shopid
      vc.saleid = self.saleid
      navigationController?.pushViewController(vc, animated: true)
    }
    if self.shopDetail.category == "70" {
      let storyboard = UIStoryboard(name: "LeisureTVC", bundle: nil)
      let vc = storyboard.instantiateViewControllerWithIdentifier("LeisureTVC") as! LeisureTVC
	  vc.shopName = self.shopDetail.shopName
      vc.shopid = shopid
      vc.saleid = self.saleid
      navigationController?.pushViewController(vc, animated: true)
    }
    if self.shopDetail.category == "60" {
      let storyboard = UIStoryboard(name: "KTVTableView", bundle: nil)
      let vc = storyboard.instantiateViewControllerWithIdentifier("KTVTableView") as! KTVTableView
      vc.shopName = self.shopDetail.shopName
      vc.shopid = shopid
      vc.saleid = self.saleid
      navigationController?.pushViewController(vc, animated: true)
    }*/
  }
  
 
  
  func gotoPhotoViewerDelegate(Brower:AnyObject) {
    self.navigationController?.pushViewController(Brower  as! UIViewController , animated: true)
  }
  
  func gotoCommentsViewerDelegate(Brower:AnyObject) {
    let vc = CommentsTVC()
    vc.shopid = self.shopid
    self.navigationController?.pushViewController(vc , animated: true)
  }

}
