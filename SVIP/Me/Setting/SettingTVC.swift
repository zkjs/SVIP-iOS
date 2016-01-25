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
    ZKJSHTTPSessionManager.sharedInstance().logoutWithSuccess({ (task:NSURLSessionDataTask!, responsObject:AnyObject!) -> Void in
      if let data = responsObject {
        if let set = data["set"] {
          if set?.boolValue == true {
            // 清理系统缓存
            AccountManager.sharedInstance().clearAccountCache()
            
            // 登出环信
            EaseMob.sharedInstance().chatManager.removeAllConversationsWithDeleteMessages!(true, append2Chat: true)
            let error: AutoreleasingUnsafeMutablePointer<EMError?> = nil
            print("登出前环信:\(EaseMob.sharedInstance().chatManager.loginInfo)")
            EaseMob.sharedInstance().chatManager.logoffWithUnbindDeviceToken(true, error: error)
            print("登出后环信:\(EaseMob.sharedInstance().chatManager.loginInfo)")
            self.hideHUD()
            if error != nil {
              self.showHint(error.debugDescription)
            } else {
              NSNotificationCenter.defaultCenter().postNotificationName(KNOTIFICATION_LOGINCHANGE, object: NSNumber(bool: false))
            }

            let window =  UIApplication.sharedApplication().keyWindow
            window?.rootViewController = MainTBC()
          }
        }
      }
      self.hideHUD()
      }) { (task:NSURLSessionDataTask!, error:NSError!) -> Void in
        self.hideHUD()
        self.showAlertWithTitle(error.description, message: "")
    }
  }
  
  // MARK: - Table view delegate
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    tableView.deselectRowAtIndexPath(indexPath, animated: true)
    let feedBack = NSIndexPath(forRow: 0, inSection: 0)
    let aboutUs = NSIndexPath(forRow: 1, inSection: 0)
    let logout = NSIndexPath(forRow: 2, inSection: 0)
    switch indexPath {
    case feedBack:
      let vc = FeedbackViewController()
      self.navigationController?.pushViewController(vc, animated: true)
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
