//
//  BookingOrderTVC.swift
//  SVIP
//
//  Created by Hanton on 8/24/15.
//  Copyright (c) 2015 zkjinshi. All rights reserved.
//

import UIKit

class BookingOrderTVC: UITableViewController {
  
  @IBOutlet weak var roomImage: UIImageView!
  @IBOutlet weak var roomType: UILabel!
  @IBOutlet weak var startDate: UILabel!
  @IBOutlet weak var endDate: UILabel!
  @IBOutlet weak var dateTips: UILabel!
  
  var shopID = ""
  var dateFormatter = NSDateFormatter()
  
  override func viewDidLoad() {
    super.viewDidLoad()

    title = "填写订单"
    
    dateFormatter.dateFormat = "M月dd日"
    startDate.text = dateFormatter.stringFromDate(NSDate())
    endDate.text = dateFormatter.stringFromDate(NSDate().dateByAddingTimeInterval(60*60*24*1))
    dateTips.text = "共1晚，在\(endDate.text!)13点前退房"
  }
  
  // MARK: - Table view data source
  
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 3
  }
  
//  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//    var rows = 0
//    switch section {
//    case 0:
//      rows = 2
//    case 1:
//      rows = 2
//    case 2:
//      rows = 2
//    default:
//      break
//    }
//    return rows
//  }
  
//  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
//    return UITableViewCell()
//  }
  
  // MARK: - Table view delegate
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    println(indexPath)
    
    if indexPath.section == 0 && indexPath.row == 0 {  // 房型
      let vc = BookVC()
      vc.shopid = shopID
      vc.selection = { [unowned self] (goods: RoomGoods) -> () in
        self.roomType.text = goods.room! + goods.type!
//        self.roomImage = goods.image
        let baseUrl = kBaseURL// "http://120.25.241.196/"
        if let goodsImage = goods.image {
          let urlStr = baseUrl .stringByAppendingString(goodsImage)
          let placeholderImage = UIImage(named: "bg_dingdan")
          let url = NSURL(string: urlStr)
          self.roomImage.sd_setImageWithURL(url, placeholderImage: placeholderImage, options: SDWebImageOptions.LowPriority | SDWebImageOptions.RetryFailed, completed: nil)
        }

      }
      navigationController?.pushViewController(vc, animated: true)
    } else if indexPath.section == 0 && indexPath.row == 1 {  // 房间数量
      
    } else if indexPath.section == 1 && indexPath.row == 1 {  // 入住/离店时间
      let vc = BookDateSelectionViewController()
      vc.selection = { [unowned self] (startDate: NSDate, endDate: NSDate) ->() in
        self.startDate.text = self.dateFormatter.stringFromDate(startDate)
        self.endDate.text = self.dateFormatter.stringFromDate(endDate)
        let duration = NSDate.daysFromDate(startDate, toDate: endDate)
        self.dateTips.text = "共\(duration)晚，在\(self.endDate.text!)13点前退房"
      }
      navigationController?.pushViewController(vc, animated: true)
    }
  }
  
}
