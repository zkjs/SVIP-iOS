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
        completionHandler(pictures,nil)
      }
    }
  }

  
}