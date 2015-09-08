//
//  SettingTableViewController.swift
//  SVIP
//
//  Created by dai.fengyi on 15/8/14.
//  Copyright (c) 2015年 zkjinshi. All rights reserved.
//

import UIKit

class SettingTableViewController: UITableViewController, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  var localBaseInfo :JSHBaseInfo?
  let Identifier = "reuseIdentifier"
  let textArray: Array<Array<String>>
  //MARK:- Init
  required override init!(nibName nibNameOrNil: String!, bundle nibBundleOrNil: NSBundle!) {
    let path = NSBundle.mainBundle() .pathForResource("SettingTable", ofType: "plist")
    textArray = NSArray(contentsOfFile: path!) as! Array
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
  }

  override init(style: UITableViewStyle) {
    let path = NSBundle.mainBundle() .pathForResource("SettingTable", ofType: "plist")
    textArray = NSArray(contentsOfFile: path!) as! Array
    super.init(style: style)
  }

  required init!(coder aDecoder: NSCoder!) {
      fatalError("init(coder:) has not been implemented")
  }
  //MARK:- Life Cycle
  func loadData() {
    let userId = JSHAccountManager.sharedJSHAccountManager().userid
    let token = JSHAccountManager.sharedJSHAccountManager().token
    localBaseInfo = JSHStorage.baseInfo()
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    refreshDataAndUI()//每次出现都加在一次数据，并且刷新tableview
  }
  
  private func refreshDataAndUI() {
    loadData()
    tableView.reloadData()
  }
  
  // MARK: - Table view data source
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return textArray.count
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    let arr = textArray[section]
    return arr.count
  }
  
  override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    if (indexPath.section == 0) && (indexPath.row == 0) {
      return 88
    }
    return 44
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    var cell = tableView.dequeueReusableCellWithIdentifier(Identifier) as? UITableViewCell
    if cell == nil {
      cell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: Identifier)
    }
  // Configure the cell...
    cell!.textLabel?.text = textArray[indexPath.section][indexPath.row]
    if indexPath.section == 0 {
      switch indexPath.row {
      case 0:
        let imageView = UIImageView(frame: CGRectMake(0, 0, 78, 78))
        imageView.layer.cornerRadius = 78 / 2
        imageView.layer.masksToBounds = true
        if let image = localBaseInfo?.avatarImage {
          imageView.image = image
        }else {
          imageView.image = UIImage(named: "img_hotel_zhanwei")
        }
        cell?.accessoryView = imageView
      case 1:
        if localBaseInfo?.real_name != nil {
          cell?.detailTextLabel?.text = localBaseInfo?.real_name
        }
      case 2:
        if localBaseInfo?.username != nil {
          cell?.detailTextLabel?.text = localBaseInfo?.username
        }
      case 3:
        println()
        if localBaseInfo?.sex != nil {
          cell?.detailTextLabel?.text = localBaseInfo?.sex
        }
      case 4:
        if localBaseInfo?.company != nil {
          cell?.detailTextLabel?.text = localBaseInfo?.company
        }
      case 5:
        if localBaseInfo?.email != nil {
          cell?.detailTextLabel?.text = localBaseInfo?.email
        }
      default:
        break
      }
    }else if indexPath.section == 1 {
      switch indexPath.row {
      case 0:
        cell?.detailTextLabel?.text = localBaseInfo?.phone
      default:
        break
      }
    }
    
    return cell!
  }

  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    tableView .deselectRowAtIndexPath(indexPath, animated: true)
    switch indexPath {
    case NSIndexPath(forRow: 0, inSection: 0):
      UIActionSheet(title:"选择照片来源", delegate:self, cancelButtonTitle:"取消", destructiveButtonTitle:"照相", otherButtonTitles:"照片库") .showInView(self.view)
    case NSIndexPath(forRow: 1, inSection: 0):
      self.navigationController?.pushViewController(SettingEditViewController(type:VCType.realname), animated: true)
    case NSIndexPath(forRow: 2, inSection: 0):
      self.navigationController?.pushViewController(SettingEditViewController(type:VCType.username), animated: true)
    case NSIndexPath(forRow: 3, inSection: 0):
      let sheet = UIActionSheet(title: "性别", delegate: self, cancelButtonTitle: "取消", destructiveButtonTitle: "男", otherButtonTitles: "女")
      sheet.tag = 888
      sheet.showInView(self.view)
    case NSIndexPath(forRow: 4, inSection: 0):
      self.navigationController?.pushViewController(SettingEditViewController(type:VCType.company), animated: true)
    case NSIndexPath(forRow: 5, inSection: 0):
      self.navigationController?.pushViewController(SettingEditViewController(type:VCType.email), animated: true)
    //section == 1
    case NSIndexPath(forRow: 0, inSection: 1):
      self.navigationController?.pushViewController(PhoneSettingFirstViewController(), animated: true)
    case NSIndexPath(forRow: 1, inSection: 1):
      self.navigationController?.pushViewController(InvoiceTableViewController(), animated: true)
    case NSIndexPath(forRow: 2, inSection: 1):
      self.navigationController?.pushViewController(PersonalLabelViewController(), animated: true)
    case NSIndexPath(forRow: 3, inSection: 1):
      self.navigationController?.pushViewController(AboutUsViewController(), animated: true)
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
        sex = "男"
        set = true
      case 2:
        sex = "女"
        set = true
      default:
        break
      }
      if set {
        ZKJSHTTPSessionManager.sharedInstance().updateUserInfoWithUserID(JSHAccountManager.sharedJSHAccountManager().userid, token: JSHAccountManager.sharedJSHAccountManager().token, username: nil, realname: nil, imageData: nil, imageName: nil, sex: sex, company: nil, occupation: nil, email:nil, tagopen:nil,success: { (task: NSURLSessionDataTask!, responseObject: AnyObject!) -> Void in
          if let dic = responseObject as? NSDictionary {
            let set = dic["set"]!.boolValue!
            if set {
              ZKJSTool.showMsg("保存成功")
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
    let dic = editingInfo
    var imageData = UIImageJPEGRepresentation(image, 1.0)
    var i = 0
    while imageData.length / 1024 > 80 {
      var persent = CGFloat(100 - i++) / 100.0
      imageData = UIImageJPEGRepresentation(image, persent)
    }
    ZKJSHTTPSessionManager.sharedInstance().updateUserInfoWithUserID(JSHAccountManager.sharedJSHAccountManager().userid, token: JSHAccountManager.sharedJSHAccountManager().token, username: nil, realname: nil, imageData: imageData, imageName: "abc", sex: nil, company: nil, occupation: nil, email: nil, tagopen: nil,success: { (task: NSURLSessionDataTask!, responseObject:AnyObject!) -> Void in
      if let dic = responseObject as? NSDictionary {
        if dic["set"]?.boolValue == true {
          var baseInfo = JSHStorage.baseInfo()
          baseInfo.avatarImage = UIImage(data: imageData)
          JSHStorage.saveBaseInfo(baseInfo)
          picker .dismissViewControllerAnimated(true, completion: { () -> Void in
            
          })
        }
      }
      }) { (task: NSURLSessionDataTask!, error: NSError!) -> Void in
      
    }
  }
}
