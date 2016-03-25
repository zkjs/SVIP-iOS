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
  var sex = 1
  var image = UIImage()
  
  override func loadView() {
    NSBundle.mainBundle().loadNibNamed("InfoEditVC", owner:self, options:nil)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setUI()
  }
  
  func setUI() {

  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    
    navigationController?.navigationBarHidden = true
  }
  
  override func viewWillDisappear(animated: Bool) {
    super.viewWillDisappear(animated)
    
    navigationController?.navigationBarHidden = false
  }
  
  //MARK:- Button Action
  
  @IBAction func nextStep(sender: AnyObject) {
    if username.text!.isEmpty {
      showHint("用户名不能为空")
      return
    }
    
    if username.text!.characters.count > 6 {
      showHint("用户名最多6位")
      return
    }
    
    if avatarData == nil {
      showHint("头像不能为空")
      return
    }
    
    showHUDInView(view, withLoading: "")
    
    guard let userName = username.text else { return }
    
    HttpService.sharedInstance.updateUserInfo(true, realname:userName, sex: "\(sex)", image: self.image,email: nil) {[unowned self] (json, error) -> () in
      self.hideHUD()
      if let error = error {
        if let msg = error.userInfo["resDesc"] as? String {
          ZKJSTool.showMsg(msg)
        } else {
          ZKJSTool.showMsg("上传图片失败，请再次尝试")
        }
      } else {
        AccountManager.sharedInstance().saveUserName(userName)
        NSNotificationCenter.defaultCenter().postNotificationName(KNOTIFICATION_LOGINCHANGE, object: NSNumber(bool: false))
        self.navigationController?.pushViewController(InvitationCodeVC(), animated: true)
      }
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
      sex = 1
    case 1 :
      sex = 0
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
    self.image = image
    var imageData = UIImageJPEGRepresentation(image, 1)!
    var i = 0
    while imageData.length / 1024 > 10 {
      let persent = CGFloat(100 - i++) / 100.0
      imageData = UIImageJPEGRepresentation(image, persent)!
    }
    avatarData = imageData
//    AccountManager.sharedInstance().saveAvatarImageData(avatarData!)
    self.avatarButton.setImage(UIImage(data: avatarData!), forState: UIControlState.Normal)
    picker.dismissViewControllerAnimated(true, completion: nil)
    
//    if let image = UIImage(named: "example.png") {
//      if let data = UIImagePNGRepresentation(image) {
//        self.filename = getDocumentsDirectory().stringByAppendingPathComponent("copy.png")
//        data.writeToFile(filename, atomically: true)
//      }
//    }
    
    
    
  }
  
  func getDocumentsDirectory() -> NSString {
    let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
    let documentsDirectory = paths[0]
    return documentsDirectory
  }
  
  //MARK:- UITextFieldDelegate
  
  func textFieldShouldReturn(textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    return true
  }
  
}
