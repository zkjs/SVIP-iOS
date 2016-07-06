//
//  MemberCardTVC.swift
//  SVIP
//
//  Created by Qin Yejun on 7/5/16.
//  Copyright © 2016 zkjinshi. All rights reserved.
//

import UIKit
import MJRefresh

class MemberCardTVC: UITableViewController {
  var cards = [MemberCard]()
  var page = 0
  
  override func viewDidLoad() {
    super.viewDidLoad()
    title = "会员卡"
    tableView.tableFooterView = UIView()
    tableView.separatorStyle = .None
    
    tableView.mj_header = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: "loadData")
    tableView.mj_footer = MJRefreshAutoNormalFooter(refreshingTarget: self, refreshingAction: "loadMore")
    
    showHUDInView(view, withLoading: "")
    loadData()
  }
  
  func getCards(page:Int) {
    HttpService.sharedInstance.getMyCards(page) { (cards, error) in
      self.hideHUD()
      self.tableView.mj_header.endRefreshing()
      self.tableView.mj_footer.endRefreshing()
      if let error = error {
        self.showErrorHint(error)
      } else {
        if cards.count < HttpService.DefaultPageSize {
          self.tableView.mj_footer.hidden = true
        } else {
          self.tableView.mj_footer.hidden = false
        }
        if cards.count == 0 {
          if page == 0 {
            self.showHint("没有商家数据")
          }
        } else {
          if page > 0 {
            self.cards += cards
          } else {
            self.cards = cards
          }
          self.tableView.reloadData()
        }
      }
    }
  }
  
  func loadData() {
    page = 0
    getCards(page)
  }
  
  func loadMore() {
    page += 1
    getCards(page)
  }
  
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return cards.count
  }
  
  override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return 130
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("MemberCardCell", forIndexPath: indexPath)
    let shop = cards[indexPath.row]
    let titleLabel = cell.viewWithTag(1) as! UILabel
    let numberLabel = cell.viewWithTag(2) as! UILabel
    let priceLabel = cell.viewWithTag(3) as! UILabel
    titleLabel.text = shop.shopname
    numberLabel.text = shop.accountno
    priceLabel.text = shop.displayBalance
    
    return cell
  }
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    tableView.deselectRowAtIndexPath(indexPath, animated: true)
    let card = cards[indexPath.row]
    let billStoryboard = UIStoryboard(name:"BillList",bundle: nil)
    let vc = billStoryboard.instantiateViewControllerWithIdentifier("BillListVC") as! BillListVC
    vc.shopid = card.shopID
    self.navigationController?.pushViewController(vc, animated: true)
  }
}
