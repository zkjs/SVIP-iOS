//
//  ShopViewModel.swift
//  SVIP
//
//  Created by Qin Yejun on 3/11/16.
//  Copyright © 2016 zkjinshi. All rights reserved.
//

import Foundation

class ShopViewModel {
  typealias LoadCompletion = (hasMore:Bool,error:NSError?) -> Void
  
  private (set) var hasMore:Bool = false
  private var page:Int = 0
  private let pageSize:Int = HttpService.DefaultPageSize
  private var isLoading:Bool = false
  private var city:String?
  private var strategy:String?
  private (set) var data = [Shop]()

  init(city:String?,strategy:String?) {
    self.city = city
    self.strategy = strategy
  }
  
  func load(page:Int = 0, completionHandler:LoadCompletion?) {
    if isLoading { return }
    
    isLoading = true
    if page == 0 { self.page = 0 }
    
    HttpService.sharedInstance.getShopList(city: city, page: page, pageSize: pageSize, strategy: strategy) {[weak self](shops, error) -> Void in
      if let strongSelf = self {
        strongSelf.hasMore = shops?.count >= strongSelf.pageSize
        strongSelf.isLoading = false
        
        if strongSelf.page == 0 {//refresh or first time loading
          strongSelf.data = shops ?? []
        } else {
          if let shops = shops {
            strongSelf.data += shops
          }
        }
        
        completionHandler?(hasMore: strongSelf.hasMore, error: error)
      }
    }
  }
  
  func next(completionHandler: LoadCompletion?) {
    if isLoading { return }
    
    ++page
    
    load(page,completionHandler: completionHandler)
  }
  
  func setCity(city:String, completionHandler:LoadCompletion?) {
    self.city = city
    load(0, completionHandler: completionHandler)
  }
  
  func setStrategy(strategy:String, completionHandler:LoadCompletion?) {
    self.strategy = strategy
    load(0, completionHandler: completionHandler)
  }

  
}