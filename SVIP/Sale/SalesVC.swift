//
//  SalesVC.swift
//  SVIP
//
//  Created by AlexBang on 15/12/7.
//  Copyright © 2015年 zkjinshi. All rights reserved.
//

import UIKit

class SalesVC: XLSegmentedPagerTabStripViewController {
  
  override func loadView() {
    NSBundle.mainBundle().loadNibNamed("SalesVC", owner:self, options:nil)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupView()
  }
  
  private func setupView() {
    navigationController?.navigationBar.translucent = false
    
    if AccountManager.sharedInstance().isLogin() == false {
      let rightBarButtonItem = UIBarButtonItem(title: "请登录", style: .Plain, target: self, action: "login:")
      rightBarButtonItem.tintColor = UIColor.ZKJS_mainColor()
      super.navigationItem.rightBarButtonItem = rightBarButtonItem
    } else {
      let rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "ic_tianjia"), style: UIBarButtonItemStyle.Plain, target: self, action: "add:")
      rightBarButtonItem.tintColor = UIColor.ZKJS_mainColor()
      super.navigationItem.rightBarButtonItem = rightBarButtonItem
    }
    
    segmentedControl.frame.size = CGSizeMake(150.0, 30.0)
    
    containerView.scrollEnabled = false
  }
  
  func login(sender: AnyObject) {
    let nc = BaseNC(rootViewController: LoginVC())
    presentViewController(nc, animated: true, completion: nil)
  }
  
  func add(sender: UIBarButtonItem) {
    let alertController = UIAlertController(title: "添加联系人", message: "", preferredStyle: UIAlertControllerStyle.Alert)
    let checkAction = UIAlertAction(title: "查询", style: .Default) { (_) in
      let phoneTextField = alertController.textFields![0] as UITextField
      guard let phone = phoneTextField.text else { return }
      phoneTextField.resignFirstResponder()
      self.showHUDInView(self.view, withLoading: "正在查找...")
      ZKJSJavaHTTPSessionManager.sharedInstance().checkSalesWithPhone(phone, success: { (task: NSURLSessionDataTask!, responseObject: AnyObject!) -> Void in
        self.hideHUD()
//        print(responseObject)
        if let array = responseObject as? [[String: AnyObject]] {
          if let data = array.first {
            if let userid = data["userId"] as? String {
              let vc = SalesDetailVC()
              vc.hidesBottomBarWhenPushed = true
              vc.salesid = userid
              self.navigationController?.pushViewController(vc, animated: true)
            }
          } else {
          self.showHint("此销售人员不存在")
          }
        }
        }) { (task: NSURLSessionDataTask!, error: NSError!) -> Void in
          self.hideHUD()
      }
    }
    checkAction.enabled = false
    let cancelAction = UIAlertAction(title: "取消", style: .Cancel) { (_) in
      self.view.endEditing(true)
    }
    alertController.addTextFieldWithConfigurationHandler { (textField) in
      textField.placeholder = "请输入销售人员的手机号码"
      textField.keyboardType = UIKeyboardType.NumberPad
      NSNotificationCenter.defaultCenter().addObserverForName(UITextFieldTextDidChangeNotification, object: textField, queue: NSOperationQueue.mainQueue()) { (notification) in
        checkAction.enabled = (textField.text != "")
      }
    }
    alertController.addAction(checkAction)
    alertController.addAction(cancelAction)
    presentViewController(alertController, animated: true, completion: nil)
  }
  
  // XLSegmentedPagerTabStripViewController Delegate
  
  override func childViewControllersForPagerTabStripViewController(pagerTabStripViewController: XLPagerTabStripViewController!) -> [AnyObject]! {
    let child1 = ConversationListController()
    let child2 = MailListTVC()
    return [child1, child2]
  }
  
}







