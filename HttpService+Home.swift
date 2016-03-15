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

  
}