//
//  HttpService+FacePay.swift
//  SVIP
//
//  Created by AlexBang on 16/3/18.
//  Copyright © 2016年 zkjinshi. All rights reserved.
//

import Foundation
extension HttpService {
  
  func getBeaconNearUsersList(shopid:String,locids:String,page:NSNumber, completionHandler: HttpCompletionHandler ->Void ) {
    let dict = ["shopid":shopid,"locids":locids,"page":page,"page_size":15]
    let urlString = ResourcePath.BeaconNearUsersList.description.fullUrl
    get(urlString, parameters: dict,tokenRequired: false) { (json, error) -> Void in
      if let error = error {
        print(error)
      } else {
        if let data = json?["users"].array where data.count > 0 {
         
        }
      }
    }
    
  }
  
  
  func userPay(orderno:String, completionHandler: HttpCompletionHandler ->Void ) {
    let urlString = ResourcePath.UserEnsurePay.description.fullUrl
    let dict = ["orderno":orderno,"action":1]
    get(urlString, parameters: dict as? [String : AnyObject],tokenRequired: false) { (json, error) -> Void in
      if let error = error {
        print(error)
      } else {
        if let data = json?["res"].string {
          print(data)
        }
      }
    }
    
  }
  
  func userPaylistInfo(completionHandler:HttpCompletionHandler ->Void ) {
    let urlString = ResourcePath.PaymentInfo.description.fullUrl
    get(urlString, parameters: nil,tokenRequired: false) { (json, error) -> Void in
      if let error = error {
        print(error)
      } else {
        if let data = json?["data"].array where data.count > 0 {
          
        }
      }
    }
    
  }
  
  
  
}