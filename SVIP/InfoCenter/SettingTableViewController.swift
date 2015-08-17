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
  required override init!(nibName nibNameOrNil: String!, bundle nibBundleOrNil: NSBundle!) {
    let path = NSBundle.mainBundle() .pathForResource("SettingTable", ofType: "plist")
    textArray = NSArray(contentsOfFile: path!) as! Array
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
  }
  /*
  NSString *userId = [JSHAccountManager sharedJSHAccountManager].userid;
  NSString *token = [JSHAccountManager sharedJSHAccountManager].token;
  JSHBaseInfo *localBaseInfo = [JSHStorage baseInfo];
  if ([localBaseInfo.phone isEqualToString:@"请编辑个人信息"]) {
  //获取个人信息
  [[ZKJSHTTPSessionManager sharedInstance] getUserInfo:userId token:token success:^(NSURLSessionDataTask *task, id responseObject) {
  JSHBaseInfo *baseInfo = [[JSHBaseInfo alloc] initWithDic:responseObject];
  //本地存储
  [JSHStorage saveBaseInfo:baseInfo];
  if (![responseObject[@"tagsid"] isKindOfClass:[NSNull class]]) {
  NSArray *abc = [NSString arrayWithSortedString:responseObject[@"tagsid"] dividedByString:@","];
  [JSHStorage saveLikeArray:abc];
  }
  //刷新frame
  _header.headerFrame.baseInfo = baseInfo;
  _header.headerFrame.Edit = YES;
  _header.headerFrame = _header.headerFrame;//类似于tableview reloadData，刷新界面
  } failure:^(NSURLSessionDataTask *task, NSError *error) {
  
  }];
  }else {
  //取本地数据
  _header.headerFrame.baseInfo = [JSHStorage baseInfo];
  _header.headerFrame.Edit = YES;
  _header.headerFrame = _header.headerFrame;
  }
  */
  override init(style: UITableViewStyle) {
    let path = NSBundle.mainBundle() .pathForResource("SettingTable", ofType: "plist")
    textArray = NSArray(contentsOfFile: path!) as! Array
    super.init(style: style)
  }

  required init!(coder aDecoder: NSCoder!) {
      fatalError("init(coder:) has not been implemented")
  }
  
  func loadData() {
    let userId = JSHAccountManager.sharedJSHAccountManager().userid
    let token = JSHAccountManager.sharedJSHAccountManager().token
    localBaseInfo = JSHStorage.baseInfo()
    if localBaseInfo!.phone == "请编辑个人信息" {
      ZKJSHTTPSessionManager.sharedInstance().getUserInfo(userId, token: token, success: { (task: NSURLSessionDataTask!, responseObject: AnyObject!) -> Void in
        if let dic = responseObject as? [NSObject : AnyObject] {
          let baseInfo = JSHBaseInfo(dic: dic)
          //本地存储
          JSHStorage.saveBaseInfo(baseInfo)
          if let tagsid = dic["tagsid"] as? String {
            let arr = NSString.arrayWithSortedString(tagsid, dividedByString: ",")
            JSHStorage.saveLikeArray(arr)
          }
        }
        
        }, failure: { (task:NSURLSessionDataTask!, error: NSError!) -> Void in
          
      })
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = false
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    loadData()
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
        imageView.image = UIImage(named: "img_hotel_zhanwei")
        cell?.accessoryView = imageView
      case 1:
        if localBaseInfo?.name != nil {
          cell?.detailTextLabel?.text = localBaseInfo?.name
        }
      case 2:
        if localBaseInfo?.nickname != nil {
          cell?.detailTextLabel?.text = localBaseInfo?.nickname
        }
      case 3:
        println()
//        if localBaseInfo?.sex != nil {
//          cell?.detailTextLabel?.text = localBaseInfo?.sex
//        }
      case 4:
        if localBaseInfo?.company != nil {
          cell?.detailTextLabel?.text = localBaseInfo?.company
        }
      case 5:
        if localBaseInfo?.email != nil {
          cell?.detailTextLabel?.text = localBaseInfo?.email
        }
      default:
        break;
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
      self.navigationController?.pushViewController(SettingEditViewController(type:VCType.name), animated: true)
    case NSIndexPath(forRow: 2, inSection: 0):
      self.navigationController?.pushViewController(SettingEditViewController(type:VCType.nickname), animated: true)
    case NSIndexPath(forRow: 3, inSection: 0):
      //sex
      println()
    case NSIndexPath(forRow: 4, inSection: 0):
      self.navigationController?.pushViewController(SettingEditViewController(type:VCType.company), animated: true)
    case NSIndexPath(forRow: 5, inSection: 0):
      self.navigationController?.pushViewController(SettingEditViewController(type:VCType.email), animated: true)
    default:
      break
    }
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


}
