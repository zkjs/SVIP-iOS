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
  @IBOutlet weak var saleAvatarImageView: UIImageView!
  @IBOutlet weak var okButton: UIButton!
  
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

  }
  
  @IBAction func nextStep(sender: AnyObject) {
    if code.isEmpty == false {
      let phone = AccountManager.sharedInstance().phone
      
      showHUDInView(view, withLoading: "")
      
      ZKJSHTTPSessionManager.sharedInstance().pairInvitationCodeWith(code, salesID: salesid, phone: phone, salesName: sales_name, salesPhone: sales_phone, shopID: shopid, shopName: "", success: { (task: NSURLSessionDataTask!, responseObject: AnyObject!) -> Void in
        if let data = responseObject {
          if let set = data["set"] as? NSNumber {
            if set.boolValue == true {
              self.sendInvitationCodeNotification()
              if self.type == InvitationCodeVCType.first {
                self.dismissViewControllerAnimated(true, completion: nil)
              } else {
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
      self.dismissViewControllerAnimated(true, completion: nil)
    }
  }
  
  func sendInvitationCodeNotification() {
    // 发送环信透传消息
    let userID = AccountManager.sharedInstance().userID
    let userName = AccountManager.sharedInstance().userName
    let phone = AccountManager.sharedInstance().phone
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
    guard let code = codeTextField.text else { return }
    ZKJSHTTPSessionManager.sharedInstance().getSaleInfoWithCode(code, success: { (task: NSURLSessionDataTask!, responseObject: AnyObject!) -> Void in
      if let data = responseObject {
        if let set = data["set"] as? NSNumber {
          if set.boolValue {
            self.okButton.setTitle("确定", forState: .Normal)
            self.code = code
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
    textField.resignFirstResponder()
    return true
  }
  
}
