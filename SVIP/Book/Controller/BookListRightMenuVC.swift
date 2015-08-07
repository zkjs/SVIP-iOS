//
//  BookListRightMenuVC.swift
//  SVIP
//
//  Created by dai.fengyi on 15/8/7.
//  Copyright (c) 2015年 zkjinshi. All rights reserved.
//

import UIKit

//class BookListRightMenuCell: UITableViewCell {
//  var hotelData: Hotel? {
//    didSet {
//      avatar .sd_setImageWithURL(NSURL(string: hotelData!.logoURL), placeholderImage: UIImage(named:"img_hotel_zhanwei"), options: SDWebImageOptions.LowPriority | SDWebImageOptions.RetryFailed, completed: nil)
//      hotel.text = hotelData!.fullname
//    }
//  }
//  @IBOutlet weak var avatar: UIImageView!
//  @IBOutlet weak var hotel: UILabel!
//  @IBOutlet weak var hotelInfo: UILabel!
//  
//  //  func configureCell(hotelData: Hotel) {
//  //    avatar .sd_setImageWithURL(NSURL(string: hotelData.logoURL), placeholderImage: UIImage(named:"img_hotel_zhanwei"), options: SDWebImageOptions.LowPriority | SDWebImageOptions.RetryFailed, completed: nil)
//  //    hotel.text = hotelData.fullname
//  //  }
//  override func awakeFromNib() {
//    super.awakeFromNib()
//    // Initialization code
//    avatar.layer.cornerRadius = 40
//    avatar.clipsToBounds = true
//  }
//}

class BookListRightMenuCell: UITableViewCell {
  var hotelData: Hotel? {
    didSet {
      avatar .sd_setImageWithURL(NSURL(string: hotelData!.logoURL), placeholderImage: UIImage(named:"img_hotel_zhanwei"), options: SDWebImageOptions.LowPriority | SDWebImageOptions.RetryFailed, completed: nil)
      hotel.text = hotelData!.fullname
    }
  }
  @IBOutlet weak var avatar: UIImageView!
  @IBOutlet weak var hotel: UILabel!

  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
//    avatar.layer.cornerRadius = 40
//    avatar.clipsToBounds = true
  }
}

let RightMenuProportion = 0.75
class BookListRightMenuVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
  var dataArray = NSMutableArray()
  var tableView: UITableView!
  override func viewDidLoad() {
    super.viewDidLoad()
    tableView = UITableView(frame: CGRectMake(self.view.bounds.width * CGFloat(1 - RightMenuProportion), 0, self.view.bounds.width * CGFloat(RightMenuProportion), self.view.bounds.height))
    tableView.delegate = self
    tableView.dataSource = self
    tableView .registerNib(UINib(nibName: "BookListRightMenuCell", bundle: nil), forCellReuseIdentifier: "reuseIdentifier")
//    tableView.registerClass(UITableViewCell.self, forHeaderFooterViewReuseIdentifier: "reuseIdentifier")
    tableView.tableHeaderView = UIView(frame: CGRectMake(0, 0, tableView.bounds.width, 100))
    tableView.tableFooterView = UIView()
    self.view.addSubview(tableView)
    loadData()
  }
  private func loadData() {
    ZKJSHTTPSessionManager .sharedInstance() .getAllShopInfoWithPage(1, key: nil, isDesc: true, success: { (task: NSURLSessionDataTask!, responseObject: AnyObject!) -> Void in
      if let array = responseObject as? NSArray {
        for dic in array {
          let hotelData = Hotel(dic: dic as! NSDictionary)
          self.dataArray .addObject(hotelData)
        }
        self.tableView .reloadData()
      }
      }) { (task: NSURLSessionDataTask!, error: NSError!) -> Void in
        ZKJSTool .showMsg("加载数据失败")
    }
  }
  //MARK: - Button Action
  // Hanton
  func dismissSelf() -> Void {
    dismissViewControllerAnimated(true, completion: nil)
  }
  
  func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return dataArray.count
  }
  
  func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return 60
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    var cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath) as! BookListRightMenuCell
    // Configure the cell...
    cell.hotelData = dataArray[indexPath.row] as? Hotel
    return cell
  }
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    tableView .deselectRowAtIndexPath(indexPath, animated: true)
    let vc = BookVC()
    vc.shopid = (dataArray[indexPath.row] as? Hotel)!.shopid
    if let navi = self.sideMenuViewController.contentViewController as? UINavigationController {
      self.sideMenuViewController.hideMenuViewController()
      navi.pushViewController(vc, animated: true)
    }
    
  }
  
}
