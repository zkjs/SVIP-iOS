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
  @IBOutlet weak var realname: UITextField!
  @IBOutlet weak var company: UITextField!
//  @IBOutlet var sexButtons: [UIButton]!
  @IBOutlet weak var maleButton: UIButton!
  @IBOutlet weak var femaleButton: UIButton!
  var avatarData: NSData! = nil
  var sexstr = "男"
  
  required override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
    super.init(nibName: "InfoEditViewController", bundle: nil)
  }

  required init(coder aDecoder: NSCoder) {
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
    self.title = "完善信息"
    let right = UIBarButtonItem(image: UIImage(named: "ic_qianwang"), style: UIBarButtonItemStyle.Plain, target: self, action: "save")
//    let right = UIBarButtonItem(title: "提交", style: UIBarButtonItemStyle.Plain, target: self, action: "save")
    self.navigationItem.rightBarButtonItem = right
    self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.whiteColor()]
    self.navigationItem.rightBarButtonItem?.tintColor = UIColor.whiteColor()
    self.navigationController?.navigationBar .setBackgroundImage(UIImage(named: "ic_qianwang"), forBarMetrics: UIBarMetrics.Compact)
    
    let tap = UITapGestureRecognizer(target: self, action: "touchBlank")
    bgImgeView.addGestureRecognizer(tap)
    
    let attString1 = NSAttributedString(string: "昵称(必填)", attributes: [NSFontAttributeName : UIFont.systemFontOfSize(14), NSForegroundColorAttributeName : UIColor(fromHexString: "0x8d8d8d")])
    let attString2 = NSAttributedString(string: "姓名(必填)", attributes: [NSFontAttributeName : UIFont.systemFontOfSize(14), NSForegroundColorAttributeName : UIColor(fromHexString: "0x8d8d8d")])
    let attString3 = NSAttributedString(string: "公司/单位", attributes: [NSFontAttributeName : UIFont.systemFontOfSize(14), NSForegroundColorAttributeName : UIColor(fromHexString: "0x8d8d8d")])
    username.attributedPlaceholder = attString1
    realname.attributedPlaceholder = attString2
    company.attributedPlaceholder = attString3
    
    if let baseInfo = JSHStorage.baseInfo() {
      avatarButton.setImage(baseInfo.avatarImage, forState: UIControlState.Normal)
      username.text = baseInfo.username
      sexstr = baseInfo.sex
      if sexstr == "男" {
        selectSex(maleButton)
      }
      
    }
  }
  
  
  //MARK:- Button Action
  func save() {
    if username.text.isEmpty || realname.text.isEmpty {
      ZKJSTool .showMsg("请填写必填项")
      return
    }
    ZKJSTool.showLoading()
    ZKJSHTTPSessionManager.sharedInstance().updateUserInfoWithUserID(JSHAccountManager.sharedJSHAccountManager().userid, token: JSHAccountManager.sharedJSHAccountManager().token, username: username.text, realname: realname.text, imageData: avatarData, imageName: " ", sex: sexstr, company: company.text, occupation: nil, email: nil, tagopen: nil,success: { (task: NSURLSessionDataTask!, responseObject: AnyObject!) -> Void in
      let dic = responseObject as! NSDictionary
      if dic["set"]!.boolValue! {
        LoginManager.sharedInstance().afterAnimation()
      }
      }) { (task: NSURLSessionDataTask!, error: NSError!) -> Void in
      
    }
    
    
  }
  @IBAction func selectAvatar(sender: AnyObject) {
    UIActionSheet(title:"选择照片来源", delegate:self, cancelButtonTitle:"取消", destructiveButtonTitle:"照相", otherButtonTitles:"照片库").showInView(self.view)
  }
  
  @IBAction func selectSex(sender: UIButton) {
    if sender == maleButton {
      femaleButton.selected = false
      sexstr = "男"
    }else {
      maleButton.selected = false
      sexstr = "女"
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
    let dic = editingInfo
    /*
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    NSData *imageData = UIImageJPEGRepresentation(image, 1.0);
    int i = 1;
    while (imageData.length / 1024 > 80) {
    float persent = (100 - i++) / 100;
    imageData = UIImageJPEGRepresentation(image, persent);
    }
    
    image = [UIImage imageWithData:imageData];
    [_avatarButton setImage:image forState:UIControlStateNormal];
    _headerFrame.baseInfo.avatarImage = image;
    [picker dismissViewControllerAnimated:YES completion:^{
    
    }];
    */
    var imageData = UIImageJPEGRepresentation(image, 1.0)
    var i = 0
    while imageData.length / 1024 > 80 {
      var persent = CGFloat(100 - i++) / 100.0
      imageData = UIImageJPEGRepresentation(image, persent)
    }
    avatarData = imageData
    self.avatarButton .setImage(UIImage(data: avatarData), forState: UIControlState.Normal)
    picker.dismissViewControllerAnimated(true, completion: { () -> Void in
      
    })
  }
  //MARK:- UITextFieldDelegate
  func textFieldShouldReturn(textField: UITextField) -> Bool {
    if textField == username {
      realname.becomeFirstResponder()
    }else if textField == realname {
      company.becomeFirstResponder()
    }else {
      company.endEditing(true)
    }
    return true
  }
//    ZKJSHTTPSessionManager.sharedInstance().updateUserInfoWithUserID(JSHAccountManager.sharedJSHAccountManager().userid, token: JSHAccountManager.sharedJSHAccountManager().token, username: nil, realname: nil, imageData: imageData, imageName: "abc", sex: nil, company: nil, occupation: nil, email: nil, success: { (task: NSURLSessionDataTask!, responseObject:AnyObject!) -> Void in
//      if let dic = responseObject as? NSDictionary {
//        if dic["set"]?.boolValue == true {
//          var baseInfo = JSHStorage.baseInfo()
//          baseInfo.avatarImage = UIImage(data: imageData)
//          JSHStorage.saveBaseInfo(baseInfo)
//          picker .dismissViewControllerAnimated(true, completion: { () -> Void in
//            
//          })
//        }
//      }
//      }) { (task: NSURLSessionDataTask!, error: NSError!) -> Void in
//        
//    }

}
