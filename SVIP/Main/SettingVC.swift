//
//  SettingVC.swift
//  SVIP
//
//  Created by AlexBang on 15/12/7.
//  Copyright © 2015年 zkjinshi. All rights reserved.
//

import UIKit
enum PrivilegeButton: Int {
  case Setting = 2
  case AccountInformation = 0
  case OrderManagement = 1
  
}
class SettingVC: UIViewController,UITableViewDelegate,UITableViewDataSource {
  var myView:MainHeaderView!
  
  var dataArray = Array<[String: String]>()
  let Identifier = "SettingVCCell"
  @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
      tableView.scrollEnabled = false
      tableView.tableFooterView = UIView()
      tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: Identifier)
      loadData()
      tableView.reloadData()
      
    }
  
  func loadData() {
    let title1 = NSLocalizedString("账户信息", comment: "")
    let menu1 = ["text": title1]
    let title2 = NSLocalizedString("订单管理", comment: "")
    let menu2 = ["text": title2]
    
    let title4 = NSLocalizedString("设置", comment: "")
    let menu4 = ["text": title4]
    dataArray.append(menu1)
    dataArray.append(menu2)
    dataArray.append(menu4)
    //分割线往左移
    if tableView.respondsToSelector("setSeparatorInset:") {
      self.tableView.separatorInset = UIEdgeInsetsZero
    }
    if tableView.respondsToSelector("setLayoutMargins:") {
      self.tableView.layoutMargins = UIEdgeInsetsZero
    }
        
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
     navigationController?.navigationBarHidden = true
    
//    let topic = "1"
//    let extra = ["locdesc": "大糖糖",
//      "locid": "1",
//      "shopid": "120",
//      "userid": "55d67f785e6cb",
//      "username": "Hanton"]
//    let json = ZKJSTool.convertJSONStringFromDictionary(extra)
//    let data = json.dataUsingEncoding(NSUTF8StringEncoding)
//    let option = YBPublish2Option()
//    let alert = "XXX 到达 什么地方"
//    let badge = NSNumber(integer: 1)
//    let sound = "default"
//    let apnOption = YBApnOption(alert: alert, badge: badge, sound: sound, contentAvailable: nil, extra: extra)
//    option.apnOption = apnOption
//    
//    YunBaService.publish2(topic, data: data, option: option) { (success: Bool, error: NSError!) -> Void in
//      if success {
//        print("[result] publish2 data(\(json)) to topic(\(topic)) succeed")
//      } else {
//        print("[result] publish data(\(json)) to topic(\(topic)) failed: \(error), recovery suggestion: \(error.localizedRecoverySuggestion)")
//      }
//    }
  }
  override func viewWillDisappear(animated: Bool) {
    super.viewWillDisappear(animated)
    //navigationController?.navigationBarHidden = false
  }

 
  
  override func loadView() {
    NSBundle.mainBundle().loadNibNamed("SettingVC", owner:self, options:nil)
  }
  

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
  
   func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
    if cell.respondsToSelector(Selector("separatorInset:")) {
      cell.separatorInset = UIEdgeInsetsZero
    }
    if cell.respondsToSelector(Selector("layoutMargins:")) {
      cell.layoutMargins = UIEdgeInsetsZero
    }
  }
  
  // MARK: - Table view data source
  
   func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }
  
   func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.dataArray.count
  }
  
  
   func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return 48
  }
  func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 30
  }
  
  
   func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let dic = dataArray[indexPath.row]
    let cell = tableView.dequeueReusableCellWithIdentifier(Identifier, forIndexPath: indexPath)
    cell.textLabel?.text = dic["text"]
    cell.textLabel?.textColor = UIColor.lightGrayColor()
    return cell
  }
  
  
//  func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//    myView = NSBundle.mainBundle().loadNibNamed("MainHeaderView", owner: self, options: nil).first as! MainHeaderView
//    myView.userImageButton.addTarget(self, action: "setInfo:", forControlEvents: UIControlEvents.TouchUpInside)
//    setupMainViewUI(myView)
//    return myView
//  }
//  
//  func setInfo(sender:UIButton) {
//    let vc = SettingTableViewController(style: .Grouped)
//    navigationController?.pushViewController(vc, animated: true)
//  }
//  
//  func downloadImage(notification: NSNotification) {
//    let userInfo = notification.userInfo as! [String:AnyObject]
//    let imageData = userInfo["avtarImage"] as! NSData
//    let image = UIImage(data: imageData)
//    myView.userImageButton.setImage(image, forState: UIControlState.Normal)
//    self.tableView.reloadData()
//  }

  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    tableView .deselectRowAtIndexPath(indexPath, animated: true)
    if let buttonIndex = PrivilegeButton(rawValue: indexPath.row) {
      var vc = UIViewController()
      switch buttonIndex {
      case .AccountInformation:
        vc = PrivilegeVC()
      case .OrderManagement:
        vc = OrderListTVC()
      case .Setting:
        vc = SettingTableViewController(style: .Grouped)
      }
      if let navi = self.sideMenuViewController.contentViewController as? UINavigationController {
        self.sideMenuViewController.hideMenuViewController()
        navi.pushViewController(vc, animated: true)
      }
    } else {
      print("在枚举LeftButton中未找到\(indexPath.row)")
    }
  }
  func setupMainViewUI(myView:MainHeaderView) {
    let image = JSHStorage.baseInfo().avatarImage
    myView.userImageButton.setImage(image, forState: .Normal)
    myView.userNameLabel.text = JSHStorage.baseInfo().username
//    if activate == true {
//      myView.gradeLabel.text = "VIP(已激活)"
//    }
//    
//    if distance == nil {
//      return
//    }else {
//      //定位客户位子 算出距离目的地酒店的距离
//      let formatter = MKDistanceFormatter()
//      formatter.units = .Metric
//      let distanceString = formatter.stringFromDistance(distance)
//      //      myView.orderStatusLabel.text = "有订单 距离\(String(format: "%.2f", distance/1000))km"
//      myView.orderStatusLabel.text = "有订单 距离\(distanceString)"
//      myView.userNameLabel.text = JSHStorage.baseInfo().username
//    }
  }

  
  
  
}


    




