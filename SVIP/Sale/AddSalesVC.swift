//
//  AddSalesVC.swift
//  SVIP
//
//  Created by AlexBang on 16/1/27.
//  Copyright © 2016年 zkjinshi. All rights reserved.
//

import UIKit

class AddSalesVC: UIViewController {
  
  @IBOutlet weak var lastLoginLabel: UILabel!
  @IBOutlet weak var shopnameLabel: UILabel!
  @IBOutlet weak var phonrLabel: UILabel!
  @IBOutlet weak var salesnameLabel: UILabel!
  @IBOutlet weak var imageView: UIImageView!
  
  var salesid = ""
  var sales: SalesModel? = nil
  var shopid = ""
    override func viewDidLoad() {
        super.viewDidLoad()
      title = "添加"
      let image = UIImage(named: "ic_fanhui_orange")
      let item1 = UIBarButtonItem(image: image, style:.Done, target: self, action: "pop:")
      self.navigationItem.leftBarButtonItem = item1
      
      salesnameLabel.text = ""
      shopnameLabel.text = ""
      phonrLabel.text = ""
      lastLoginLabel.text = ""
        // Do any additional setup after loading the view.
    }
  
  override func loadView() {
    NSBundle.mainBundle().loadNibNamed("AddSalesVC", owner:self, options:nil)
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    loadData()
    
  }
  
  func pop(sender:UIBarButtonItem) {
    self.navigationController?.popViewControllerAnimated(true)
  }
  
  func setupUI() {
    if let sales = self.sales {
      let url = NSURL(string: kImageURL)?.URLByAppendingPathComponent("/uploads/users/\(sales.userid).jpg")
      imageView.sd_setImageWithURL(url)
      salesnameLabel.text = sales.username
      salesnameLabel.sizeToFit()
      shopnameLabel.text = sales.shop_name
      shopnameLabel.sizeToFit()
      phonrLabel.text = String(sales.phone)
      let dateFormatter = NSDateFormatter()
      dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
      if let date = dateFormatter.dateFromString(sales.lasttime) {
        dateFormatter.dateFormat = "M月d日 hh:mm"
        let lastLogin = dateFormatter.stringFromDate(date)
        lastLoginLabel.text = "最近 \(lastLogin) 在线"
        lastLoginLabel.sizeToFit()
      }
    }

  }
  
  func loadData() {
    ZKJSHTTPSessionManager.sharedInstance().getSalesWithID(salesid, success: { (task: NSURLSessionDataTask!, responseObject: AnyObject!) -> Void in
      print(responseObject)
      if let data = responseObject as? [String: AnyObject] {
        if let set = data["set"] as? NSNumber {
          if set.boolValue == false {
            if let err = data["err"] as? NSNumber {
              if err.integerValue == 404 {
                self.showHint("此销售不存在")
              }
            }
          } else {
            self.sales = SalesModel(dictionary: data)
            self.setupUI()
          }
        }
      }
      }) { (task: NSURLSessionDataTask!, error: NSError!) -> Void in
        
    }
  }

  @IBAction func addWaiter(sender: AnyObject) {
    showHUDInView(view, withLoading: "")
    if let shopid = self.sales?.shopid
    {
      self.shopid = String(shopid)
    }
    
    ZKJSHTTPSessionManager.sharedInstance().userAddwaiterWithSalesID(salesid, shopID: shopid, success: { (task: NSURLSessionDataTask!, responseObject: AnyObject!) -> Void in
      print(responseObject)
      if let data = responseObject as? [String: AnyObject] {
        if let set = data["set"] as? Bool {
          if set == true {
            NSNotificationCenter.defaultCenter().postNotificationName("addWaiterSuccess", object: self)
            self.showHint("添加成功")
            self.sendInvitationCodeNotification()
            self.navigationController?.popViewControllerAnimated(true)
            self.hideHUD()
          }
          else {
            self.showHint("您已经添加过商家的服务员")
            self.navigationController?.popViewControllerAnimated(true)
            self.hideHUD()
          }
        }
      }
      }) { (task: NSURLSessionDataTask!, error: NSError!) -> Void in
        self.showHint("您已经添加过该服务员")
        self.navigationController?.popViewControllerAnimated(true)
        self.hideHUD()
    }
  }
  
  func sendInvitationCodeNotification() {
    // 发送环信透传消息
    let userID = AccountManager.sharedInstance().userID
    let userName = AccountManager.sharedInstance().userName
    let cmdChat = EMChatCommand()
    cmdChat.cmd = "addSales"
    let body = EMCommandMessageBody(chatObject: cmdChat)
    let message = EMMessage(receiver: salesid, bodies: [body])
    message.ext = [
      "userId": userID,
      "userName": userName]
    message.messageType = .eMessageTypeChat
    EaseMob.sharedInstance().chatManager.asyncSendMessage(message, progress: nil)
  }

}
