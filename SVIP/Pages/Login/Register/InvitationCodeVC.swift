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
  
  @IBOutlet weak var customLabel: UILabel!
  @IBOutlet weak var animationView: UIView!
  @IBOutlet weak var codeTextField: UITextField!
  @IBOutlet weak var saleNameTextField: UILabel!
  @IBOutlet weak var saleAvatarImageView: UIImageView!{
    didSet {
      saleAvatarImageView.layer.masksToBounds = true
      saleAvatarImageView.layer.cornerRadius = saleAvatarImageView.frame.width / 2.0
    }
  }
  @IBOutlet weak var okButton: UIButton!
  @IBOutlet weak var animationViewHeight: NSLayoutConstraint!
  @IBOutlet weak var avatarImageHeight: NSLayoutConstraint!
  
  lazy var type = InvitationCodeVCType.first
  lazy var code = ""
  lazy var salesid = ""
  lazy var shopid = ""
  lazy var shopname = ""
  lazy var sales_phone = ""
  lazy var sales_name = ""
  
  override func loadView() {
    NSBundle.mainBundle().loadNibNamed("InvitationCodeVC", owner:self, options:nil)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    customLabel.text = ""
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    
    navigationController?.navigationBarHidden = true
    setupUI()
  }
  
  override func viewWillDisappear(animated: Bool) {
    super.viewWillDisappear(animated)
    
    navigationController?.navigationBarHidden = false
  }

  override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
    view.endEditing(true)
  }
  
  func setupUI() {
    let codeIV = UIImageView(image: UIImage(named: "ic_duanxin"))
    codeIV.frame = CGRectMake(0.0, 0.0, codeIV.frame.size.width + 10.0, codeIV.frame.size.height)
    codeIV.contentMode = .Center
    codeTextField.leftViewMode = .Always
    codeTextField.leftView = codeIV
    animationViewHeight.constant = 0
    avatarImageHeight.constant = 0
  }
  
  @IBAction func nextStep(sender: AnyObject) {
     if codeTextField.text!.isEmpty == false {
      showHUDInView(view, withLoading: "")
      HttpService.sharedInstance.codeActive(code, completionHandler: { (json, error) -> Void in
        if let _ = error {
          self.showHint("激活失败，请检查邀请码是否正确")
        } else {
          if let json = json {
            if let res = json["res"].int {
              if res == 0 {
                self.hideHUD()
                AccountManager.sharedInstance().saveActivated("1")
                self.hideHUD()
                if self.type == InvitationCodeVCType.first {
                  HttpService.sharedInstance.getUserinfo{ (json, error) -> Void in
                    self.dismissViewControllerAnimated(true, completion: nil)
                  }
                } else {
                  self.navigationController?.popViewControllerAnimated(true)
                }
              } else {
                self.hideHUD()
                ZKJSTool.showMsg("该邀请码无效,请重试")
                self.navigationController?.popViewControllerAnimated(true)
              }
            }
          }
        }
      })
     
    }
    if codeTextField.text!.characters.count < 6 {//跳过
      showHUDInView(view, withLoading: "")
      HttpService.sharedInstance.getUserinfo{ (json, error) -> Void in
        self.hideHUD()
        self.dismissViewControllerAnimated(true, completion: nil)
      }
    }
  }
  
  
}

extension InvitationCodeVC: UITextFieldDelegate {
  
  func textFieldDidEndEditing(textField: UITextField) {
    textField.layer.borderWidth = 0
    guard let code = codeTextField.text else { return }
    if code.characters.count == 6 {
     HttpService.sharedInstance.querySalesFromCode(code, completionHandler: { (json, error) -> Void in
      if let _ = error {
        let alertView = UIAlertController(title: "邀请码不正确，请重新输入", message: "", preferredStyle: .Alert)
        alertView.addAction(UIAlertAction(title: "确定", style: .Cancel, handler: nil))
        self.presentViewController(alertView, animated: true, completion: nil)
      } else {
        if let json = json!["data"].dictionary {
          self.okButton.setTitle("确定", forState: .Normal)
          self.code = code
          if let salesname = json["username"]?.string {
            self.sales_name = salesname
          }
          self.saleNameTextField.text = "来自\(self.sales_name)的邀请码"
          self.customLabel.text = "点击确认激活特权，他将成为您的专属客服"
          if let salesid = json["userimage"]?.string {
            let placeImage = UIImage(named: "ic_zhijian")
            self.saleAvatarImageView.sd_setImageWithURL(NSURL(string: salesid.fullImageUrl), placeholderImage: placeImage)
          }
          
          if let sales_phone = json["phone"]?.number{
            self.sales_phone = sales_phone.stringValue
          }
          if let salesid = json["userid"]?.string {
            self.salesid = salesid
          }
          if let shopid = json["shopid"]?.number {
            self.shopid = shopid.stringValue
          }
          if let shopname = json["fullname"]?.string {
            self.shopname = shopname
          }
          self.avatarImageHeight.constant = 48
          self.animationViewHeight.constant = 74
          UIView.animateWithDuration(0.4, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
            self.view.layoutIfNeeded()
            }, completion: nil)
        }
      }
     })
    } else {
      okButton.setTitle("跳过", forState: .Normal)
      animationViewHeight.constant = 0
      avatarImageHeight.constant = 0
      customLabel.text = ""
      UIView.animateWithDuration(0.4, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
        self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
  }
  func textFieldDidBeginEditing(textField: UITextField) {
    textField.layer.borderWidth = 1
    textField.layer.borderColor = UIColor.ZKJS_mainColor().CGColor
  }
  
  func textFieldShouldReturn(textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    return true
  }
  
}
