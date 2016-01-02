//
//  BusinessDetailVC.swift
//  SVIP
//
//  Created by AlexBang on 15/12/31.
//  Copyright © 2015年 zkjinshi. All rights reserved.
//

import UIKit

class BusinessDetailVC: UIViewController {

  var shopid: NSNumber!
  var shopName: String!
  var saleid: String!
  var shopDetail = DetailModel()
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
//      self.navigationController!.navigationBar.translucent = true
      self.navigationController!.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
      self.navigationController!.navigationBar.shadowImage = UIImage()
      let image = UIImage(named: "ic_fanhui_orange")
      let item1 = UIBarButtonItem(image: image, style:.Done, target: self, action: "pop:")
      navigationController?.navigationBar.translucent = true
      self.navigationItem.leftBarButtonItem = item1
      loadData()
      
      if let nc = childViewControllers[0] as? UINavigationController {
        if let vc = nc.topViewController as? BusinessDetailTVC {
          vc.shopid = shopid
          vc.shopName = shopName
          vc.saleid = self.saleid
        }
      }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
  
  func loadData() {
    ZKJSJavaHTTPSessionManager.sharedInstance().getOrderDetailWithShopID(String(shopid), success: { (task:NSURLSessionDataTask!, responsObject:AnyObject!) -> Void in
      if let dict = responsObject as? NSDictionary {
        self.shopDetail = DetailModel(dic: dict)
      }
      }) { (task:NSURLSessionDataTask!, error: NSError!) -> Void in
        
    }
  }
  
  override func viewWillDisappear(animated: Bool) {
    super.viewWillDisappear(animated)
    navigationController?.navigationBar.translucent = false
  }
  
  func pop(sender:UIBarButtonItem) {
    self.navigationController?.popViewControllerAnimated(true)
  }
    
  @IBAction func advanceOrder(sender: AnyObject) {
    if self.shopDetail.category == "酒店行业" {
      let storyboard = UIStoryboard(name: "HotelOrderTVC", bundle: nil)
      let vc = storyboard.instantiateViewControllerWithIdentifier("HotelOrderTVC") as! HotelOrderTVC
      vc.shopName = self.shopDetail.shopName
      vc.shopid = shopid
      vc.saleid = self.saleid
      navigationController?.pushViewController(vc, animated: true)
    }
    if self.shopDetail.category == "餐饮行业" {
      let storyboard = UIStoryboard(name: "LeisureTVC", bundle: nil)
      let vc = storyboard.instantiateViewControllerWithIdentifier("LeisureTVC") as! LeisureTVC
      navigationController?.pushViewController(vc, animated: true)
    }
    if self.shopDetail.category == "KTV" {
      let storyboard = UIStoryboard(name: "KTVTableView", bundle: nil)
      let vc = storyboard.instantiateViewControllerWithIdentifier("KTVTableView") as! KTVTableView
      navigationController?.pushViewController(vc, animated: true)
    }
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