//
//  HttpService+Activity.swift
//  SVIP
//
//  Created by Qin Yejun on 6/29/16.
//  Copyright © 2016 zkjinshi. All rights reserved.
//

import Foundation

extension HttpService {
  /// 我的行程列表
  func getMySchedule(page:Int = 0, locid:String = "", completionHandler: ([MySchedule],NSError?)->Void) {
    let urlString = ResourcePath.MySchedule.description.fullUrl
    
    let parameters = ["page":page,"page_size":HttpService.DefaultPageSize]
    get(urlString, parameters: parameters, tokenRequired: true) { (json, error) -> Void in
      if let error = error {
        print(error)
        completionHandler([],error)
      } else {
        if let data = json?["data"].array where data.count > 0 {
          var ret = [MySchedule]()
          for d in data {
            let o = MySchedule(json: d)
            ret.append(o)
          }
          completionHandler(ret, nil)
        } else {
          completionHandler([],nil)
        }
      }
    }
  }
  
  /// 参加活动
  func attendActivity(actid:String, memdersCount:Int, completionHandler:HttpCompletionHandler){
    let urlString = ResourcePath.AttendActivity.description.fullUrl
    
    let dict = ["actstatus":"1","actid":actid, "takeperson":"\(memdersCount)"]
    put(urlString, parameters: dict) { (json, error) in
      if let error = error {
        completionHandler(nil,error)
      } else {
        completionHandler(json,nil)
      }
    }
  }
  
  /// 参加活动
  func quitActivity(actid:String, completionHandler:HttpCompletionHandler){
    let urlString = ResourcePath.QuitActivity.description.fullUrl
    
    let dict = ["actstatus":"2","actid":actid]
    put(urlString, parameters: dict) { (json, error) in
      if let error = error {
        completionHandler(nil,error)
      } else {
        completionHandler(json,nil)
      }
    }
  }
  
}