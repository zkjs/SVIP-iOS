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
  
  // MARK: - Table view delegate
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    tableView.deselectRowAtIndexPath(indexPath, animated: true)
    switch indexPath {
    case NSIndexPath(forRow: 0, inSection: 0):
      self.navigationController?.pushViewController(AboutUsViewController(), animated: true)
    case NSIndexPath(forRow: 1, inSection: 0):
      let alertController = UIAlertController(title: "确定要登出吗？", message: "", preferredStyle: .ActionSheet)
      
      let logoutAction = UIAlertAction(title: "登出", style:.Destructive, handler: { (action: UIAlertAction) -> Void in
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
  
  func logout() {
    
    ZKJSHTTPSessionManager.sharedInstance().logoutWithSuccess({ (task:NSURLSessionDataTask!, responsObject:AnyObject!) -> Void in
      if let data = responsObject {
        if let set = data["set"] {
          if set?.boolValue == true {
            let window =  UIApplication.sharedApplication().keyWindow
            window?.rootViewController = LoginVC()
            
          }
        }
      }
      }) { (task:NSURLSessionDataTask!, error:NSError!) -> Void in
    }
  }

}
