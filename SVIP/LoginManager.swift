//
//  LoginManager.swift
//  SVIP
//
//  Created by dai.fengyi on 15/8/7.
//  Copyright (c) 2015年 zkjinshi. All rights reserved.
//
/*
                      进场动画
                  动画结束判断本地已存在
  本地已登陆过                         本地未登陆过
  登录获取用户信息                      跳注册页面
  获取信息写本地                 手机注册        微信授权登录注册
（读取后台用户信息）              判断是否为老用户GET user/getuser
  跳主界面                        资料填写         验证手机
                                  （读取后台用户信息）
                                      跳主界面
*/
/*
接口说明：
1. 不管什么情况，先判断用户手机和微信登录  GET user/getuser
2. 新用户：新用户注册        POST user/reg
2. 老用户：直接登录
*/
import UIKit

class LoginManager: NSObject, RESideMenuDelegate {
  var appWindow: UIWindow!
  class func sharedInstance() -> LoginManager {
    struct Singleton {
      static let instance = LoginManager()
    }
    return Singleton.instance
  }
  
  //进场动画
  func showAnimation() {
     appWindow.rootViewController = JSHAnimationVC()
  }
  //动画结束
  func afterAnimation() {
    if JSHAccountManager.sharedJSHAccountManager().userid != nil {//已注册
      fetchUserInfo({ () -> () in
        ZKJSTool.hideHUD()
        self.showResideMenu(haspushed: nil)
      })
      
    }else {//未注册
      showRegister()
    }
  }
  
  func showResideMenu(haspushed pushedVC: UIViewController?) {
    let nc = UINavigationController(rootViewController: MainVC())
    nc.navigationBar.tintColor = UIColor.blackColor()
    if pushedVC != nil {
      nc.pushViewController(pushedVC!, animated: false)
    }
//    nc.navigationBarHidden = true
    let menu = JSSideMenu(contentViewController: nc, leftMenuViewController: LeftMenuVC(), rightMenuViewController: MessageCenterTVC())
    menu.delegate = self
    menu.contentViewScaleValue = 1
    menu.bouncesHorizontally = false
    menu.contentViewInPortraitOffsetCenterX = appWindow.bounds.size.width * (0.75 - 0.5)
    appWindow.rootViewController = menu

  }
  
  func showRegister() {
    appWindow.rootViewController = JSHHotelRegisterVC()
  }
  
  //获取用户信息保存本地
  func fetchUserInfo(afterFetch: () -> ()) {
    let userId = JSHAccountManager.sharedJSHAccountManager().userid
    let token = JSHAccountManager.sharedJSHAccountManager().token
    let oldImage = JSHStorage.baseInfo().avatarImage//单独将本地头像提出来，为了从服务器取头像数据滞后于显示的问题
    ZKJSHTTPSessionManager.sharedInstance().getUserInfo(userId, token: token, success: { (task: NSURLSessionDataTask!, responseObject: AnyObject!) -> Void in
      if let dic = responseObject as? [NSObject : AnyObject] {
        let baseInfo = JSHBaseInfo(dic: dic)
        if baseInfo.avatarImage == nil {
          baseInfo.avatarImage = oldImage
        }
        //本地存储
        JSHStorage.saveBaseInfo(baseInfo)
        afterFetch()
      }
      }) { (task: NSURLSessionDataTask!, error: NSError!) -> Void in
      println("\(error.description)")
    }
  }
  
  /*
  [[ZKJSHTTPSessionManager sharedInstance] userSignUpWithPhone:_phoneField.text openID:nil success:^(NSURLSessionDataTask *task, id responseObject) {
  if ([[responseObject objectForKey:@"set"] boolValue]) {
  //save account data
  [[JSHAccountManager sharedJSHAccountManager] saveAccountWithDic:responseObject];
  //获取用户信息
  [[LoginManager sharedInstance] fetchUserInfo:^{
  //jump
  [[LoginManager sharedInstance] showResideMenuWithHaspushed:nil];
  }];
  }
  } failure:^(NSURLSessionDataTask *task, NSError *error) {
  [ZKJSTool showMsg:@"请输入受邀请的手机号码"];
  }];
  */
  func signup(phone: String?, openID: String?, success:() ->()) {
    var idstr :String?
    if phone == nil && openID != nil {
      idstr = openID
    }
    if phone != nil && openID == nil {
      idstr = phone
    }
    if let str = idstr {
      ZKJSHTTPSessionManager.sharedInstance().verifyIsRegisteredWithID(str, success: { (task: NSURLSessionDataTask!, responseObject: AnyObject!) -> Void in
        if let dic = responseObject as? NSDictionary {
          let newRegister = !dic["set"]!.boolValue!
          if newRegister {//新注册
            ZKJSHTTPSessionManager.sharedInstance().userSignUpWithPhone(phone, openID: openID, success: { (task: NSURLSessionDataTask!, responseObject :AnyObject!) -> Void in
              if let dic = responseObject as? [NSObject : AnyObject] {
                let set = dic["set"]!.boolValue!
                if set {//注册成功
                  //回调
                  success()
                  //save account data
                  JSHAccountManager.sharedJSHAccountManager().saveAccountWithDic(dic)
                  //编辑个人信息
                  println("here goes to edit info ")
                  self.appWindow.rootViewController = UINavigationController(rootViewController: InfoEditViewController())
                  
                }
              }
              }, failure: { (task: NSURLSessionDataTask!, error: NSError!) -> Void in
                
            })
          }else {//已注册
//            ZKJSHTTPSessionManager.sharedInstance().userSignUpWithPhone(phone, openID: openID, success: { (task: NSURLSessionDataTask!, responseObject :AnyObject!) -> Void in
//              if let dic = responseObject as? [NSObject : AnyObject] {
//                let set = dic["set"]!.boolValue!
//                if set {//注册成功
//                  //save account data
//                  JSHAccountManager.sharedJSHAccountManager().saveAccountWithDic(dic)
//                  //获取用户信息
//                  LoginManager.sharedInstance().fetchUserInfo({ () -> () in
//                    LoginManager.sharedInstance().showResideMenu(haspushed: nil)
//                  })
//                }
//              }
//              }, failure: { (task: NSURLSessionDataTask!, error: NSError!) -> Void in
//                
//            })
            //save account data
            JSHAccountManager.sharedJSHAccountManager().saveAccountWithDic(dic as [NSObject : AnyObject])
            //获取用户信息
            LoginManager.sharedInstance().fetchUserInfo({ () -> () in
              LoginManager.sharedInstance().showResideMenu(haspushed: nil)
            })
          }
          
        }
        }, failure: { (task: NSURLSessionDataTask!, error: NSError!) -> Void in
      })
    }
  }
  
  // MARK: - RESideMenuDelegate
  func sideMenu(sideMenu: RESideMenu!, willShowMenuViewController menuViewController: UIViewController!) {
    if let rightVC = menuViewController as? MessageCenterTVC {
      rightVC.tableView.reloadData()
    }
  }
  
  
}
