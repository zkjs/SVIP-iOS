//
//  HttpService+FacePay.swift
//  SVIP
//
//  Created by AlexBang on 16/3/18.
//  Copyright © 2016年 zkjinshi. All rights reserved.
//

import Foundation

enum FacePayOrderStatus:Int {
  case NotPaid = 0,Rejected,Paid
}

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
  
  func userPaylistInfo(status:FacePayOrderStatus,page:Int = 0,completionHandler:HttpCompletionHandler ) {
    let urlString = ResourcePath.PaymentInfo.description.fullUrl
    let dict = ["status":status.rawValue,"page":page,"page_size":HttpService.DefaultPageSize]
    get(urlString, parameters: dict) { (json, error) -> Void in
      if let error = error {
        print(error)
        completionHandler(nil,error)
      } else {
        if let data = json?["data"].array where data.count > 0 {
          
        }
      }
    }
    
  }
  
  // 查询账户余额 GET /for/res/v1/payment/balance
  func getBalance(completionHandler:(Double,NSError?)->Void) {
    let urlString = ResourcePath.Balance.description.fullUrl
    
    get(urlString, parameters: nil) { (json, error) -> Void in
      if let error = error {
        completionHandler(0,error)
      } else {
        if let data = json?["balance"].double {
          completionHandler(data,nil)
        }
        completionHandler(0,nil)
      }
    }
  }
  
}