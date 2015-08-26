//
//  BookingOrderTVC.swift
//  SVIP
//
//  Created by Hanton on 8/24/15.
//  Copyright (c) 2015 zkjinshi. All rights reserved.
//

import UIKit

class BookingOrderTVC: UITableViewController, UITextFieldDelegate {
  
  @IBOutlet weak var roomImage: UIImageView!
  @IBOutlet weak var roomType: UILabel!
  @IBOutlet weak var startDate: UILabel!
  @IBOutlet weak var endDate: UILabel!
  @IBOutlet weak var dateTips: UILabel!
  @IBOutlet weak var roomCountLabel: UILabel!
  @IBOutlet var nameTextFields: [UITextField]!
  
  var shopID = ""
  var dateFormatter = NSDateFormatter()
  var roomCount = 1
  
  override func viewDidLoad() {
    super.viewDidLoad()

    title = "填写订单"
    self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "确定", style: UIBarButtonItemStyle.Plain, target: self, action: "gotoChatVC")
    
    dateFormatter.dateFormat = "M月dd日"
    startDate.text = dateFormatter.stringFromDate(NSDate())
    endDate.text = dateFormatter.stringFromDate(NSDate().dateByAddingTimeInterval(60*60*24*1))
    dateTips.text = "共1晚，在\(endDate.text!)13点前退房"
  }
  
  // MARK: - Private
  
  func gotoChatVC() {
    let chatVC = JSHChatVC(chatType: .NewSession)
    chatVC.shopID = shopID
    navigationController?.pushViewController(chatVC, animated: true)
  }
  
  // MARK: - Action
  
  @IBAction func roomCountChanged(sender: UIStepper) {
    roomCountLabel.text = Int(sender.value).description + "间"
    let count = Int(sender.value)
    roomCount = count
    tableView.reloadData()
  }
  
  @IBAction func sendBookingOrder(sender: AnyObject) {
    // 还差后台接口发个消息给商家端
    for index in 0..<roomCount {
      println(nameTextFields[index].text)
    }
    gotoChatVC()
  }
  
  // MARK: - Table view datasource
  
  override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    if indexPath.section == 2 {
      if indexPath.row > roomCount {
        return 0.0
      }
    }
    return super.tableView(tableView, heightForRowAtIndexPath: indexPath)
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    var count = super.tableView(tableView, numberOfRowsInSection: section)
    if section == 2 {
      count = roomCount
    }
    return count
  }
  
  // MARK: - Table view delegate
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    println(indexPath)
    
    if indexPath.section == 0 && indexPath.row == 0 {  // 房型
      let vc = BookVC()
      vc.shopid = shopID
      vc.selection = { [unowned self] (goods: RoomGoods) -> () in
        self.roomType.text = goods.room! + goods.type!
        let baseUrl = kBaseURL
        if let goodsImage = goods.image {
          let urlStr = baseUrl .stringByAppendingString(goodsImage)
          let placeholderImage = UIImage(named: "bg_dingdan")
          let url = NSURL(string: urlStr)
          self.roomImage.sd_setImageWithURL(url, placeholderImage: placeholderImage, options: SDWebImageOptions.LowPriority | SDWebImageOptions.RetryFailed, completed: nil)
        }
      }
      navigationController?.pushViewController(vc, animated: true)
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
  
  // MARK: - UITextFieldDelegate
  func textFieldShouldReturn(textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    return false
  }
  
}
