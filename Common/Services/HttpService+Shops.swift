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
    var shopid = "8888"
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
  
  //我的商家列表[GET /res/v1/shop/belong/si]
  func getMyShops(page:Int = 0, pageSize:Int = 20, completionHandler: ([ShopDetailModel],NSError?)->Void) {
    let urlString = ResourcePath.MyShops.description.fullUrl
    
    let parameters = ["page":page,"page_size":pageSize]
    get(urlString, parameters: parameters, tokenRequired: false) { (json, error) -> Void in
      if let error = error {
        print(error)
        completionHandler([],error)
      } else {
        if let data = json?["data"].array where data.count > 0 {
          var shops = [ShopDetailModel]()
          for d in data {
            let shop = ShopDetailModel(json: d)
            shops.append(shop)
          }
          completionHandler(shops,nil)
        } else {
          completionHandler([],nil)
        }
        
      }
    }
  }
  
  func getMyCards(page:Int = 0, pageSize:Int = 20, completionHandler: ([MemberCard],NSError?)->Void) {
    let urlString = ResourcePath.MyCards.description.fullUrl
    
    let parameters = ["page":page,"page_size":pageSize]
    get(urlString, parameters: parameters, tokenRequired: false) { (json, error) -> Void in
      if let error = error {
        print(error)
        completionHandler([],error)
      } else {
        if let data = json?["data"].array where data.count > 0 {
          var shops = [MemberCard]()
          for d in data {
            let shop = MemberCard(json: d)
            shops.append(shop)
          }
          completionHandler(shops,nil)
        } else {
          completionHandler([],nil)
        }
        
      }
    }
  }
}