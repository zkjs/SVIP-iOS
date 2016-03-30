//
//  YunbaSubscribeService.swift
//  SVIP
//
//  Created by Qin Yejun on 3/30/16.
//  Copyright © 2016 zkjinshi. All rights reserved.
//

import Foundation

struct YunbaSubscribeService {
  static let sharedInstance = YunbaSubscribeService()
  private init(){}
  
  func setAlias(alias:String) {
    print("set alias:\(alias)")
    YunBaService.setAlias(alias) { (succ, err) -> Void in
      if succ {
        print("Yunba setAlias success:\(alias)")
      } else {
        print("Yunba setAlias fail.\(err)")
      }
    }
  }
  
  func unsubscribeAllTopics() {
    YunBaService.getTopicList { (topics, error) in
      guard let topics = topics as? [String] else {
        return
      }
      for topic in topics {
        print("unSubscribe yunba:\(topic)")
        YunBaService.unsubscribe(topic, resultBlock: { (succ, err) in })
      }
    }
  }
}