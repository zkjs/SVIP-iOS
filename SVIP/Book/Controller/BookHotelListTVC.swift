//
//  BookHotelListTVC.swift
//  SVIP
//
//  Created by dai.fengyi on 15/7/22.
//  Copyright (c) 2015年 zkjinshi. All rights reserved.
//

import UIKit

class BookHotelListCell: UITableViewCell {
  
  var hotelData: Hotel? {
    didSet {
      avatar .sd_setImageWithURL(NSURL(string: hotelData!.logoURL), placeholderImage: UIImage(named:"img_hotel_zhanwei"), options: [SDWebImageOptions.LowPriority, SDWebImageOptions.RetryFailed], completed: nil)
      hotel.text = hotelData!.fullname
    }
  }
  
  @IBOutlet weak var avatar: UIImageView!
  @IBOutlet weak var hotel: UILabel!
  @IBOutlet weak var hotelInfo: UILabel!
  
//  func configureCell(hotelData: Hotel) {
//    avatar .sd_setImageWithURL(NSURL(string: hotelData.logoURL), placeholderImage: UIImage(named:"img_hotel_zhanwei"), options: SDWebImageOptions.LowPriority | SDWebImageOptions.RetryFailed, completed: nil)
//    hotel.text = hotelData.fullname
//  }
  
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
    avatar.layer.cornerRadius = 40
    avatar.clipsToBounds = true
  }
}

enum HotelListStyle: Int, CustomStringConvertible {
  case Booking
  case PhoneCall
  
  var description: String {
    switch self {
    case Booking:
      return "Booking"
    case PhoneCall:
      return "PhoneCall"
    }
  }
}

class BookHotelListTVC: UITableViewController {

  var dataArray = NSMutableArray()
  var style = HotelListStyle.Booking
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.tableView .registerNib(UINib(nibName: "BookHotelListCell", bundle: nil), forCellReuseIdentifier: "reuseIdentifier")
    self.tableView.tableFooterView = UIView()
    
    // Hanton
    title = NSLocalizedString("CHOOSE_HOTEL", comment: "")
    
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
  
  // MARK: - Table view data source
  
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return dataArray.count
  }
  
  override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return 100
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath) as! BookHotelListCell
    
    cell.hotelData = dataArray[indexPath.row] as? Hotel

    return cell
  }
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    tableView .deselectRowAtIndexPath(indexPath, animated: true)
//    let vc = BookVC()
//    vc.shopid = (dataArray[indexPath.row] as? Hotel)!.shopid
//    let vc = BookingOrderTVC()
    
    switch style {
    case .Booking:
      let storyboard = UIStoryboard(name: "BookingOrder", bundle: nil)
      let vc = storyboard.instantiateViewControllerWithIdentifier("BookingOrderTVC") as! BookingOrderTVC
      vc.shopID = (dataArray[indexPath.row] as? Hotel)!.shopid
      self.navigationController?.pushViewController(vc, animated: true)
    case .PhoneCall:
      let hotel = dataArray[indexPath.row] as? Hotel
      UIApplication.sharedApplication().openURL(NSURL(string: "tel://\(hotel!.phone)")!)
    }
  }
}
