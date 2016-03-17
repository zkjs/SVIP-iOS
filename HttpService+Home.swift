//
//  HttpService+Home.swift
//  SVIP
//
//  Created by Qin Yejun on 3/15/16.
//  Copyright © 2016 zkjinshi. All rights reserved.
//

import Foundation

extension HttpService {
  
  /**
   *  首页图片
   */
  func getHomePictures(completionHandler: ([String]?,NSError?)->Void) {
    let urlString = ResourcePath.HomePicture.description.fullUrl
    
    get(urlString, parameters: nil,tokenRequired: false) { (json, error) -> Void in
      if let error = error {
        print(error)
        completionHandler(nil,error)
      } else {
        var pictures = [String]()
        if let data = json?["data"].array where data.count > 0 {
          for d in data {
            if let url = d["url"].string {
              pictures.append(url)
            }
          }
        }
        if pictures.count > 0 {
          StorageManager.sharedInstance().saveHomeImages(pictures)
        }
        completionHandler(pictures,nil)
      }
    }
  }
  
  /**
  *  首页服务介绍
  */
  func getPrivilegeIntro(completionHandler: (PrivilegeModel?,NSError?)->Void ) {
    let urlString = ResourcePath.HomePrivilegeIntro.description.fullUrl
    
    get(urlString, parameters: nil,tokenRequired: false) { (json, error) -> Void in
      if let error = error {
        print(error)
        completionHandler(nil,error)
      } else {
        if let data = json?["data"] {
          let intro = PrivilegeModel(json: data)
          completionHandler(intro,nil)
        } else {
          completionHandler(nil,error)
        }
      }
    }
    
  }
  
  /**
   *  首页推荐
   */
  func getHomeRecom(city:String, completionHandler: ([PushInfoModel]?,NSError?)->Void) {
    guard let city = city.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet()) else {
      return
    }
    let urlString = ResourcePath.HomeRecom(city: city).description.fullUrl

    get(urlString, parameters: nil,tokenRequired: false) { (json, error) -> Void in
      if let error = error {
        print(error)
        completionHandler(nil,error)
      } else {
        var result = [PushInfoModel]()
        if let data = json?["data"].array where data.count > 0 {
          for d in data {
            result.append(PushInfoModel(json: d))
          }
        }
        completionHandler(result,nil)
      }
    }
  }
  
  /**
   * 登录后获取首页详情-订单-特权
   */
  func getHomeAllMessages(city:String, completionHandler: ([PrivilegeModel]?,[PushInfoModel]?,[PushInfoModel]?,NSError?)->Void) {
    guard let city = city.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet()) else {
      return
    }
    let urlString = ResourcePath.HomeAllMessages(city: city).description.fullUrl
    
    get(urlString, parameters: nil) { (json, error) -> Void in
      if let error = error {
        print(error)
        completionHandler(nil,nil,nil,error)
      } else {
        var privileges = [PrivilegeModel]()
        var homeOrder = [PushInfoModel]()
        var recommendShops = [PushInfoModel]()
        if let data = json?["data"]["homePrivilegeModels"].array where data.count > 0 {
          for d in data {
            privileges.append(PrivilegeModel(json: d))
          }
        }
        if let data = json?["data"]["recommendShops"].array where data.count > 0 {
          for d in data {
            recommendShops.append(PushInfoModel(json: d))
          }
        }
        if let data = json?["data"]["homeOrderModel"] {
          homeOrder.append(PushInfoModel(json: data))
        }
        completionHandler(privileges.count > 0 ? privileges : nil,
          homeOrder.count > 0 ? homeOrder : nil,
          recommendShops.count > 0 ? recommendShops : nil,
          nil)
      }
    }
  }

  
}