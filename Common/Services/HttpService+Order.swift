//
//  HttpService+Order.swift
//  SVIP
//
//  Created by Qin Yejun on 6/23/16.
//  Copyright © 2016 zkjinshi. All rights reserved.
//

import Foundation

extension HttpService {
  func getServiceTag(locid:String = "", completionHandler: ([ServiceLoc],NSError?)->Void) {
    let urlString = ResourcePath.ServiceTag.description.fullUrl
    
    //completionHandler([],nil)
    get(urlString, parameters: !locid.isEmpty ? ["locid":locid] : nil, tokenRequired: true) { (json, error) -> Void in
      if let error = error {
        print(error)
        completionHandler([],error)
      } else {
        if let data = json?["data"].array where data.count > 0 {
          var locs = [ServiceLoc]()
          for d in data {
            let l = ServiceLoc(json: d)
            locs.append(l)
          }
          completionHandler(locs,nil)
        } else {
          completionHandler([],nil)
        }
        
      }
    }
  }
  
  /// 呼叫服务列表
  func getMyOrders(page:Int = 0, locid:String = "", completionHandler: ([MyOrder],NSError?)->Void) {
    let urlString = ResourcePath.Myorders.description.fullUrl
    
    let parameters = ["page":page,"page_size":HttpService.DefaultPageSize]
    get(urlString, parameters: parameters, tokenRequired: true) { (json, error) -> Void in
      if let error = error {
        print(error)
        completionHandler([],error)
      } else {
        if let data = json?["data"].array where data.count > 0 {
          var orders = [MyOrder]()
          for d in data {
            let o = MyOrder(json: d)
            orders.append(o)
          }
          completionHandler(orders, nil)
        } else {
          completionHandler([],nil)
        }
      }
    }
  }
  
  /// 服务评价
  func ratingService(taskid:String, ratingValue:Double, operationseq:Int, review:String = "", completionHandler:HttpCompletionHandler){
    let urlString = ResourcePath.RatingOrder.description.fullUrl
    
    let dict = ["taskaction":"6","operationseq":"\(operationseq)", "taskid":taskid, "score":"\(Int(ratingValue * 2))", "desc":review]
    put(urlString, parameters: dict) { (json, error) in
      if let error = error {
        completionHandler(nil,error)
      } else {
        completionHandler(json,nil)
      }
    }
  }
  
  /// 创建呼叫服务 /res/v1/call/service/task
  func createOrder(srvid:String, locid:String, remark:String = "", completionHandler:HttpCompletionHandler){
    let urlString = ResourcePath.CreateOrder.description.fullUrl
    
    let dict = ["srvid":srvid, "locid":locid, "desc":remark]
    post(urlString, parameters: dict) { (json, error) in
      if let error = error {
        completionHandler(nil,error)
      } else {
        completionHandler(json,nil)
      }
    }
  }
  
  /// 商家区域列表
  func getBeaconAreas(shopid:String, page:Int = 0, pageSize:Int = 1000, completionHandler: ([BeaconArea],NSError?)->Void) {
    let urlString = ResourcePath.BeaconAreas.description.fullUrl
    
    let parameters = ["shopid":shopid,"page": "\(page)","page_size":"\(pageSize)"]
    get(urlString, parameters: parameters, tokenRequired: true) { (json, error) -> Void in
      if let error = error {
        print(error)
        completionHandler([],error)
      } else {
        if let data = json?["data"].array where data.count > 0 {
          var beacons = [BeaconArea]()
          for d in data {
            let o = BeaconArea(json: d)
            beacons.append(o)
          }
          completionHandler(beacons, nil)
        } else {
          completionHandler([],nil)
        }
      }
    }
  }
  
}