//
//  AccountTVC.swift
//  SVIP
//
//  Created by  on 12/14/15.
//  Copyright © 2015 zkjinshi. All rights reserved.
//

import UIKit

class AccountTVC: UITableViewController ,UIActionSheetDelegate, UIImagePickerControllerDelegate,UINavigationControllerDelegate{
  
  @IBOutlet weak var emailTextFiled: UITextField!
  @IBOutlet weak var sexTextField: UITextField!
  @IBOutlet weak var surnameTextField: UITextField!
  @IBOutlet weak var userImage: UIImageView!
  var localBaseInfo :JSHBaseInfo?
  override func viewDidLoad() {
    super.viewDidLoad()
    
    title = "账户信息"
    self.refreshDataAndUI()
    tableView.tableFooterView = UIView()
  }
  private func refreshDataAndUI() {
    loadUserData()
    tableView.reloadData()
  }
  
  //定义一个带字符串参数的闭包
  func myClosure(testStr:String)->Void{
    surnameTextField.text = testStr
    emailTextFiled.text = testStr
  }
  
  func loadUserData() {
    localBaseInfo = JSHStorage.baseInfo()
    userImage.image = localBaseInfo?.avatarImage
    surnameTextField.text = localBaseInfo?.real_name
    emailTextFiled.text = localBaseInfo?.email
    sexTextField.text = localBaseInfo?.sex
  }
  
  // MARK: - Table view delegate
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    tableView.deselectRowAtIndexPath(indexPath, animated: true)
    switch indexPath {
    case NSIndexPath(forRow: 0, inSection: 0):
    UIActionSheet(title:NSLocalizedString("CHOOSE_PHOTO", comment: ""),
    delegate:self,
    cancelButtonTitle:NSLocalizedString("CANCEL", comment: ""),
    destructiveButtonTitle:NSLocalizedString("TAKE_PHOTO", comment: ""),
    otherButtonTitles:NSLocalizedString("PHOTO_LIBRARY", comment: "")) .showInView(self.view)
    case NSIndexPath(forRow: 1, inSection: 0):
      let vc = SettingEditViewController(type:VCType.realname)
    self.navigationController?.pushViewController(vc, animated: true)
      vc.testClosure = myClosure
    case NSIndexPath(forRow: 2, inSection: 0):
    let sheet = UIActionSheet(title: NSLocalizedString("SEX", comment: ""),
      delegate: self,
      cancelButtonTitle: NSLocalizedString("CANCEL", comment: ""),
      destructiveButtonTitle: NSLocalizedString("MAN", comment: ""),
      otherButtonTitles: NSLocalizedString("WOMAN", comment: ""))
    sheet.tag = 888
    sheet.showInView(self.view)
    case NSIndexPath(forRow: 3, inSection: 0):
    self.navigationController?.pushViewController(SettingEditViewController(type:VCType.email), animated: true)
    //section == 1
    case NSIndexPath(forRow: 5, inSection: 0):
    self.navigationController?.pushViewController(PhoneSettingFirstViewController(), animated: true)
    case NSIndexPath(forRow: 6, inSection: 0):
    self.navigationController?.pushViewController(InvoiceTableViewController(), animated: true)
    default:
    break
  }

  }
  
  //MARK:- ACTIONSHEET
  
  func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {//两个actionSheet，通过tag区分
    if actionSheet.tag == 888 {//选择性别
      var set = false
      var sex = JSHStorage.baseInfo().sex
      switch buttonIndex {
      case 0:
        sex = NSLocalizedString("MAN", comment: "")
        set = true
      case 2:
        sex = NSLocalizedString("WOMAN", comment: "")
        set = true
      default:
        break
      }
      if set {
        ZKJSHTTPSessionManager.sharedInstance().updateUserInfoWithUsername(nil, imageData: nil, sex: sex, email:nil, success: { (task: NSURLSessionDataTask!, responseObject: AnyObject!) -> Void in
          if let dic = responseObject as? NSDictionary {
            let set = dic["set"]!.boolValue!
            if set {
              self.showHint(NSLocalizedString("SAVED", comment: ""))
              let baseInfo = JSHStorage.baseInfo()
              baseInfo.sex = sex
              JSHStorage.saveBaseInfo(baseInfo)
              self.refreshDataAndUI()
            }
          }
          }) { (task:NSURLSessionDataTask!, error: NSError!) -> Void in
            
        }
      }
      return
    }
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
    //    let dic = editingInfo
    var imageData = UIImageJPEGRepresentation(image, 1.0)!
    var i = 0
    while imageData.length / 1024 > 80 {
      let persent = CGFloat(100 - i++) / 100.0
      imageData = UIImageJPEGRepresentation(image, persent)!
    }
//    ZKJSHTTPSessionManager.sharedInstance().updateUserInfoWithUsername(nil, realname: nil, imageData: imageData, imageName: "abc", sex: nil, company: nil, occupation: nil, email: nil, tagopen: nil,success: { (task: NSURLSessionDataTask!, responseObject:AnyObject!) -> Void in
//      if let dic = responseObject as? NSDictionary {
//        if dic["set"]?.boolValue == true {
//          let baseInfo = JSHStorage.baseInfo()
//          baseInfo.avatarImage = UIImage(data: imageData)
//          JSHStorage.saveBaseInfo(baseInfo)
//          self.refreshDataAndUI()
//          picker .dismissViewControllerAnimated(true, completion: { () -> Void in
//            
//          })
//        }
//      }
//      }) { (task: NSURLSessionDataTask!, error: NSError!) -> Void in
//        
//    }
  }

}
