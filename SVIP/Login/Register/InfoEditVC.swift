//
//  InfoEditVC.swift
//  SVIP
//
//  Created by  on 12/15/15.
//  Copyright © 2015 zkjinshi. All rights reserved.
//

import UIKit

class InfoEditVC: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextFieldDelegate {
  
  @IBOutlet weak var avatarButton: UIButton!
  @IBOutlet weak var username: UITextField!
  
  var avatarData: NSData? = nil
  var sex = "0"
  
  
  override func loadView() {
    NSBundle.mainBundle().loadNibNamed("InfoEditVC", owner:self, options:nil)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setUI()
  }
  
  func setUI() {

  }
  
  //MARK:- Button Action
  
  @IBAction func nextStep(sender: AnyObject) {
    if username.text!.isEmpty {
      showHint("用户名不能为空")
      return
    }
    
    if avatarData == nil {
      showHint("头像不能为空")
      return
    }
    
    showHUDInView(view, withLoading: "")
    
    guard let userName = username.text else { return }
    ZKJSHTTPSessionManager.sharedInstance().updateUserInfoWithUsername(userName, imageData: avatarData, sex: sex, email: nil,success: { (task: NSURLSessionDataTask!, responseObject: AnyObject!) -> Void in
      if let data = responseObject as? [String: AnyObject] {
        if let set = data["set"] as? NSNumber {
          if set.boolValue == true {
            AccountManager.sharedInstance().saveUserName(userName)
            self.hideHUD()
            self.navigationController?.pushViewController(InvitationCodeVC(), animated: true)
          }
        }
      }
      }) { (task: NSURLSessionDataTask!, error: NSError!) -> Void in
        
    }
  }
  
  @IBAction func selectAvatar(sender: AnyObject) {
    let alertController = UIAlertController(title: "选择图片", message: "", preferredStyle: .ActionSheet)
    let takePhotoAction = UIAlertAction(title: "拍照", style: .Default, handler: { (action: UIAlertAction) -> Void in
      let picker = UIImagePickerController()
      picker.sourceType = UIImagePickerControllerSourceType.Camera
      picker.delegate = self
      picker.allowsEditing = true
      self.presentViewController(picker, animated: true, completion: nil)
    })
    alertController.addAction(takePhotoAction)
    let choosePhotoAction = UIAlertAction(title: "从手机相册选择", style:.Default, handler: { (action: UIAlertAction) -> Void in
      let picker = UIImagePickerController()
      picker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
      picker.delegate = self
      picker.allowsEditing = true
      self.presentViewController(picker, animated: true, completion: nil)
    })
    alertController.addAction(choosePhotoAction)
    let cancelAction = UIAlertAction(title: "取消", style: .Cancel, handler: nil)
    alertController.addAction(cancelAction)
    presentViewController(alertController, animated: true, completion: nil)
  }
  
  @IBAction func selectSex(sender: UISegmentedControl) {
    switch sender.selectedSegmentIndex {
    case 0 :
      sex = "1"
    case 1 :
      sex = "0"
    default:
      print("default")
    }
    AccountManager.sharedInstance().saveSex(sex)
  }
  
  // MARK: - Gesture
  
  override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
    view.endEditing(true)
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
    self.avatarButton.setImage(UIImage(data: avatarData!), forState: UIControlState.Normal)
    picker.dismissViewControllerAnimated(true, completion: nil)
  }
  
  //MARK:- UITextFieldDelegate
  
  func textFieldShouldReturn(textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    return true
  }
  
}
