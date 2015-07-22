//
//  MessageCenterTVC.swift
//  SVIP
//
//  Created by Hanton on 6/27/15.
//  Copyright (c) 2015 zkjinshi. All rights reserved.
//

import UIKit
import MessageUI

class MessageCenterTVC: UITableViewController, MFMailComposeViewControllerDelegate {
  
  // MARK: - Life cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    
    title = "消息中心"
    
    navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Stop, target: self, action: NSSelectorFromString("dismissSelf"))
    
    let cellNib = UINib(nibName: HotelMessageCell.nibName(), bundle: nil)
    tableView.registerNib(cellNib, forCellReuseIdentifier: HotelMessageCell.reuseIdentifier())
    tableView.tableFooterView = UIView()
  }
  
  override func viewWillAppear(animated: Bool) {
    tableView.reloadData()
  }
  
  // MARK: - Table view data source
  
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 2
  }
  
  override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return 82
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
  let cell: HotelMessageCell = tableView.dequeueReusableCellWithIdentifier(HotelMessageCell.reuseIdentifier()) as! HotelMessageCell
    
    if indexPath.row == 0 {
      var version = ""
      if let info = NSBundle.mainBundle().infoDictionary?["CFBundleShortVersionString"] as? String {
        version = info
      }
      var build = ""
      if let info = NSBundle.mainBundle().infoDictionary?["CFBundleVersion"] as? String {
        build = info
      }
      cell.name.text = "意见反馈"
      cell.tips.text = "Version \(version) Build \(build)"
      cell.logo.setImage(UIImage(named: "ic_app"), forState: .Normal)
      return cell
    }
  
    cell.name.text = "长沙芙蓉国温德姆至尊豪廷大酒店"
    
//    if let chatMessage = StorageManager.sharedInstance().lastChatMessage("120") {
//      cell.tips.text = chatMessage["message"]
//      cell.date.text = chatMessage["date"]
//    }
    
    if let chatMessage = Persistence.sharedInstance().fetchLastMessageWithShopID("120") {
      let message = formatMessage(chatMessage)
      cell.tips.text = message["message"]
      cell.date.text = message["date"]
    }
    
    if let order = StorageManager.sharedInstance().lastOrder() {
      if let status = order.status {
        switch status {
          case "0":
          cell.status.text = "可取消"
          case "1":
          cell.status.text = "已取消"
          case "2":
          cell.status.text = "已确定"
          case "3":
          cell.status.text = "已完成"
          case "5":
          cell.status.text = "已删除"
        default:
          break
        }
      }
    }
    
    if UIApplication.sharedApplication().applicationIconBadgeNumber > 0 {
      cell.logo.badgeString = String(UIApplication.sharedApplication().applicationIconBadgeNumber)
    }
    
    return cell
  }
  
  // MARK: - Table view delegate
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    tableView.deselectRowAtIndexPath(indexPath, animated: true)
    
    if indexPath.row == 0 {
      sendLogEmail()
      return
    }
    
    let chatVC = JSHChatVC(chatType: ChatType.OldSession)
    chatVC.shopID = "120"
    navigationController?.pushViewController(chatVC, animated: true)
  }
  
  // MARK: - Private Method
  func dismissSelf() -> Void {
    dismissViewControllerAnimated(true, completion: nil)
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
      mailComposer.setMessageBody("来自用户:\(JSHStorage.baseInfo().name)\n账号:\(JSHStorage.baseInfo().phone)\n版本:\(version) (\(build))", isHTML: false)
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
