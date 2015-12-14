//
//  CustomServiceVC.swift
//  SVIP
//
//  Created by AlexBang on 15/12/11.
//  Copyright © 2015年 zkjinshi. All rights reserved.
//

import UIKit

class CustomServiceVC: UIViewController {

  @IBOutlet weak var coustomImage: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
      
      self.view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    self.navigationController?.navigationBarHidden = true
  }
  
  override func viewWillDisappear(animated: Bool) {
    super.viewWillDisappear(true)
    self.view.removeFromSuperview()
  }
  
  override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?){
    view.endEditing(true)
    super.touchesBegan(touches, withEvent: event)
    self.view.removeFromSuperview()
  }
    

  @IBAction func checkin(sender: AnyObject) {
   // registerNotification()
     let order = StorageManager.sharedInstance().lastOrder()
     let shopID = order?.shopid
    ZKJSHTTPSessionManager.sharedInstance().getMerchanCustomerServiceListWithShopID(shopID!.stringValue, success: { (task: NSURLSessionDataTask!, responseObject: AnyObject!) -> Void in
      self.chooseChatterWithData(responseObject)
      }) { (task: NSURLSessionDataTask!, error: NSError!) -> Void in
        
    }
    self.view.removeFromSuperview()

  }
  
  func chooseChatterWithData(data: AnyObject) {
    if let head = data["head"] as? [String: AnyObject] {
      if let set = head["set"] as? NSNumber {
        if set.boolValue {
          if let exclusive_salesid = head["exclusive_salesid"] as? String {
            if let data = data["data"] as? [[String: AnyObject]] {
              for sale in data {
                if let salesid = sale["salesid"] as? String {
                  if salesid == exclusive_salesid {
                    if let name = sale["name"] as? String {
                      self.createConversationWithSalesID(salesid, salesName: name)
                    }
                  }
                }
              }
            }
          } else if let data = data["data"] as? [[String: AnyObject]] where data.count > 0 {
            let randomIndex = Int(arc4random_uniform(UInt32(data.count)))
            let sale = data[randomIndex]
            if let salesid = sale["salesid"] as? String,
              let name = sale["name"] as? String {
                self.createConversationWithSalesID(salesid, salesName: name)
            }
          }
        }
      }
    }
  }
  
  func createConversationWithSalesID(salesID: String, salesName: String) {
    print(salesID,salesName)
    let vc = ChatViewController(conversationChatter: salesID, conversationType: .eConversationTypeChat)
    vc.chatter = salesName
    navigationController?.pushViewController(vc, animated: true)
  }
  
  @IBAction func callCustom(sender: AnyObject) {
    let order = StorageManager.sharedInstance().lastOrder()
    if let shopID = order?.shopid {
      if let shopPhone = StorageManager.sharedInstance().shopPhoneWithShopID(shopID.stringValue) {
        UIApplication.sharedApplication().openURL(NSURL(string: "tel://\(shopPhone)")!)
      }
    }
  }

}
