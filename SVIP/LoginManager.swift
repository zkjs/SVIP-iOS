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

class LoginManager: NSObject {
  
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
//    let nc = BaseNC(rootViewController: MainTBC())
//    appWindow.rootViewController = nc
    appWindow.rootViewController = MainTBC()
  }
  
//  func signup(phone: String?, openID: String?, success:() ->()) {
//    var idstr :String?
//    if phone == nil && openID != nil {
//      idstr = openID
//    }
//    if phone != nil && openID == nil {
//      idstr = phone
//    }
//    if let str = idstr {
//      ZKJSHTTPSessionManager.sharedInstance().verifyIsRegisteredWithID(str, success: { (task: NSURLSessionDataTask!, responseObject: AnyObject!) -> Void in
//        if let dic = responseObject as? NSDictionary {
//          let newRegister = !dic["set"]!.boolValue!
//          if newRegister {//新注册
//            ZKJSHTTPSessionManager.sharedInstance().userSignUpWithPhone(phone, openID: openID, success: { (task: NSURLSessionDataTask!, responseObject :AnyObject!) -> Void in
//              if let dic = responseObject as? [NSObject : AnyObject] {
//                let set = dic["set"]!.boolValue!
//                if set {//注册成功
//                  //回调
//                  success()
//                  //save account data
//                  JSHAccountManager.sharedJSHAccountManager().saveAccountWithDic(dic)
//                  self.easeMobAutoLogin()
//                  //编辑个人信息
//                  print("here goes to edit info ")
//                  let nv = BaseNC(rootViewController: InfoEditViewController())
//                  nv.navigationBar.tintColor = UIColor.whiteColor()
//                  nv.navigationBar.setBackgroundImage(UIImage(named: "avator"), forBarMetrics: UIBarMetrics.Default)
//                  nv.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.whiteColor()]
//                  self.appWindow.rootViewController = nv
//                }
//              }
//              }, failure: { (task: NSURLSessionDataTask!, error: NSError!) -> Void in
//                
//            })
//          } else {//已注册
//            //save account data
//            JSHAccountManager.sharedJSHAccountManager().saveAccountWithDic(dic as [NSObject : AnyObject])
//            //获取用户信息
//            LoginManager.sharedInstance().fetchUserInfo({ () -> () in
//              LoginManager.sharedInstance().showResideMenu(haspushed: nil)
//            })
//          }
//        }
//        }, failure: { (task: NSURLSessionDataTask!, error: NSError!) -> Void in
//      })
//    }
//  }
  
}
