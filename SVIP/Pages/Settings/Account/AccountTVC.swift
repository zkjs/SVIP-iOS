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
      
    } else {
      
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
    let phone = NSIndexPath(forRow: 5, inSection: 0)
    
    switch indexPath {
    case photo:
      choosePhoto()
    case name:
      navigationController?.pushViewController(NameVC(), animated: true)
    case sex:
      chooseSex()
    case email:
      navigationController?.pushViewController(EmailVC(), animated: true)
    case phone:
      navigationController?.pushViewController(PhoneFirstVC(), animated: true)
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
      HttpService.sharedInstance.updateUserInfo(false, realname:nil, sex: "1", image: nil, email: nil) { (json, error) -> () in
        if let _ = error {
          
        } else {
          AccountManager.sharedInstance().saveSex(1)
          self.refreshDataAndUI()
        }
      }
    })
    alertController.addAction(manAction)
    let womanAction = UIAlertAction(title: "女", style:.Default, handler: { (action: UIAlertAction) -> Void in
      HttpService.sharedInstance.updateUserInfo(false, realname:nil, sex: "0", image: nil, email: nil) { (json, error) -> () in
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
    var imageData = UIImageJPEGRepresentation(image, 1.0)!
    var i = 0
    while imageData.length / 1024 > 80 {
      let persent = CGFloat(100 - i++) / 100.0
      imageData = UIImageJPEGRepresentation(image, persent)!
    }
    
    HttpService.sharedInstance.updateUserInfo(false, realname:nil, sex: nil, image: image,email: nil) {[unowned self] (json, error) -> () in
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
