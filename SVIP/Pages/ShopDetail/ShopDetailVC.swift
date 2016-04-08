//
//  ShopDetailVC.swift
//  SVIP
//
//  Created by Qin Yejun on 4/6/16.
//  Copyright © 2016 zkjinshi. All rights reserved.
//

import UIKit

class ShopDetailVC: UITableViewController {
  
 
  @IBOutlet weak var headerView: UIView!
  @IBOutlet weak var phoneLabel: UILabel!
  @IBOutlet weak var shopAddressLabel: UILabel!
  @IBOutlet weak var shopnameLabel: UILabel!
  @IBOutlet weak var shoplogoImageView: UIImageView!
  var shopDetailArray = [ShopmodsModel]() 
  var shopDetail: ShopDetailModel!
  
  override func viewDidLoad() {
    super.viewDidLoad()

    tableView.tableFooterView = UIView()
    tableView.contentInset = UIEdgeInsetsMake(-20, 0, 0, 0)
    self.tableView.backgroundColor = UIColor(patternImage: UIImage(named: "texture_bg")!)
    headerView.backgroundColor = UIColor(patternImage: UIImage(named: "texture_bg")!)
    tableView.separatorStyle = UITableViewCellSeparatorStyle.None
    tableView.separatorColor = UIColor(hex: "#B8B8B8")
    //分割线往左移
    if tableView.respondsToSelector(Selector("setSeparatorInset:")) {
      tableView.separatorInset = UIEdgeInsetsZero
    }
    if tableView.respondsToSelector(Selector("setLayoutMargins:")) {
      tableView.layoutMargins = UIEdgeInsetsZero
    }
    self.tableView.rowHeight = UITableViewAutomaticDimension
    self.tableView.estimatedRowHeight = 365.0

  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
//    navigationController?.navigationBarHidden = true
//    navigationController?.navigationBar.translucent = true
    loadData()
    
  }
  
 
  
  func setupView() {
    guard let url:String = shopDetail.shoplogo,let shopname:String = shopDetail.shopname,let shopAddress:String = shopDetail.shopaddress,phone:String = shopDetail.telephone else {return}
    shoplogoImageView.sd_setImageWithURL(NSURL(string: url.fullImageUrl))
    shopnameLabel.text = shopname
    shopAddressLabel.text = shopAddress
    phoneLabel.text = phone
    self.tableView.reloadData()
  }
  
  func loadData() {
    guard let shopid = TokenPayload.sharedInstance.shopid else {return}
    HttpService.sharedInstance.getShopDetail(shopid) { (shopDetail, error) -> Void in
      if let _ = error {
        
      } else {
        self.shopDetail = shopDetail 
        self.shopDetailArray = self.shopDetail.shopmods
        self.setupView()
        self.tableView.reloadData()
      }
    }
  }
  
  
   override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
    
    if cell.respondsToSelector(Selector("setSeparatorInset:")) {
      cell.separatorInset = UIEdgeInsetsZero
    }
    if cell.respondsToSelector(Selector("setLayoutMargins:")) {
      cell.layoutMargins = UIEdgeInsetsZero
    }
  }
  
  
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }
  
  
  override   func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return shopDetailArray.count
  }
  
   override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("ShopDetailCell", forIndexPath: indexPath) as! ShopDetailCell
    let shopmod = shopDetail.shopmods[indexPath.row]
    cell.configCell(shopmod)
    return cell
  }
  
}
