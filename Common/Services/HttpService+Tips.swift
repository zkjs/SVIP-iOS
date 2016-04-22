//
//  HttpService+Tips.swift
//  SVIP
//
//  Created by Qin Yejun on 4/22/16.
//  Copyright © 2016 zkjinshi. All rights reserved.
//

import Foundation

extension HttpService {
  func getNearbyWaiters(shopid shopid:String,locids:String,completionHandler:([Waiter]?,NSError?) -> ()) {
    let urlString = ResourcePath.NearbyWaiters.description.fullUrl
    
    let dict = ["page":"0","page_size":"40"]
    
    get(urlString, parameters: dict) { (json, error) -> Void in
      if let error = error {
        completionHandler(nil,error)
      } else {
        if let data = json?["data"].array where data.count > 0 {
          var users = [Waiter]()
          for userData in data {
            let user = Waiter(json: userData)
            users.append(user)
          }
          print(users.count)
          completionHandler(users,nil)
        } else {
          completionHandler([],nil)
        }
      }
    }
  }
  
  
}