//
//  HttpService+FacePay.swift
//  SVIP
//
//  Created by AlexBang on 16/3/18.
//  Copyright © 2016年 zkjinshi. All rights reserved.
//

import Foundation
extension HttpService {

  
  
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
  
  func userPaylistInfo(status:Int,page:Int,completionHandler:HttpCompletionHandler ->Void ) {
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