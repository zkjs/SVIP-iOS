//
//  AccountTVC.swift
//  SVIP
//
//  Created by  on 12/14/15.
//  Copyright © 2015 zkjinshi. All rights reserved.
//

import UIKit

class AccountTVC: UITableViewController, UINavigationControllerDelegate {
  
  @IBOutlet weak var emailTextFiled: UITextField!
  @IBOutlet weak var sexTextField: UITextField!
  @IBOutlet weak var surnameTextField: UITextField!
  @IBOutlet weak var userImage: UIImageView!
  
  @IBOutlet weak var switchPush: UISwitch!
  @IBOutlet weak var switchMonitoring: UISwitch!
  var silentMode = "0"//消息免打扰
  override func viewDidLoad() {
    super.viewDidLoad()
    
    title = "账户信息"
    
    tableView.tableFooterView = UIView()
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    
    refreshDataAndUI()
  }

  private func refreshDataAndUI() {
    let attributeString = NSAttributedString(string:"立即补全信息",
      attributes:[NSForegroundColorAttributeName: UIColor.ZKJS_mainColor(), NSFontAttributeName: UIFont.systemFontOfSize(14.0)])
    surnameTextField.attributedPlaceholder = attributeString
    sexTextField.attributedPlaceholder = attributeString
    emailTextFiled.attributedPlaceholder = attributeString
    guard let userid = TokenPayload.sharedInstance.userID else {return}
    if let silentMode:String = StorageManager.sharedInstance().pushMessageWithUserid(userid) {
      self.silentMode = silentMode
    }
    if silentMode == "0" {
      switchPush.on = true
    } else {
      switchPush.on = false
    }
    
    switchMonitoring.on = !StorageManager.sharedInstance().settingMonitoring()
    
    HttpService.sharedInstance.getUserinfo(nil)
    loadUserData()
    tableView.reloadData()
  }
  
  //定义一个带字符串参数的闭包
  func myClosure(testStr:String)->Void{
    surnameTextField.text = testStr
    emailTextFiled.text = testStr
  }
  
  
  @IBAction func pushSwitch(sender: AnyObject) {
    if switchPush.on {
      HttpService.sharedInstance.updateUserInfo(false, realname:nil, sex: nil, image: nil, email: nil,silentmode:"0") { (json, error) -> () in
        if let _ = error {
          
        } else {
          guard let userid = TokenPayload.sharedInstance.userID else {return}
          StorageManager.sharedInstance().savepushMessageWithUserid(userid,slientmode: "0")
        }
      }
    } else {
      HttpService.sharedInstance.updateUserInfo(false, realname:nil, sex: nil, image: nil, email: nil,silentmode:"1") { (json, error) -> () in
        if let _ = error {
          
        } else {
          guard let userid = TokenPayload.sharedInstance.userID else {return}
          StorageManager.sharedInstance().savepushMessageWithUserid(userid,slientmode: "1")
        }
      }
  
    }
  }
  
  
  @IBAction func monitoringSwitch(sender: UISwitch) {
    let monitoring = StorageManager.sharedInstance().settingMonitoring()
    if monitoring {// stop monitoring
      let confirmAlert = UIAlertController(title: "提示", message: "确定要隐藏身份吗?", preferredStyle: .Alert)
      let confirmAction = UIAlertAction(title: "确定", style: .Default) { (_) in
        BeaconMonitor.sharedInstance.stopMonitoring()
        LocationMonitor.sharedInstance.stopUpdatingLocation()
        LocationMonitor.sharedInstance.stopMonitoringLocation()
        StorageManager.sharedInstance().settingMonitoring(!monitoring)
        self.switchMonitoring.on = !StorageManager.sharedInstance().settingMonitoring()
      }
      let cancelAction = UIAlertAction(title: "取消", style: .Cancel) { (_) in
        self.switchMonitoring.on = false
      }
      confirmAlert.addAction(confirmAction)
      confirmAlert.addAction(cancelAction)
      presentViewController(confirmAlert, animated: true, completion: nil)
      
    } else { // start monitoring
      BeaconMonitor.sharedInstance.startMonitoring()
      LocationMonitor.sharedInstance.startUpdatingLocation()
      StorageManager.sharedInstance().settingMonitoring(!monitoring)
      switchMonitoring.on = !StorageManager.sharedInstance().settingMonitoring()
    }
  }
  
  func loadUserData() {
    print(AccountManager.sharedInstance().avatarURL)
    userImage.sd_setImageWithURL(NSURL(string: AccountManager.sharedInstance().avatarURL), placeholderImage: UIImage(named: "logo_white"))
    surnameTextField.text = AccountManager.sharedInstance().userName
    emailTextFiled.text = AccountManager.sharedInstance().email
    sexTextField.text = AccountManager.sharedInstance().sexName
  }
  
  // MARK: - Table view delegate
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    tableView.deselectRowAtIndexPath(indexPath, animated: true)
    
    let photo = NSIndexPath(forRow: 0, inSection: 0)
    let name = NSIndexPath(forRow: 1, inSection: 0)
    let sex = NSIndexPath(forRow: 2, inSection: 0)
    let email = NSIndexPath(forRow: 3, inSection: 0)
    
    switch indexPath {
    case photo:
      if let ismodifyimage:Int = AccountManager.sharedInstance().ismodifyimage {
        if ismodifyimage == 1 {
          self.showHint("每月只能修改一次头像", withFontSize: 18)
        } else {
          choosePhoto()
        }
      }
    case name:
      if let ismodifyusername:Int = AccountManager.sharedInstance().ismodifyusername {
        if ismodifyusername == 1 {
          self.showHint("姓名只能修改一次", withFontSize: 18)
        } else {
          navigationController?.pushViewController(NameVC(), animated: true)
        }
      }
    case sex:
      chooseSex()
    case email:
      navigationController?.pushViewController(EmailVC(), animated: true)
    default:
      break
    }
  }
  
  func choosePhoto() {
    let alertController = UIAlertController(title: "请选择图片", message: "", preferredStyle: .ActionSheet)
    let takePhotoAction = UIAlertAction(title: "拍照", style:.Default, handler: { (action: UIAlertAction) -> Void in
      let picker = UIImagePickerController()
      picker.sourceType = UIImagePickerControllerSourceType.Camera
      picker.delegate = self
      picker.allowsEditing = true
      self.presentViewController(picker, animated: true, completion: nil)
    })
    alertController.addAction(takePhotoAction)
    let choosePhotoAction = UIAlertAction(title: "从相册中选择", style:.Default, handler: { (action: UIAlertAction) -> Void in
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
  
  func chooseSex() {
    let alertController = UIAlertController(title: "请选择性别", message: "", preferredStyle: .ActionSheet)
    let manAction = UIAlertAction(title: "男", style:.Default, handler: { (action: UIAlertAction) -> Void in
      HttpService.sharedInstance.updateUserInfo(false, realname:nil, sex: "1", image: nil, email: nil,silentmode:nil) { (json, error) -> () in
        if let _ = error {
          
        } else {
          AccountManager.sharedInstance().saveSex(1)
          self.refreshDataAndUI()
        }
      }
    })
    alertController.addAction(manAction)
    let womanAction = UIAlertAction(title: "女", style:.Default, handler: { (action: UIAlertAction) -> Void in
      HttpService.sharedInstance.updateUserInfo(false, realname:nil, sex: "0", image: nil, email: nil,silentmode:nil) { (json, error) -> () in
        if let _ = error {
          
        } else {
          AccountManager.sharedInstance().saveSex(0)
          self.refreshDataAndUI()
        }
      }
    })
    
    alertController.addAction(womanAction)
    let cancelAction = UIAlertAction(title: "取消", style: .Cancel, handler: nil)
    alertController.addAction(cancelAction)
    presentViewController(alertController, animated: true, completion: nil)
  }
  
}

// MARK: - UIImagePickerControllerDelegate

extension AccountTVC: UIImagePickerControllerDelegate {
  
  func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
    picker.dismissViewControllerAnimated(true, completion: nil)

    showHudInView(view, hint: "正在上传头像...")
    var imageData = UIImageJPEGRepresentation(image, 0.8)!
    var i = 0
    while imageData.length / 1024 > 80 {
      i += 1
      let persent = CGFloat(100 - i) / 100.0
      imageData = UIImageJPEGRepresentation(image, persent)!
    }
    
    
    
    HttpService.sharedInstance.updateUserInfo(false, realname:nil, sex: nil, image: image,email: nil,silentmode:nil) {[unowned self] (json, error) -> () in
      self.hideHUD()
      if let error = error {
        self.showHint("上传头像失败")
        print(error)
      } else {
        HttpService.sharedInstance.getUserinfo({[unowned self] (json, error) -> () in
          self.refreshDataAndUI()
          self.showHint("上传头像成功")
        })
      }
    }
    
  }
  
}
