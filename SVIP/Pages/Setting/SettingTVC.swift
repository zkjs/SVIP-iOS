//
//  SettingTVC.swift
//  SVIP
//
//  Created by  on 12/14/15.
//  Copyright © 2015 zkjinshi. All rights reserved.
//

import UIKit

class SettingTVC: UITableViewController {

  override func viewDidLoad() {
    super.viewDidLoad()
    
    title = "设置"
    
    tableView.tableFooterView = UIView()
  }
  
  // MARK: - Private
  
  func logout() {
    showHUDInView(view, withLoading: "")
    HttpService.sharedInstance.deleteToken { (json, error) -> () in
      //退出登录，主动把token消除
      TokenPayload.sharedInstance.clearCacheTokenPayload()
      self.hideHUD()
      
      // 清理系统缓存
      AccountManager.sharedInstance().clearAccountCache()
      //登出友盟统计
      MobClick.profileSignOff()
      NSNotificationCenter.defaultCenter().postNotificationName(KNOTIFICATION_LOGINCHANGE, object: NSNumber(bool: false))
    }
    YunbaSubscribeService.sharedInstance.unsubscribeAllTopics()
    
    let window =  UIApplication.sharedApplication().keyWindow
    window?.rootViewController = BaseNC(rootViewController: LoginVC())
  }
  
  // MARK: - Table view delegate
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    tableView.deselectRowAtIndexPath(indexPath, animated: true)
    let aboutUs = NSIndexPath(forRow: 0, inSection: 0)
    let logout = NSIndexPath(forRow: 1, inSection: 0)
    switch indexPath {
    case aboutUs:
      let vc = WebViewVC()
      vc.url = "http://www.zkjinshi.com/about_us/"
      self.navigationController?.pushViewController(vc, animated: true)
    case logout:
      let alertController = UIAlertController(title: "确定要退出登录吗？", message: "", preferredStyle: .ActionSheet)
      let logoutAction = UIAlertAction(title: "退出登录", style:.Destructive, handler: { (action: UIAlertAction) -> Void in
        self.logout()
      })
      alertController.addAction(logoutAction)
      let cancelAction = UIAlertAction(title: "取消", style: .Cancel, handler: nil)
      alertController.addAction(cancelAction)
      presentViewController(alertController, animated: true, completion: nil)
    default:
      break
    }
  }

}
