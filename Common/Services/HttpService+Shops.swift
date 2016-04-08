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
  func getShopDetail( completionHandler: (ShopDetailModel?,NSError?)->Void) {
    var shopid = ""
    if let shopLogo = StorageManager.sharedInstance().cachedShopLogo() where shopLogo.validthru.timeIntervalSinceNow > 0 {
      shopid = shopLogo.shopid
    }
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