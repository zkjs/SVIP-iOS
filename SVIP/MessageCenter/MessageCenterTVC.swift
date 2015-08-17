//
//  MessageCenterTVC.swift
//  SVIP
//
//  Created by Hanton on 6/27/15.
//  Copyright (c) 2015 zkjinshi. All rights reserved.
//

import UIKit
import MessageUI

private let kRightViewRatio: Double = 1.0 - 0.75

class MessageCenterTVC: UIViewController, UITableViewDataSource, UITableViewDelegate, MFMailComposeViewControllerDelegate {
  
  let tableView = UITableView()
  
  var shops = [NSDictionary]()
  
  // MARK: - Life cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    
//    title = "消息中心"
    
//    navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Stop, target: self, action: NSSelectorFromString("dismissSelf"))
    
    let screeWidth = UIScreen.mainScreen().bounds.width
    tableView.frame = CGRectMake(screeWidth * 0.25, 0.0, screeWidth * 0.75, UIScreen.mainScreen().bounds.height)
    tableView.bounces = false
    tableView.delegate = self
    tableView.dataSource = self
    view.addSubview(tableView)
    
    let cellNib = UINib(nibName: HotelMessageCell.nibName(), bundle: nil)
    tableView.registerNib(cellNib, forCellReuseIdentifier: HotelMessageCell.reuseIdentifier())
    tableView.tableFooterView = UIView()
    
    UIApplication.sharedApplication().applicationIconBadgeNumber = 0
    
    fetchShops()
  }
  
  override func viewWillAppear(animated: Bool) {
    tableView.reloadData()
  }
  
  // MARK: - Table view data source
  
  func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return shops.count + 1
  }
  
  func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return 82
  }
  
  func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
    if (self.tableView.respondsToSelector(Selector("setSeparatorInset:"))) {
      self.tableView.separatorInset = UIEdgeInsetsZero
    }
    
    if (self.tableView.respondsToSelector(Selector("setLayoutMargins:"))) {
      self.tableView.layoutMargins = UIEdgeInsetsZero
    }
    
    if (cell.respondsToSelector(Selector("setLayoutMargins:"))) {
      cell.layoutMargins = UIEdgeInsetsZero
    }
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell: HotelMessageCell = tableView.dequeueReusableCellWithIdentifier(HotelMessageCell.reuseIdentifier()) as! HotelMessageCell
    
    if indexPath.row == 0 {
//      var version = ""
//      if let info = NSBundle.mainBundle().infoDictionary?["CFBundleShortVersionString"] as? String {
//        version = info
//      }
//      var build = ""
//      if let info = NSBundle.mainBundle().infoDictionary?["CFBundleVersion"] as? String {
//        build = info
//      }
//      cell.tips.text = "Version \(version) Build \(build)"
      cell.name.text = "软件反馈"
      cell.logo.setImage(UIImage(named: "img_hotel_zhanwei"), forState: .Normal)
      return cell
    }
  
    let shop = shops[indexPath.row - 1]
    
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
      cell.logo.sd_setImageWithURL(logoURL, forState: .Normal, placeholderImage: placeholderImage, options: SDWebImageOptions.ProgressiveDownload | SDWebImageOptions.RetryFailed, completed: nil)
      
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
  
  func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 150.0
  }
  
  func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let screeWidth = UIScreen.mainScreen().bounds.width
    let headerView = UIView(frame: CGRectMake(0.0, 0.0, screeWidth * 0.75, 150.0))
    let imageView = UIImageView(image: UIImage(named: "bg_cebian"))
    imageView.frame = CGRectMake(0.0, 0.0, screeWidth * 0.75, 150.0)
    headerView.addSubview(imageView)
    let title = UILabel(frame: CGRectMake(30.0, 30.0, 120.0, 30.0))
    title.textColor = UIColor.whiteColor()
    title.text = "消息中心"
    headerView.addSubview(title)
    return headerView
  }
  
  // MARK: - Table view delegate
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    tableView.deselectRowAtIndexPath(indexPath, animated: true)
    
    if indexPath.row == 0 {
//      sendLogEmail()
      let chatVC = JSHChatVC(chatType: ChatType.OldSession)
      chatVC.shopID = "31415"
      chatVC.shopName = "软件反馈"
      if let navigationController = self.sideMenuViewController.contentViewController as? UINavigationController {
        self.sideMenuViewController.hideMenuViewController()
        navigationController.pushViewController(chatVC, animated: false)
      }
      return
    }
    
    let shop = shops[indexPath.row - 1]
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
  
  func dismissSelf() -> Void {
    dismissViewControllerAnimated(true, completion: nil)
  }
  
  func fetchShops() {
    ZKJSHTTPSessionManager.sharedInstance().getAllShopInfoWithPage(1, key: "", isDesc: true, success: { [unowned self] (task: NSURLSessionDataTask!, responseObject: AnyObject!) -> Void in
      for shopInfo in responseObject as! [NSDictionary] {
        var shop = [String: String]()
        shop["fullname"] = shopInfo["fullname"] as? String
        shop["shopid"] = shopInfo["shopid"] as? String
        self.shops.append(shop)
      }
      self.tableView.reloadData()
      }) { (task: NSURLSessionDataTask!, error: NSError!) -> Void in
        
    }
  }
  
  func sendLogEmail() {
    let mailComposer = MFMailComposeViewController()
    mailComposer.mailComposeDelegate = self
    mailComposer.setSubject("意见反馈")
    let toRecipients = ["hanton@zkjinshi.com"]
    mailComposer.setToRecipients(toRecipients)
    let logsDirectory = LogManager.sharedInstance().logsDirectory()
    
    let fileManager = NSFileManager.defaultManager()
    var error: NSError? = nil
    let files = NSFileManager.defaultManager().contentsOfDirectoryAtPath(logsDirectory, error: &error)
    if files != nil {
      let sortedFileNames = sorted(files!) { fileName1, fileName2 in
        let file1Path = logsDirectory.stringByAppendingPathComponent(fileName1 as! String)
        let file2Path = logsDirectory.stringByAppendingPathComponent(fileName2 as! String)
        let attr1 = fileManager.attributesOfItemAtPath(file1Path, error: nil)
        let attr2 = fileManager.attributesOfItemAtPath(file2Path, error: nil)
        let file1Date = attr1![NSFileModificationDate] as! NSDate
        let file2Date = attr2![NSFileModificationDate] as! NSDate
        let result = file1Date.compare(file2Date)
        return result == NSComparisonResult.OrderedDescending
      }
      let logPath = logsDirectory.stringByAppendingPathComponent(sortedFileNames.first as! String)
      println(logPath)
      var version = ""
      if let info = NSBundle.mainBundle().infoDictionary?["CFBundleShortVersionString"] as? String {
        version = info
      }
      var build = ""
      if let info = NSBundle.mainBundle().infoDictionary?["CFBundleVersion"] as? String {
        build = info
      }
      let logData = NSData(contentsOfFile: logPath)
      mailComposer.addAttachmentData(logData, mimeType: "text/plain", fileName: "SVIP.log")
      mailComposer.setMessageBody("来自用户:\(JSHStorage.baseInfo().username)\n账号:\(JSHStorage.baseInfo().phone)\n版本:\(version) (\(build))", isHTML: false)
      if MFMailComposeViewController.canSendMail() {
        presentViewController(mailComposer, animated: true, completion: nil)
      } else {
        showSendMailErrorAlert()
      }
    }
  }
  
  func formatMessage(message: XHMessage) -> [String: String] {
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
  
  func showSendMailErrorAlert() {
    let sendMailErrorAlert = UIAlertView(title: "Could Not Send Email", message: "Your device could not send e-mail.  Please check e-mail configuration and try again.", delegate: self, cancelButtonTitle: "OK")
    sendMailErrorAlert.show()
  }
  
  // MARK: - MFMailComposeViewControllerDelegate Method
  
  func mailComposeController(controller: MFMailComposeViewController!, didFinishWithResult result: MFMailComposeResult, error: NSError!) {
    controller.dismissViewControllerAnimated(true, completion: nil)
  }

}
