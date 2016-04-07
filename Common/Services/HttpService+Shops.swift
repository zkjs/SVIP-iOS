//
//  HttpService+Shops.swift
//  SVIP
//
//  Created by Qin Yejun on 3/11/16.
//  Copyright © 2016 zkjinshi. All rights reserved.
//

import Foundation

extension HttpService {
  
  //取商家详情GET/res/v1/shop/detail/{shopid}
  func getShopDetail(shopid:String, completionHandler: (ShopDetailModel?,NSError?)->Void) {
    let urlString = ResourcePath.ShopDetail(id: shopid).description.fullUrl
    
    get(urlString, parameters: nil, tokenRequired: false) { (json, error) -> Void in
      if let error = error {
        print(error)
        completionHandler(nil,error)
      } else {
        if let data = json?["data"].array?.first {
          let shop = ShopDetailModel(json: data)
          completionHandler(shop,nil)
        } else {
          completionHandler(nil,error)
        }
        
      }
    }
  }
}