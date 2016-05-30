//
//  MyShopsTVC.swift
//  SVIP
//
//  Created by Qin Yejun on 5/24/16.
//  Copyright © 2016 zkjinshi. All rights reserved.
//

import UIKit
import MJRefresh

class MyShopsTVC: UITableViewController {
  var shops = [ShopDetailModel]()
  var page = 0
  
  override func viewDidLoad() {
    super.viewDidLoad()
    title = "我的商家"
    tableView.tableFooterView = UIView()
    tableView.separatorInset = UIEdgeInsetsZero
    tableView.layoutMargins = UIEdgeInsetsZero
    
    tableView.mj_header = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: "loadData")
    tableView.mj_footer = MJRefreshAutoNormalFooter(refreshingTarget: self, refreshingAction: "loadMore")
    
    showHUDInView(view, withLoading: "")
    loadData()
  }
  
  func getShops(page:Int) {
    HttpService.sharedInstance.getMyShops(page) { (shops, error) in
      self.hideHUD()
      self.tableView.mj_header.endRefreshing()
      self.tableView.mj_footer.endRefreshing()
      if let error = error {
        self.showErrorHint(error)
      } else {
        if shops.count < HttpService.DefaultPageSize {
          self.tableView.mj_footer.hidden = true
        } else {
          self.tableView.mj_footer.hidden = false
        }
        if shops.count == 0 {
          if page == 0 {
            self.showHint("没有商家数据")
          }
        } else {
          if page > 0 {
            self.shops += shops
          } else {
            self.shops = shops
          }
          self.tableView.reloadData()
        }
      }
    }
  }
  
  func loadData() {
    page = 0
    getShops(page)
  }
  
  func loadMore() {
    page += 1
    getShops(page)
  }
  
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return shops.count
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("ShopCell", forIndexPath: indexPath)
    let shop = shops[indexPath.row]
    let logo = cell.viewWithTag(10) as! UIImageView
    let title = cell.viewWithTag(11) as! UILabel
    logo.sd_setImageWithURL(NSURL(string: shop.shoplogo.fullImageUrl))
    title.text = shop.shopname
    
    return cell
  }
}
