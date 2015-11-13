//
//  AdvertisementModel.swift
//  SVIP
//
//  Created by AlexBang on 15/11/12.
//  Copyright © 2015年 zkjinshi. All rights reserved.
//

import UIKit

class AdvertisementModel: NSObject {
  var ad_title: String?
  var url: String?
  
  init(dic:[String:AnyObject]) {
    ad_title = dic["ad_title"] as? String
    url = dic["url"] as? String
  }

}
