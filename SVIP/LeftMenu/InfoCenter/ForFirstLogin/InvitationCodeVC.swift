//
//  InvitationCodeVC.swift
//  SVIP
//
//  Created by Hanton on 11/6/15.
//  Copyright © 2015 zkjinshi. All rights reserved.
//

import UIKit

@objc enum InvitationCodeVCType: Int {
  case first
  case second
}

class InvitationCodeVC: UIViewController {
  
  @IBOutlet weak var codeTextField: UITextField!
  @IBOutlet weak var saleNameTextField: UILabel!
  @IBOutlet weak var saleAvatarImageView: UIImageView! {
    didSet {
      let width = saleAvatarImageView.frame.width
      saleAvatarImageView.clipsToBounds = true
      saleAvatarImageView.layer.cornerRadius = width / 2.0
    }
  }
  
  lazy var type = InvitationCodeVCType.first
  lazy var code = ""
  lazy var salesid = ""
  lazy var shopid = ""
  lazy var sales_phone = ""
  lazy var sales_name = ""
  
  override func loadView() {
    NSBundle.mainBundle().loadNibNamed("InvitationCodeVC", owner:self, options:nil)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupUI()
  }

  override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
    view.endEditing(true)
  }
  
  func setupUI() {
    title = "邀请码"
    let right = UIBarButtonItem(image: UIImage(named: "ic_qianwang"), style: UIBarButtonItemStyle.Plain, target: self, action: "nextStep")
    navigationItem.rightBarButtonItem = right
    navigationItem.hidesBackButton = true
    
    let attString = NSAttributedString(string: "没有请为空",
      attributes: [NSFontAttributeName : UIFont.systemFontOfSize(14),
        NSForegroundColorAttributeName : UIColor.hx_colorWithHexString("8d8d8d")])
    codeTextField.attributedPlaceholder = attString
  }
  
  func nextStep() {
    if code.isEmpty == false {
      let shopName = StorageManager.sharedInstance().shopNameWithShopID(shopid) ?? ""
      let phone = JSHStorage.baseInfo().phone
      
      ZKJSHTTPSessionManager.sharedInstance().pairInvitationCodeWith(code, salesID: salesid, phone: phone,salesName: sales_name, salesPhone: sales_phone, shopID: shopid, shopName: shopName, success: { (task: NSURLSessionDataTask!, responseObject: AnyObject!) -> Void in
        if let data = responseObject {
          if let set = data["set"] as? NSNumber {
            if set.boolValue == true {
              self.sendInvitationCodeNotification()
              if self.type == InvitationCodeVCType.first {
               LoginManager.sharedInstance().afterAnimation()
              }else {
                self.navigationController?.popViewControllerAnimated(true)
              }
            } else {
              ZKJSTool.showMsg("您已经绑定过邀请码")
              self.navigationController?.popViewControllerAnimated(true)
            }
          }
        }
        }, failure: { (task: NSURLSessionDataTask!, error: NSError!) -> Void in
          
      })
    } else {
       LoginManager.sharedInstance().afterAnimation()
    }
  }
  
  func sendInvitationCodeNotification() {
    // 发送环信透传消息
    let userID = JSHStorage.baseInfo().userid
    let userName = JSHStorage.baseInfo().username
    let phone = JSHStorage.baseInfo().phone
    let timestamp = Int64(NSDate().timeIntervalSince1970 * 1000)
    let cmdChat = EMChatCommand()
    cmdChat.cmd = "inviteAdd"
    let body = EMCommandMessageBody(chatObject: cmdChat)
    let message = EMMessage(receiver: salesid, bodies: [body])
    message.ext = [
      "userId": userID,
      "userName": userName,
      "mobileNo": phone,
      "date": NSNumber(longLong: timestamp)]
    message.messageType = .eMessageTypeChat
    EaseMob.sharedInstance().chatManager.asyncSendMessage(message, progress: nil)
  }
  
}

extension InvitationCodeVC: UITextFieldDelegate {
  
  func textFieldDidEndEditing(textField: UITextField) {
    ZKJSHTTPSessionManager.sharedInstance().getSaleInfoWithCode(codeTextField.text, success: { (task: NSURLSessionDataTask!, responseObject: AnyObject!) -> Void in
      if let data = responseObject {
        if let set = data["set"] as? NSNumber {
          if set.boolValue {
            self.code = self.codeTextField.text!
            self.sales_name = data["sales_name"] as? String ?? ""
            self.saleNameTextField.text = self.sales_name
            if let avatar = data["sales_avatar"] as? String {
              var url = NSURL(string: kBaseURL)
              url = url?.URLByAppendingPathComponent(avatar)
              self.saleAvatarImageView.sd_setImageWithURL(url)
            }
            if let sales_phone = data["sales_phone"] as? NSNumber {
              self.sales_phone = sales_phone.stringValue
            }
            if let salesid = data["salesid"] as? String {
              self.salesid = salesid
            }
            if let shopid = data["shopid"] as? NSNumber {
              self.shopid = shopid.stringValue
            }
          } else {
            let alertView = UIAlertController(title: "邀请码不正确，请重新输入", message: "", preferredStyle: .Alert)
            alertView.addAction(UIAlertAction(title: "确定", style: .Cancel, handler: nil))
            self.presentViewController(alertView, animated: true, completion: nil)
          }
        }
      }
      }) { (task: NSURLSessionDataTask!, error: NSError!) -> Void in
        
    }
  }
  
  func textFieldShouldReturn(textField: UITextField) -> Bool {
    if textField == codeTextField {
      view.endEditing(true)
    }
    return true
  }
  
}
