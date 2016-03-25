//
//  HomeViewModel.swift
//  SVIP
//
//  Created by Qin Yejun on 3/16/16.
//  Copyright © 2016 zkjinshi. All rights reserved.
//

import Foundation

class HomeViewModel {
  // 获取数据失败
  private(set) var fetchDataError = false
  // 获取图片失败
  private(set) var fetchImageError = false
  // 特权
  var privilegeArray = [PrivilegeModel]()
  // 推荐
  var recommendArray = [PushInfoModel]()
  // 订单
  var orderArray = [PushInfoModel]()

  private var homeImgUrl: String?
  // 当前首页大图
  var imgUrl :String? {
    if let homeImgUrl = homeImgUrl {
      return homeImgUrl
    }
    if let imageArray = StorageManager.sharedInstance().homeImage() { // 已有缓存
      print("cached \(imageArray)")
      let randomIndex = Int(arc4random_uniform(UInt32(imageArray.count)))
      homeImgUrl = imageArray[randomIndex]
      return homeImgUrl
    }
    return nil
  }
  
  // 是否已经激活
  var activate:Bool {
    return AccountManager.sharedInstance().userstatus == 1
  }
  
  var city = "长沙"
  
  init(city:String) {
    self.city = city
  }

  /**
   * 获取登陆用户所有消息
   */
  private func getAllMessages(city:String, completionHandler:((NSError?)->Void)?) {
    HttpService.sharedInstance.getHomeAllMessages(city) { (privileges, orders, recom, error) -> Void in
      self.fetchDataError = (error != nil)
      if let error = error {
        completionHandler?(error)
      } else {
        if let orders = orders where orders.count > 0 {
          self.orderArray = orders
        }
        if let privileges = privileges where privileges.count > 0{
          self.privilegeArray = privileges
        }
        if let recom = recom where recom.count > 0 {
          self.recommendArray = recom
        }
      }
      completionHandler?(nil)
    }
  }
  
  /**
   * 获取未登陆用户特权消息
   */
  private func getPrivilegeInfo(completionHandler:((NSError?)->Void)?) {
    /*HttpService.sharedInstance.getPrivilegeIntro { (privilege, error) -> Void in
      self.fetchDataError = (error != nil)
      if let privilege = privilege {
        self.privilegeArray = [privilege]
        completionHandler?(nil)
      } else {
        print(error)
        completionHandler?(error)
      }
    }*/
  }
  
  /**
   * 获取登陆用户推荐消息
   */
  private func getRecomData(completionHandler:((NSError?)->Void)?) {
    HttpService.sharedInstance.getHomeRecom(self.city) { (results, error) -> Void in
      self.fetchDataError = (error != nil)
      if let results = results {
        self.recommendArray = results
        completionHandler?(nil)
      } else {
        completionHandler?(error)
      }
    }
  }
  
  func loadImageData(completionHandler:((NSError?)->Void)?) {
    if let imageArray = StorageManager.sharedInstance().homeImage() {
      // 已有缓存
      print("cached \(imageArray)")
    } else {
      // 未有缓冲，从服务器上取
      HttpService.sharedInstance.getHomePictures { (imgs, error) -> Void in
        self.fetchImageError = (error != nil)
        if let imgs = imgs {
          StorageManager.sharedInstance().saveHomeImages(imgs)
          completionHandler?(nil)
        }
      }
    }
    
  }
  
  func refreshData(completionHandler:((NSError?)->Void)?) {
    if TokenPayload.sharedInstance.isLogin {
      getAllMessages(self.city, completionHandler: completionHandler)
    } else {
      getPrivilegeInfo(completionHandler)
      getRecomData(completionHandler)
    }
  }
  
  
  
}