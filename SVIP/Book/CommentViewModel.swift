//
//  CommentViewModel.swift
//  SVIP
//
//  Created by Qin Yejun on 3/12/16.
//  Copyright © 2016 zkjinshi. All rights reserved.
//

import Foundation

class CommentViewModel {
  typealias LoadCompletion = (hasMore:Bool,error:NSError?) -> Void
  
  private (set) var hasMore:Bool = false
  private var page:Int = 0
  private let pageSize:Int = HttpService.DefaultPageSize
  private var isLoading:Bool = false
  private var shopid:String
  private (set) var data = [CommentModel]()
  
  init(shopid:String) {
    self.shopid = shopid
  }
  
  func load(page:Int = 0, completionHandler:LoadCompletion?) {
    if isLoading { return }
    
    isLoading = true
    if page == 0 { self.page = 0 }
    
    HttpService.sharedInstance.getShopComments(shopid, page: page, pageSize: pageSize) {[weak self] (comments, error) -> Void in
      if let strongSelf = self {
        strongSelf.hasMore = comments?.count >= strongSelf.pageSize
        strongSelf.isLoading = false
        
        if strongSelf.page == 0 {//refresh or first time loading
          strongSelf.data = comments ?? []
        } else {
          if let comments = comments {
            strongSelf.data += comments
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
  
  func setShopid(shopid:String, completionHandler:LoadCompletion?) {
    self.shopid = shopid
    load(0, completionHandler: completionHandler)
  }
  
  
}