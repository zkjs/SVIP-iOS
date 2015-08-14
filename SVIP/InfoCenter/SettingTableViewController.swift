//
//  SettingTableViewController.swift
//  SVIP
//
//  Created by dai.fengyi on 15/8/14.
//  Copyright (c) 2015年 zkjinshi. All rights reserved.
//

import UIKit

class SettingTableViewController: UITableViewController {
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
    if (indexPath.section == 0) && (indexPath.row == 0) {
      let imageView = UIImageView(frame: CGRectMake(0, 0, 78, 78))
      imageView.image = UIImage(named: "img_hotel_zhanwei")
      cell?.accessoryView = imageView
    }
    return cell!
  }

  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    tableView .deselectRowAtIndexPath(indexPath, animated: true)
  }
  
  /*
  // Override to support conditional editing of the table view.
  override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
  // Return NO if you do not want the specified item to be editable.
  return true
  }
  */
  
  /*
  // Override to support editing the table view.
  override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
  if editingStyle == .Delete {
  // Delete the row from the data source
  tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
  } else if editingStyle == .Insert {
  // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
  }
  }
  */
  
  /*
  // Override to support rearranging the table view.
  override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
  
  }
  */
  
  /*
  // Override to support conditional rearranging of the table view.
  override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
  // Return NO if you do not want the item to be re-orderable.
  return true
  }
  */
  
  /*
  // MARK: - Navigation
  
  // In a storyboard-based application, you will often want to do a little preparation before navigation
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
  // Get the new view controller using [segue destinationViewController].
  // Pass the selected object to the new view controller.
  }
  */
  
}
