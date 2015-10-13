//
//  RightMenuVC.swift
//  SVIP
//
//  Created by Hanton on 10/13/15.
//  Copyright © 2015 zkjinshi. All rights reserved.
//

import UIKit

class RightMenuVC: UIViewController, RESideMenuDelegate {
  
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var name: UILabel!
  
  var shops = [NSDictionary]()
  
  // MARK: - Life cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupUI()
    loadData()
  }
  
  // MARK: - RESideMenuDelegate
  
  func sideMenu(sideMenu: RESideMenu!, willShowMenuViewController menuViewController: UIViewController!) {
    if menuViewController == self {
      tableView.reloadData()
    }
  }
  
  // MARK: - Table view data source
  
  func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return shops.count// + 1
  }
  
  func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return 90
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell: HotelMessageCell = tableView.dequeueReusableCellWithIdentifier(HotelMessageCell.reuseIdentifier()) as! HotelMessageCell
    
    //    if indexPath.row == 0 {
    //      cell.name.text = "软件反馈"
    //      cell.logo.setImage(UIImage(named: "img_hotel_zhanwei"), forState: .Normal)
    //      let userID = JSHAccountManager.sharedJSHAccountManager().userid
    //      let shopID = "808"  // 我们自己用shopID 808
    //      if let chatMessage = Persistence.sharedInstance().fetchLastMessageWithShopID(shopID, userID: userID) {
    //        let message = formatMessage(chatMessage)
    //        cell.tips.text = message["message"]
    //        cell.date.text = message["date"]
    //      }
    //
    //      if var shopMessageBadge = StorageManager.sharedInstance().shopMessageBadge() {
    //        if let badge = shopMessageBadge[shopID] {
    //          if badge != 0 {
    //            cell.logo.badgeString = String(badge)
    //          }
    //        }
    //      }
    //      return cell
    //    }
    
    //    let shop = shops[indexPath.row - 1]
    let shop = shops[indexPath.row]
    
    if let name = shop["fullname"] as? String {
      cell.name.text = name
    }
    
    if let shopID = shop["shopid"] as? String {
      let userID = JSHAccountManager.sharedJSHAccountManager().userid
      if let chatMessage = Persistence.sharedInstance().fetchLastMessageWithShopID(shopID, userID: userID) {
        let message = formatMessage(chatMessage)
        cell.tips.text = message["message"]
        cell.date.text = message["date"]
      }
      
      let placeholderImage = UIImage(named: "img_hotel_zhanwei")
      let urlString = "\(kBaseURL)uploads/shops/\(shopID).png"
      let logoURL = NSURL(string: urlString)
      cell.logo.sd_setImageWithURL(logoURL, forState: .Normal, placeholderImage: placeholderImage, options: [SDWebImageOptions.ProgressiveDownload, SDWebImageOptions.RetryFailed], completed: nil)
      
      if var shopMessageBadge = StorageManager.sharedInstance().shopMessageBadge() {
        if let badge = shopMessageBadge[shopID] {
          if badge != 0 {
            cell.logo.badgeString = String(badge)
          }
        }
      }
    }
    
    return cell
  }
  
  
  // MARK: - Table view delegate
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    tableView.deselectRowAtIndexPath(indexPath, animated: true)
    
    //    if indexPath.row == 0 {
    ////      sendLogEmail()
    //      let chatVC = JSHChatVC(chatType: ChatType.OldSession)
    //      chatVC.shopID = "808"
    //      chatVC.shopName = "软件反馈"
    //      if let navigationController = self.sideMenuViewController.contentViewController as? UINavigationController {
    //        self.sideMenuViewController.hideMenuViewController()
    //        navigationController.pushViewController(chatVC, animated: false)
    //      }
    //      return
    //    }
    
    //    let shop = shops[indexPath.row - 1]
    let shop = shops[indexPath.row]
    if let shopID = shop["shopid"] as? String {
      let chatVC = JSHChatVC(chatType: ChatType.OldSession)
      chatVC.shopID = shopID
      if let shopName = shop["fullname"] as? String {
        chatVC.shopName = shopName
      }
      //      navigationController?.pushViewController(chatVC, animated: true)
      if let navigationController = self.sideMenuViewController.contentViewController as? UINavigationController {
        self.sideMenuViewController.hideMenuViewController()
        navigationController.pushViewController(chatVC, animated: false)
      }
    }
  }
  
  // MARK: - Private Method
  
  private func setupUI() {
    name.text = NSLocalizedString("MESSAGE_CENTER", comment: "")
    
    sideMenuViewController.delegate = self
    
    let cellNib = UINib(nibName: HotelMessageCell.nibName(), bundle: nil)
    tableView.registerNib(cellNib, forCellReuseIdentifier: HotelMessageCell.reuseIdentifier())
    tableView.tableFooterView = UIView()
    
    UIApplication.sharedApplication().applicationIconBadgeNumber = 0
  }
  
  private func loadData() {
    if let shopsInfo = StorageManager.sharedInstance().shopsInfo() {
      self.shops = shopsInfo as! [(NSDictionary)]
    } else {
      ZKJSHTTPSessionManager.sharedInstance().getAllShopInfoWithPage(1, key: "", isDesc: true, success: { [unowned self] (task: NSURLSessionDataTask!, responseObject: AnyObject!) -> Void in
        self.shops = responseObject as! [(NSDictionary)]
        StorageManager.sharedInstance().saveShopsInfo(self.shops)
        self.tableView.reloadData()
        }) { (task: NSURLSessionDataTask!, error: NSError!) -> Void in
          
      }
    }
  }
  
  private func formatMessage(message: XHMessage) -> [String: String] {
    var chatMessage = [String: String]()
    if message.messageMediaType == .Text {
      chatMessage["message"] = message.text
    } else if message.messageMediaType == .Photo {
      chatMessage["message"] = "图片消息"
    } else if message.messageMediaType == .Voice {
      chatMessage["message"] = "语音消息"
    }
    
    let now = NSDate()
    let duration = NSDate.daysFromDate(message.timestamp, toDate: now)
    if duration == 0 {
      let dateFormat = NSDateFormatter()
      dateFormat.dateFormat = "HH:mm"
      chatMessage["date"] = "今天\(dateFormat.stringFromDate(message.timestamp))"
    } else if duration == 1 {
      let dateFormat = NSDateFormatter()
      dateFormat.dateFormat = "HH:mm"
      chatMessage["date"] = "昨天\(dateFormat.stringFromDate(message.timestamp))"
    } else {
      let dateFormat = NSDateFormatter()
      dateFormat.dateFormat = "MM-dd"
      chatMessage["date"] = "\(dateFormat.stringFromDate(message.timestamp))"
    }
    return chatMessage
  }
  
}
