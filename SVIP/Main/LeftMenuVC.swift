//
//  LeftMenuVC.swift
//  SVIP
//
//  Created by dai.fengyi on 15/8/7.
//  Copyright (c) 2015年 zkjinshi. All rights reserved.
//

import UIKit

enum LeftButton: Int {
  case Main = 0
  case Setting
  case InRoomCheckin
  case BookingOrder
  case HistoryOrder
}

let LeftMenuProportion = 0.75

class LeftMenuVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
  let Identifier = "LeftMenuCell"
  var dataArray: NSArray?
  
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
    let path = NSBundle.mainBundle().pathForResource("LeftMenu", ofType: "plist")
    dataArray = NSArray(contentsOfFile:path!)
  }

  func setUI() {
    if let baseInfo = JSHStorage .baseInfo() {
      if baseInfo.avatarImage != nil {
        avatar .setImage(baseInfo.avatarImage, forState: UIControlState.Normal)
      }else {
        if let avatarStr = baseInfo.avatarStr {
            let urlStr = kBaseURL.stringByAppendingPathComponent(baseInfo.avatarStr)
            let url = NSURL(string: urlStr)
            avatar.sd_setImageWithURL(url, forState: UIControlState.Normal, placeholderImage: UIImage(named: "ic_camera_nor"), options: SDWebImageOptions.LowPriority | SDWebImageOptions.RefreshCached | SDWebImageOptions.RetryFailed)
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
    if self.dataArray == nil {
      return 0
    }else {
      return self.dataArray!.count
    }
  }
  
  func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return 60
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    var cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier") as? UITableViewCell
    if cell == nil {
      cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: Identifier)
    }
    // Configure the cell...
    cell?.backgroundColor = UIColor.clearColor()
    if let dic = dataArray![indexPath.row] as? Dictionary<String, String> {
      cell!.textLabel?.text = dic["text"]
      cell?.imageView?.image = UIImage(named:dic["logo"]!)
      cell?.textLabel?.textColor = UIColor.whiteColor()
    }
    
    return cell!
  }
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    tableView .deselectRowAtIndexPath(indexPath, animated: true)
//    let vc = BookVC()
//    vc.shopid = (dataArray[indexPath.row] as? Hotel)!.shopid
//    if let navi = self.sideMenuViewController.contentViewController as? UINavigationController {
//      self.sideMenuViewController.hideMenuViewController()
//      navi.pushViewController(vc, animated: true)
//    }
    // Hanton
    if let buttonIndex = LeftButton(rawValue: indexPath.row) {
      switch buttonIndex {
      case .Main:
        println(".Main")
      case .Setting:
        let vc = SettingTableViewController(style: UITableViewStyle.Grouped)
        if let navi = self.sideMenuViewController.contentViewController as? UINavigationController {
          self.sideMenuViewController.hideMenuViewController()
          navi.pushViewController(vc, animated: true)
        }
      case .InRoomCheckin:
        println(".InRoomCheckin")
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
        let vc = OrderListTVC()
        if let navi = self.sideMenuViewController.contentViewController as? UINavigationController {
          self.sideMenuViewController.hideMenuViewController()
          navi.pushViewController(vc, animated: true)
        }
      default:
        break
      }
    } else {
      println("在枚举LeftButton中未找到\(indexPath.row)")
    }
//    switch indexPath.row {
//    case 1:
//      let vc = SettingTableViewController(style: UITableViewStyle.Grouped)
//      if let navi = self.sideMenuViewController.contentViewController as? UINavigationController {
//        self.sideMenuViewController.hideMenuViewController()
//        navi.pushViewController(vc, animated: true)
//      }
//    default:
//      break;
//    }


  }


}
