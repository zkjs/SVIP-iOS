//
//  InvitationCodeVC.swift
//  SVIP
//
//  Created by Hanton on 11/6/15.
//  Copyright © 2015 zkjinshi. All rights reserved.
//

import UIKit

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
  
  lazy var code = ""
  lazy var salesid = ""
  lazy var shopid = ""
  
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
        NSForegroundColorAttributeName : UIColor(hexString: "8d8d8d")])
    codeTextField.attributedPlaceholder = attString
  }
  
  func nextStep() {
    if code.isEmpty == false {
      ZKJSHTTPSessionManager.sharedInstance().pairInvitationCodeWith(code, salesID:salesid, shopID:shopid, success: { (task: NSURLSessionDataTask!, responseObject: AnyObject!) -> Void in
        if let data = responseObject {
          if let set = data["set"] as? NSNumber {
            if set.boolValue {
              self.sendInvitationCodeNotification()
              LoginManager.sharedInstance().afterAnimation()
            }
          }
        }
        
        }) { (task: NSURLSessionDataTask!, error: NSError!) -> Void in
          
      }
    } else {
      LoginManager.sharedInstance().afterAnimation()
    }
  }
  
  func sendInvitationCodeNotification() {
    let timestamp = Int64(NSDate().timeIntervalSince1970)
    let userID = JSHAccountManager.sharedJSHAccountManager().userid
    let userName = JSHAccountManager.sharedJSHAccountManager().username
    let dictionary = [
      "userid": userID,
      "username": userName,
      "date": NSNumber(longLong: timestamp),
    ]
    do {
      let jsonData = try NSJSONSerialization.dataWithJSONObject(
        dictionary,
        options: NSJSONWritingOptions(rawValue: 0))
      guard let jsonString = NSString(data: jsonData,
        encoding: NSASCIIStringEncoding) else { return }
      let dictionary: [String: AnyObject] = [
        "type": MessageIMType.UserDefine.rawValue,
        "fromid": userID,
        "toid": salesid,
        "pushalert": "\(userName)已使用邀请码\(code)",
        "childtype": MessageUserDefineType.InvitationCode.rawValue,
        "content": jsonString,
        "timestamp": NSNumber(longLong: timestamp)
      ]
      ZKJSTCPSessionManager.sharedInstance().sendPacketFromDictionary(dictionary)
    } catch let error as NSError {
      print(error)
    }
  }
}

extension InvitationCodeVC: UITextFieldDelegate {
  
  func textFieldDidEndEditing(textField: UITextField) {
    ZKJSHTTPSessionManager.sharedInstance().getSaleInfoWithCode(codeTextField.text, success: { (task: NSURLSessionDataTask!, responseObject: AnyObject!) -> Void in
      if let data = responseObject {
        if let set = data["set"] as? NSNumber {
          if set.boolValue {
            self.code = self.codeTextField.text!
            self.saleNameTextField.text = data["username"] as? String
            if let avatar = data["user_avatar"] as? String {
              var url = NSURL(string: kBaseURL)
              url = url?.URLByAppendingPathComponent(avatar)
              self.saleAvatarImageView.sd_setImageWithURL(url)
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
