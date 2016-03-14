//
//  HttpService+Shops.swift
//  SVIP
//
//  Created by Qin Yejun on 3/11/16.
//  Copyright © 2016 zkjinshi. All rights reserved.
//

import Foundation

extension HttpService {
  
  /**
   *  商家列表
   *  city: 中文城市名称
   *  strategy: 获取策略: 默认(空或default), 系统推荐(sys)
   */
  func getShopList(city city:String?, page:Int = 0, pageSize:Int = HttpService.DefaultPageSize, strategy:String? = "", completionHandler: ([Shop]?,NSError?)->Void) {
    var urlString = ResourcePath.ShopList.description.fullUrl
    if let city = city?.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet()) {
      urlString += "/" + city
    }
    var dict = ["page":"\(page)","page_size":"\(pageSize)"]
    if let strategy = strategy where !strategy.isEmpty {
      dict["strategy"] = strategy
    }
    
    get(urlString, parameters: dict,tokenRequired: false) { (json, error) -> Void in
      if let error = error {
        print(error)
        completionHandler(nil,error)
      } else {
        var shops = [Shop]()
        if let data = json?["data"].array where data.count > 0 {
          for d in data {
            let shop = Shop(json: d)
            shops.append(shop)
          }
          print("shop count:\(shops.count)")
        }
        completionHandler(shops,nil)
      }
    }
  }
  
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
  
  /**
   *  商家评论列表
   */
  func getShopComments(shopid:String, page:Int = 0, pageSize:Int = HttpService.DefaultPageSize, completionHandler: ([CommentModel]?,NSError?)->Void) {
    let urlString = ResourcePath.ShopComments(shopid: shopid).description.fullUrl

    let dict = ["page":"\(page)","page_size":"\(pageSize)"]
    
    get(urlString, parameters: dict,tokenRequired: false) { (json, error) -> Void in
      if let error = error {
        print(error)
        completionHandler(nil,error)
      } else {
        var comments = [CommentModel]()
        if let data = json?["data"].array where data.count > 0 {
          for d in data {
            comments.append(CommentModel(json: d))
          }
          print("comments count:\(comments.count)")
        }
        completionHandler(comments,nil)
      }
    }
  }

  
}