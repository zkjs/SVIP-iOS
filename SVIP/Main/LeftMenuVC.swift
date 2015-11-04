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
  var dataArray = Array<[String: String]>()
  
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var avatar: UIButton!
  @IBOutlet weak var name: UILabel!
  
  override func loadView() {
    NSBundle.mainBundle().loadNibNamed("LeftMenuVC", owner:self, options:nil)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setUI()
    loadData()
    tableView.reloadData()
  }
  
  func loadData() {
    let title1 = NSLocalizedString("SETTINGS", comment: "")
    let menu1 = ["logo": "ic_shezhi",
                 "text": title1]
    let title2 = NSLocalizedString("IN_ROOM_CHECK_IN", comment: "")
    let menu2 = ["logo": "ic_mianqiantai",
                 "text": title2]
    let title3 = NSLocalizedString("行程", comment: "")
    let menu3 = ["logo": "ic_dingdan",
                 "text": title3]
    let title4 = NSLocalizedString("ORDER_HISTORY", comment: "")
    let menu4 = ["logo": "ic_zuji",
                 "text": title4]
    dataArray.append(menu1)
    dataArray.append(menu2)
    dataArray.append(menu3)
    dataArray.append(menu4)
  }
  
  func setUI() {
    avatar.imageView?.contentMode = UIViewContentMode.ScaleAspectFit
    if let baseInfo = JSHStorage.baseInfo() {
      if baseInfo.avatarImage != nil {
        avatar.setImage(baseInfo.avatarImage, forState: UIControlState.Normal)
      }else {
        if let userid = JSHStorage.baseInfo().userid {
          var url = NSURL(string: kBaseURL)
          url = url?.URLByAppendingPathComponent("uploads/users/\(userid).jpg")
          avatar.sd_setImageWithURL(url, forState: UIControlState.Normal, placeholderImage: UIImage(named: "ic_camera_nor"), options: [SDWebImageOptions.LowPriority, SDWebImageOptions.RefreshCached, SDWebImageOptions.RetryFailed])
        }
      }
      
      name.text = baseInfo.username
    }
    
    tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: Identifier)
  }
  
  // MARK: - Button Action
  
  @IBAction func tapAvatarImage(sender: AnyObject) {
    let vc = SettingTableViewController(style: .Grouped)
    if let navi = self.sideMenuViewController.contentViewController as? UINavigationController {
      self.sideMenuViewController.hideMenuViewController()
      navi.pushViewController(vc, animated: true)
    }
  }
  
  // MARK: - Table view data source
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.dataArray.count
  }
  
  func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return 60
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let dic = dataArray[indexPath.row]
    let cell = tableView.dequeueReusableCellWithIdentifier(Identifier, forIndexPath: indexPath)
    cell.backgroundColor = UIColor.clearColor()
    cell.textLabel?.text = dic["text"]
    cell.imageView?.image = UIImage(named:dic["logo"]!)
    cell.textLabel?.textColor = UIColor.whiteColor()
    return cell
  }
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    tableView .deselectRowAtIndexPath(indexPath, animated: true)
    if let buttonIndex = LeftButton(rawValue: indexPath.row) {
      var vc = UIViewController()
      switch buttonIndex {
      case .Setting:
        vc = SettingTableViewController(style: .Grouped)
      case .InRoomCheckin:
        print(".InRoomCheckin")
        vc = SkipCheckInSettingViewController()
      case .BookingOrder:
        vc = OrderListTVC()
      case .HistoryOrder:
        vc = OrderHistoryListTVC()
      }
      if let navi = self.sideMenuViewController.contentViewController as? UINavigationController {
        self.sideMenuViewController.hideMenuViewController()
        navi.pushViewController(vc, animated: true)
      }
    } else {
      print("在枚举LeftButton中未找到\(indexPath.row)")
    }
  }
  
}
