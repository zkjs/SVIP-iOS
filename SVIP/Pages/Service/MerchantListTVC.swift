//
//  MerchantListTVC.swift
//  SVIP
//
//  Created by Qin Yejun on 6/22/16.
//  Copyright © 2016 zkjinshi. All rights reserved.
//

import UIKit

class MerchantListTVC: UITableViewController {
  var shops = [ShopDetailModel]()
  var page = 0

  override func viewDidLoad() {
    super.viewDidLoad()
    
    tableView.tableFooterView = UIView()

    title = "选择商家"
    
    loadData()
  }
  
  func getShops(page:Int) {
    HttpService.sharedInstance.getMyShops(page,pageSize: 1000) { (shops, error) in
      self.hideHUD()
      if let error = error {
        self.showErrorHint(error)
      } else {
        if shops.count == 0 {
          if page == 0 {
            self.showHint("没有商家数据")
          }
        } else {
          self.shops = shops
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

  // MARK: - Table view data source

  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return shops.count
  }
  
  override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return 64
  }

  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("MerchantCell", forIndexPath: indexPath)
    let shop = shops[indexPath.row]
    let logo = cell.viewWithTag(10) as! UIImageView
    let title = cell.viewWithTag(11) as! UILabel
    logo.sd_setImageWithURL(NSURL(string: shop.shoplogo.fullImageUrl))
    title.text = shop.shopname
    
    return cell
  }
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    tableView.deselectRowAtIndexPath(indexPath, animated: true)
    performSegueWithIdentifier("SegueBeaconArea", sender: indexPath)
  }

  
  // MARK: - Navigation

  // In a storyboard-based application, you will often want to do a little preparation before navigation
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "SegueBeaconArea" {
      let vc = segue.destinationViewController as! BeaconAreaListTVC
      let idx = sender as! NSIndexPath
      let shop = shops[idx.row]
      vc.shopid = shop.shopID
    }
  }

}
