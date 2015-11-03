//
//  InfoEditViewController.swift
//  SVIP
//
//  Created by dai.fengyi on 15/8/18.
//  Copyright (c) 2015年 zkjinshi. All rights reserved.
//

import UIKit

class InfoEditViewController: UIViewController, UIActionSheetDelegate,UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextFieldDelegate {
  @IBOutlet weak var bgImgeView: UIImageView!
  @IBOutlet weak var avatarButton: UIButton!
  @IBOutlet weak var username: UITextField!
//  @IBOutlet var sexButtons: [UIButton]!
  @IBOutlet weak var maleButton: UIButton!
  @IBOutlet weak var femaleButton: UIButton!
  var avatarData: NSData! = nil
  var sexstr = NSLocalizedString("MAN", comment: "")
  
  required override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
    super.init(nibName: "InfoEditViewController", bundle: nil)
  }

  required init?(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
  }
  override func viewDidLoad() {
    super.viewDidLoad()
    setUI()
  }

  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
  }
  /*
  NSAttributedString *attString1 = [[NSAttributedString alloc] initWithString:@"130-0000-0000" attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:14] , NSForegroundColorAttributeName : [UIColor colorFromHexString:@"0x8d8d8d"]}];
  _phoneField.attributedPlaceholder = attString1;
  NSAttributedString *attString2 = [[NSAttributedString alloc] initWithString:@"验证码" attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:14] , NSForegroundColorAttributeName : [UIColor colorFromHexString:@"0x8d8d8d"]}];
  _codeField.attributedPlaceholder = attString2;
  */
  func setUI() {
    self.title = NSLocalizedString("MY_PROFILE", comment: "")
    self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.whiteColor()]
    self.navigationItem.rightBarButtonItem?.tintColor = UIColor.whiteColor()
    self.navigationController?.navigationBar .setBackgroundImage(UIImage(named: "ic_qianwang"), forBarMetrics: UIBarMetrics.Compact)
    
    let tap = UITapGestureRecognizer(target: self, action: "touchBlank")
    bgImgeView.addGestureRecognizer(tap)
    
    let attString1 = NSAttributedString(string: NSLocalizedString("PROFILE_NICKNAME", comment: ""),
                                        attributes: [NSFontAttributeName : UIFont.systemFontOfSize(14),
                                        NSForegroundColorAttributeName : UIColor(hexString: "8d8d8d")])
    username.attributedPlaceholder = attString1
    
    if let baseInfo = JSHStorage.baseInfo() {
      avatarButton.setImage(baseInfo.avatarImage, forState: UIControlState.Normal)
      username.text = baseInfo.username
      sexstr = baseInfo.sex
      if sexstr == NSLocalizedString("MAN", comment: "") {
        selectSex(maleButton)
      }
      
    }
  }
  
  
  //MARK:- Button Action
  
  @IBAction func nextStep(sender: AnyObject) {
    if username.text!.isEmpty {
      ZKJSTool.showMsg(NSLocalizedString("PROFILE_FILL_ALL", comment: ""))
      return
    }
    ZKJSTool.showLoading()
    ZKJSHTTPSessionManager.sharedInstance().updateUserInfoWithUserID(JSHAccountManager.sharedJSHAccountManager().userid, token: JSHAccountManager.sharedJSHAccountManager().token, username: username.text, realname: "", imageData: avatarData, imageName: " ", sex: sexstr, company: "", occupation: nil, email: nil, tagopen: nil,success: { (task: NSURLSessionDataTask!, responseObject: AnyObject!) -> Void in
      let dic = responseObject as! NSDictionary
      if dic["set"]!.boolValue! {
        LoginManager.sharedInstance().afterAnimation()
      }
      }) { (task: NSURLSessionDataTask!, error: NSError!) -> Void in
        
    }
  }
  
  @IBAction func selectAvatar(sender: AnyObject) {
    UIActionSheet(title:NSLocalizedString("CHOOSE_PHOTO", comment: ""),
                  delegate:self,
                  cancelButtonTitle:NSLocalizedString("CANCEL", comment: ""),
                  destructiveButtonTitle:NSLocalizedString("TAKE_PHOTO", comment: ""),
                  otherButtonTitles:NSLocalizedString("PHOTO_LIBRARY", comment: "")).showInView(self.view)
  }
  
  @IBAction func selectSex(sender: UIButton) {
    if sender == maleButton {
      femaleButton.selected = false
      sexstr = NSLocalizedString("MAN", comment: "")
    }else {
      maleButton.selected = false
      sexstr = NSLocalizedString("WOMAN", comment: "")
    }
    sender.selected = true
  }

  func touchBlank() {
    self.view.endEditing(true)
  }
  
  //MARK:- ACTIONSHEET
  
  func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
    switch buttonIndex {//莫名其妙的buttonIndex：照相0，取消1，照片库2
    case 0:
      let picker = UIImagePickerController()
      picker.sourceType = UIImagePickerControllerSourceType.Camera
      picker.delegate = self
      picker.allowsEditing = true
      self.presentViewController(picker, animated: true, completion: { () -> Void in
        
      })
    case 2:
      let picker = UIImagePickerController()
      picker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
      picker.delegate = self
      picker.allowsEditing = true
      self.presentViewController(picker, animated: true, completion: { () -> Void in
        
      })
    default:
      break
    }
  }
  
  //MARK:- UIImagePickerControllerDelegate
  
  func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
    var imageData = UIImageJPEGRepresentation(image, 1.0)!
    var i = 0
    while imageData.length / 1024 > 80 {
      let persent = CGFloat(100 - i++) / 100.0
      imageData = UIImageJPEGRepresentation(image, persent)!
    }
    avatarData = imageData
    self.avatarButton .setImage(UIImage(data: avatarData), forState: UIControlState.Normal)
    picker.dismissViewControllerAnimated(true, completion: { () -> Void in
      
    })
  }
  
  //MARK:- UITextFieldDelegate
  
  func textFieldShouldReturn(textField: UITextField) -> Bool {
    if textField == username {
      view.endEditing(true)
    }
    return true
  }

}
