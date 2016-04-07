//
//  shopmodsMmodel.swift
//  SVIP
//
//  Created by AlexBang on 16/4/7.
//  Copyright © 2016年 zkjinshi. All rights reserved.
//

import UIKit
import SwiftyJSON

class ShopmodsModel: NSObject {
  let title:String                
  let body:String                
  let shopid:String          
  let modid:String           
  let sort:String         
  let photos:[String]       
                
  
  init (json:JSON) {
    
    title = json["title"].string ?? ""
    body = json["body"].string ?? ""
    shopid = json["shopid"].string ?? ""
    modid = json["modid"].string ?? ""
    sort = json["sort"].string ?? ""
    photos = json["photos"].array?.flatMap{ $0.string?.fullImageUrl } ?? []
      
  }

}
