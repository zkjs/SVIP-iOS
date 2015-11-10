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
  var textArray = Array<Array<String>>()
  
  //MARK:- Init
  
  required override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    loadData()
  }

  override init(style: UITableViewStyle) {
    super.init(style: style)
    loadData()
  }

  required init!(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
  }
  
  //MARK:- Life Cycle
  
  func loadData() {
    var titleSection1 = [String]()
    let title1 = NSLocalizedString("PROFILE_IMAGE", comment: "")
    let title2 = NSLocalizedString("NAME", comment: "")
    let title3 = NSLocalizedString("NICKNAME", comment: "")
    let title4 = NSLocalizedString("SEX", comment: "")
    let title5 = NSLocalizedString("COMPANY", comment: "")
    let title6 = NSLocalizedString("EMAIL", comment: "")
    titleSection1.append(title1)
    titleSection1.append(title2)
    titleSection1.append(title3)
    titleSection1.append(title4)
    titleSection1.append(title5)
    titleSection1.append(title6)
    textArray.append(titleSection1)
    
    var titleSection2 = [String]()
    let title7 = NSLocalizedString("MOBILE_NUMBER", comment: "")
    let title8 = NSLocalizedString("INVOICE_LIST", comment: "")
    let title9 = NSLocalizedString("PERSONAL_TAGS", comment: "")
    let title10 = NSLocalizedString("ABOUT_US", comment: "")
    titleSection2.append(title7)
    titleSection2.append(title8)
    titleSection2.append(title9)
    titleSection2.append(title10)
    textArray.append(titleSection2)
  }
  
  func loadUserData() {
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
    loadUserData()
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
    var cell = tableView.dequeueReusableCellWithIdentifier(Identifier)
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
        imageView.contentMode = .ScaleAspectFit
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
        print("")
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
      UIActionSheet(title:NSLocalizedString("CHOOSE_PHOTO", comment: ""),
                    delegate:self,
                    cancelButtonTitle:NSLocalizedString("CANCEL", comment: ""),
                    destructiveButtonTitle:NSLocalizedString("TAKE_PHOTO", comment: ""),
                    otherButtonTitles:NSLocalizedString("PHOTO_LIBRARY", comment: "")) .showInView(self.view)
    case NSIndexPath(forRow: 1, inSection: 0):
      self.navigationController?.pushViewController(SettingEditViewController(type:VCType.realname), animated: true)
    case NSIndexPath(forRow: 2, inSection: 0):
      self.navigationController?.pushViewController(SettingEditViewController(type:VCType.username), animated: true)
    case NSIndexPath(forRow: 3, inSection: 0):
      let sheet = UIActionSheet(title: NSLocalizedString("SEX", comment: ""),
                                delegate: self,
                                cancelButtonTitle: NSLocalizedString("CANCEL", comment: ""),
                                destructiveButtonTitle: NSLocalizedString("MAN", comment: ""),
                                otherButtonTitles: NSLocalizedString("WOMAN", comment: ""))
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
        sex = NSLocalizedString("MAN", comment: "")
        set = true
      case 2:
        sex = NSLocalizedString("WOMAN", comment: "")
        set = true
      default:
        break
      }
      if set {
        ZKJSHTTPSessionManager.sharedInstance().updateUserInfoWithUsername(nil, realname: nil, imageData: nil, imageName: nil, sex: sex, company: nil, occupation: nil, email:nil, tagopen:nil,success: { (task: NSURLSessionDataTask!, responseObject: AnyObject!) -> Void in
          if let dic = responseObject as? NSDictionary {
            let set = dic["set"]!.boolValue!
            if set {
              ZKJSTool.showMsg(NSLocalizedString("SAVED", comment: ""))
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
    ZKJSHTTPSessionManager.sharedInstance().updateUserInfoWithUsername(nil, realname: nil, imageData: imageData, imageName: "abc", sex: nil, company: nil, occupation: nil, email: nil, tagopen: nil,success: { (task: NSURLSessionDataTask!, responseObject:AnyObject!) -> Void in
      if let dic = responseObject as? NSDictionary {
        if dic["set"]?.boolValue == true {
          let baseInfo = JSHStorage.baseInfo()
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
