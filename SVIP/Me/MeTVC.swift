//
//  MeTVC.swift
//  SVIP
//
//  Created by  on 12/14/15.
//  Copyright © 2015 zkjinshi. All rights reserved.
//

import UIKit

class MeTVC: UITableViewController {
  
  @IBOutlet weak var userImage: UIImageView!
  @IBOutlet weak var loginLabel: UILabel!

  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    tableView.tableFooterView = UIView()
    automaticallyAdjustsScrollViewInsets = false
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    
    navigationController?.navigationBarHidden = true
    setupUI()
    #if DEBUG
      sendTestPushNotification()
    #endif
  }
  
  private func sendTestPushNotification() {
    let shopID = "110"
    let locid = "30"
    let locdesc = "中科金石"
    let userID = "5603d8d417392"
    var userName = "不要紧张"
    let sex = "1"
    let topic = locid
    var orderDict = [String: AnyObject]()
    if let order = StorageManager.sharedInstance().lastOrder() {
      orderDict["shopid"] = order.shopid
      orderDict["fullname"] = order.fullname
      orderDict["guest"] = order.guest
      orderDict["rooms"] = order.rooms
      orderDict["room_type"] = order.room_type
      orderDict["room_rate"] = order.room_rate
      orderDict["arrival_date"] = order.arrival_date
      orderDict["departure_date"] = order.departure_date
      orderDict["dayInt"] = order.dayInt
      orderDict["reservation_no"] = order.reservation_no
      orderDict["created"] = order.created
      orderDict["status"] = order.status
    }
    var extra = [String: AnyObject]()
    extra["locdesc"] = locdesc
    extra["locid"] = locid
    extra["shopid"] = shopID
    extra["userid"] = userID
    extra["username"] = userName
    extra["sex"] = sex
    extra["order"] = orderDict
    let json = ZKJSTool.convertJSONStringFromDictionary(extra)
    let data = json.dataUsingEncoding(NSUTF8StringEncoding)
    let option = YBPublish2Option()
    var gender = "先生"
    if sex == "0" {
      gender = "女士"
    }
    if userName.isEmpty {
      userName = "游客"
    }
    let alert = "\(userName)\(gender) 到达 \(locdesc)"
    let badge = NSNumber(integer: 1)
    let sound = "default"
//    var avatarBase64 = ""
//    if let avatar = AccountManager.sharedInstance().avatarImage {
//      var avatarData = UIImageJPEGRepresentation(avatar, 1.0)!
//      var i = 0
//      while avatarData.length / 1024 > 30 {
//        let persent = CGFloat(100 - i++) / 100.0
//        avatarData = UIImageJPEGRepresentation(avatar, persent)!
//      }
//      avatarBase64 = avatarData.base64EncodedStringWithOptions(.Encoding64CharacterLineLength)
//    }
//    let avatarURL = AccountManager.sharedInstance().avatarURL
    let apnDict = ["aps": ["alert": ["body": alert, "title": "到店通知"], "badge": badge, "sound": sound, "category": "arrivalInfo"], "extra": extra]
    print(apnDict)
    let apnOption = YBApnOption(apnDict: apnDict as [NSObject : AnyObject])
    option.apnOption = apnOption
    YunBaService.publish2(topic, data: data, option: option) { (success: Bool, error: NSError!) -> Void in
      if success {
        print("[result] publish2 data(\(json)) to topic(\(topic)) succeed")
      } else {
        print("[result] publish data(\(json)) to topic(\(topic)) failed: \(error), recovery suggestion: \(error.localizedRecoverySuggestion)")
      }
    }
  }
  
  override func viewWillDisappear(animated: Bool) {
    super.viewWillDisappear(animated)
    
    navigationController?.navigationBarHidden = false
  }
  
  func setupUI() {
    if AccountManager.sharedInstance().isLogin() == true {
      loginLabel.hidden = true
      userImage.image = AccountManager.sharedInstance().avatarImage
    }
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = super.tableView(tableView, cellForRowAtIndexPath: indexPath)
    cell.accessoryView = UIImageView(image: UIImage(named: "ic_right_orange"))
    return cell
  }
  
  // MARK: - Table view delegate
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    tableView.deselectRowAtIndexPath(indexPath, animated: true)
    
    if AccountManager.sharedInstance().isLogin() == false {
      let nc = BaseNC(rootViewController: LoginVC())
      presentViewController(nc, animated: true, completion: nil)
      return
    }
    
    let accountIndexPath = NSIndexPath(forRow: 0, inSection: 0)
    let orderIndexPath = NSIndexPath(forRow: 1, inSection: 0)
    let settingIndexPath = NSIndexPath(forRow: 2, inSection: 0)
    
    switch indexPath {
    case accountIndexPath:
      let storyboard = UIStoryboard(name: "AccountTVC", bundle: nil)
      let vc = storyboard.instantiateViewControllerWithIdentifier("AccountTVC") as! AccountTVC
      vc.hidesBottomBarWhenPushed = true
      navigationController?.pushViewController(vc, animated: true)
    case orderIndexPath:
      let vc = OrderListTVC()
      vc.hidesBottomBarWhenPushed = true
      navigationController?.pushViewController(vc, animated: true)
    case settingIndexPath:
      let storyboard = UIStoryboard(name: "SettingTVC", bundle: nil)
      let vc = storyboard.instantiateViewControllerWithIdentifier("SettingTVC") as! SettingTVC
      vc.hidesBottomBarWhenPushed = true
      navigationController?.pushViewController(vc, animated: true)
    default:
      print("还没实现呢")
    }
  }
  
}
