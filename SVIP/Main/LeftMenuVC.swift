//
//  LeftMenuVC.swift
//  SVIP
//
//  Created by dai.fengyi on 15/8/7.
//  Copyright (c) 2015年 zkjinshi. All rights reserved.
//

import UIKit

enum LeftButton: Int {
  case Setting = 0
  case InRoomCheckin
  case BookingOrder
  case HistoryOrder
}

let LeftMenuProportion = 0.75

class LeftMenuVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
  let Identifier = "LeftMenuCell"
//  var dataArray: NSArray?
  var dataArray = Array<[String: String]>()
  
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var widthConstraint: NSLayoutConstraint!
  @IBOutlet weak var avatar: UIButton!
  @IBOutlet weak var name: UILabel!
  
  override func loadView() {
    NSBundle.mainBundle().loadNibNamed("LeftMenuVC", owner:self, options:nil)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setUI()
    loadData()
    tableView?.reloadData()
  }
  
  func loadData() {
//    let path = NSBundle.mainBundle().pathForResource("LeftMenu", ofType: "plist")
//    dataArray = NSArray(contentsOfFile:path!)
    let menu1 = ["logo": "ic_shezhi",
                 "text": "设置"]
    let menu2 = ["logo": "ic_mianqiantai",
                 "text": "免前台"]
    let menu3 = ["logo": "ic_dingdan",
                 "text": "订单"]
    let menu4 = ["logo": "ic_zuji",
                 "text": "足迹"]
    dataArray.append(menu1)
    dataArray.append(menu2)
    dataArray.append(menu3)
    dataArray.append(menu4)
  }
  
  func setUI() {
    if let baseInfo = JSHStorage.baseInfo() {
      if baseInfo.avatarImage != nil {
        avatar .setImage(baseInfo.avatarImage, forState: UIControlState.Normal)
      }else {
        if let userid = JSHStorage.baseInfo().userid {
          let url = NSURL(string: kBaseURL)
          url?.URLByAppendingPathComponent("uploads/users/\(userid).jpg")
          avatar.sd_setImageWithURL(url, forState: UIControlState.Normal, placeholderImage: UIImage(named: "ic_camera_nor"), options: [SDWebImageOptions.LowPriority, SDWebImageOptions.RefreshCached, SDWebImageOptions.RetryFailed])
        }
      }
      
      name.text = baseInfo.username
    }
    
    tableView .registerClass(UITableViewCell.self, forCellReuseIdentifier: Identifier)
    widthConstraint.constant = UIScreen.mainScreen().bounds.width * 0.75
  }
  
  // MARK: - Table view data source
  func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.dataArray.count
  }
  
  func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return 60
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let dic = dataArray[indexPath.row]
    var cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier")
    if cell == nil {
      cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: Identifier)
    }
    cell?.backgroundColor = UIColor.clearColor()
    cell!.textLabel?.text = dic["text"]
    cell?.imageView?.image = UIImage(named:dic["logo"]!)
    cell?.textLabel?.textColor = UIColor.whiteColor()
    
    return cell!
  }
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    tableView .deselectRowAtIndexPath(indexPath, animated: true)
    if let buttonIndex = LeftButton(rawValue: indexPath.row) {
      switch buttonIndex {
      case .Setting:
        let vc = SettingTableViewController(style: UITableViewStyle.Grouped)
        if let navi = self.sideMenuViewController.contentViewController as? UINavigationController {
          self.sideMenuViewController.hideMenuViewController()
          navi.pushViewController(vc, animated: true)
        }
      case .InRoomCheckin:
        print(".InRoomCheckin")
        let vc = SkipCheckInSettingViewController()
        if let navi = self.sideMenuViewController.contentViewController as? UINavigationController {
          self.sideMenuViewController.hideMenuViewController()
          navi.pushViewController(vc, animated: true)
        }
      case .BookingOrder:
        let vc = OrderListTVC()
        if let navi = self.sideMenuViewController.contentViewController as? UINavigationController {
          self.sideMenuViewController.hideMenuViewController()
          navi.pushViewController(vc, animated: true)
        }
      case .HistoryOrder:
        let vc = OrderHistoryListTVC()
        if let navi = self.sideMenuViewController.contentViewController as? UINavigationController {
          self.sideMenuViewController.hideMenuViewController()
          navi.pushViewController(vc, animated: true)
        }
      }
    } else {
      print("在枚举LeftButton中未找到\(indexPath.row)")
    }
  }
  
}
