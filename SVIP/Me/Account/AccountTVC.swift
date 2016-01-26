//
//  AccountTVC.swift
//  SVIP
//
//  Created by  on 12/14/15.
//  Copyright © 2015 zkjinshi. All rights reserved.
//

import UIKit

class AccountTVC: UITableViewController, UINavigationControllerDelegate {
  
  @IBOutlet weak var invoinceLabel: UILabel!
  @IBOutlet weak var emailTextFiled: UITextField!
  @IBOutlet weak var sexTextField: UITextField!
  @IBOutlet weak var surnameTextField: UITextField!
  @IBOutlet weak var userImage: UIImageView!
  
  
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
  
  func loadUserData() {
    userImage.image = AccountManager.sharedInstance().avatarImage
    surnameTextField.text = AccountManager.sharedInstance().userName
    emailTextFiled.text = AccountManager.sharedInstance().email
    sexTextField.text = AccountManager.sharedInstance().sexName
    invoinceLabel.text = AccountManager.sharedInstance().invoice
  }
  
  // MARK: - Table view delegate
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    tableView.deselectRowAtIndexPath(indexPath, animated: true)
    
    let photo = NSIndexPath(forRow: 0, inSection: 0)
    let name = NSIndexPath(forRow: 1, inSection: 0)
    let sex = NSIndexPath(forRow: 2, inSection: 0)
    let email = NSIndexPath(forRow: 3, inSection: 0)
    let phone = NSIndexPath(forRow: 5, inSection: 0)
    let invoice = NSIndexPath(forRow: 6, inSection: 0)
    
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
    case invoice:
      let vc = InvoiceVC()
      self.navigationController?.pushViewController(vc, animated: true)
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
      ZKJSHTTPSessionManager.sharedInstance().updateUserInfoWithUsername(nil, imageData: nil, sex: "1", email:nil, success: { (task: NSURLSessionDataTask!, responseObject: AnyObject!) -> Void in
        print(responseObject)
        if let dic = responseObject as? NSDictionary {
          let set = dic["set"]!.boolValue!
          if set {
            AccountManager.sharedInstance().saveSex("1")
            self.refreshDataAndUI()
          }
        }
        }) { (task:NSURLSessionDataTask!, error: NSError!) -> Void in
          
      }
    })
    alertController.addAction(manAction)
    let womanAction = UIAlertAction(title: "女", style:.Default, handler: { (action: UIAlertAction) -> Void in
      ZKJSHTTPSessionManager.sharedInstance().updateUserInfoWithUsername(nil, imageData: nil, sex: "0", email:nil, success: { (task: NSURLSessionDataTask!, responseObject: AnyObject!) -> Void in
        print(responseObject)
        if let dic = responseObject as? NSDictionary {
          let set = dic["set"]!.boolValue!
          if set {
            AccountManager.sharedInstance().saveSex("0")
            self.refreshDataAndUI()
          }
        }
        }) { (task:NSURLSessionDataTask!, error: NSError!) -> Void in
          
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
    var imageData = UIImageJPEGRepresentation(image, 1.0)!
    var i = 0
    while imageData.length / 1024 > 80 {
      let persent = CGFloat(100 - i++) / 100.0
      imageData = UIImageJPEGRepresentation(image, persent)!
    }
    ZKJSHTTPSessionManager.sharedInstance().updateUserInfoWithUsername(nil, imageData: imageData, sex: nil, email: nil, success: { (task: NSURLSessionDataTask!, responseObject:AnyObject!) -> Void in
      if let dic = responseObject as? NSDictionary {
        if dic["set"]?.boolValue == true {
          AccountManager.sharedInstance().saveAvatarImageData(imageData)
          self.refreshDataAndUI()
          picker .dismissViewControllerAnimated(true, completion: nil)
        }
      }
      }) { (task: NSURLSessionDataTask!, error: NSError!) -> Void in
        
    }
  }
  
}
