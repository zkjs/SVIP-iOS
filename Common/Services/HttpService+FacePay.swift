//
//  HttpService+FacePay.swift
//  SVIP
//
//  Created by AlexBang on 16/3/18.
//  Copyright © 2016年 zkjinshi. All rights reserved.
//

import Foundation

enum FacePayOrderStatus:Int {
  case NotPaid = 0,Rejected,Paid,Unknown
}

extension HttpService {

  
  
  func userPay(orderno:String,action:Int,completionHandler:(String?,NSError?) ->Void ) {
    let urlString = ResourcePath.UserEnsurePay.description.fullUrl
    let dict = ["orderno":orderno,"action":action]
    put(urlString, parameters: dict as? [String : AnyObject],tokenRequired: false) { (json, error) -> Void in
      if let error = error {
        print(error)
      } else {
        if let data = json?["resDesc"].string {
          completionHandler(data,nil)
        }
        
      }
    }
    
  }
  
  func userPaylistInfo(status:FacePayOrderStatus,page:Int = 0,completionHandler:([PaylistmModel]?,NSError?) ->Void) {
    let urlString = ResourcePath.PaymentInfo.description.fullUrl
    let dict = ["status":status.rawValue,"page":page,"page_size":HttpService.DefaultPageSize]
    get(urlString, parameters: dict) { (json, error) -> Void in
      if let error = error {
        print(error)
        completionHandler(nil,error)
      } else {
        var payArr = [PaylistmModel]()
        if let data = json?["data"].array where data.count > 0 {
          for dic in data {
            let pay = PaylistmModel(json:dic)
            payArr.append(pay)
          }

        }
        completionHandler(payArr,nil)
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
        } else {
          completionHandler(0,nil)
        }
      }
    }
  }
  
}