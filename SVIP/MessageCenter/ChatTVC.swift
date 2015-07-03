//
//  ChatTVC.swift
//  SVIP
//
//  Created by Hanton on 6/29/15.
//  Copyright (c) 2015 zkjinshi. All rights reserved.
//

import UIKit
import AVFoundation
import Foundation

class ChatTVC: XHMessageTableViewController, XHMessageTableViewControllerDelegate, XHMessageTableViewCellDelegate, XHAudioPlayerHelperDelegate, AVAudioPlayerDelegate {
  
  let bookingOrder: BookingOrder
  let currentSelectedCell = XHMessageTableViewCell()
  
  var activityIndicator = UIActivityIndicatorView()
  var messageReceiver = ""
  var employerID = ""
  var employerList = []
  var senderID = ""
  
  // MARK: - Init
  init(bookingOrder: BookingOrder?) {
    self.bookingOrder = bookingOrder!
    super.init(nibName: nil, bundle: nil)
  }
  
  required init(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    allowsSendFace = false
    
    super.viewDidLoad()
    
    title = "聊天"
    
    messageSender = "我";
    messageReceiver = "556825758efb0";
    employerID = "paipai990";
    employerList = NSMutableArray(array: [employerID])
    messageReceiver = employerID;
    senderID = "557cff54a9a97";
    
    var shareMenuItems = [XHShareMenuItem]()
    let plugIcons = ["sharemore_pic", "sharemore_video"]
    let plugTitles = ["照片", "拍摄"]
    for plugIcon in plugIcons {
      let shareMenuItem = XHShareMenuItem(normalIconImage: UIImage(named: plugIcon), title: plugTitles[find(plugIcons, plugIcon)!])
      shareMenuItems.append(shareMenuItem)
    }
    self.shareMenuItems = shareMenuItems
    shareMenuView.reloadData()
    
//    loadDataSource()
    setupNotification()
    requestWaiter()
  }
  
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    
    activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
    activityIndicator.center = CGPointMake(view.center.x, (view.frame.size.height - 64.0) / 2.0)
    activityIndicator.hidesWhenStopped = true
    view.addSubview(activityIndicator)
    activityIndicator.startAnimating()
  }
  
  override func viewDidDisappear(animated: Bool) {
    super.viewDidDisappear(animated)
    
//    saveDataSource()
  }
  
  deinit {
    XHAudioPlayerHelper.shareInstance().setDelegate(nil)
    NSNotificationCenter.defaultCenter().removeObserver(self)
  }
  
  // MARK: - Private Method
  func setupNotification() {
    
  }
  
  func requestWaiter() {
    
  }
  
  func sendTextMessage(text: String) {
    
  }
  
  func sendImageMessage(photo: UIImage) {
    
  }
  
  func sendVoiceMessage(voicePath: String) {
    
  }
  
  // MARK: - XHMessageTableViewControllerDelegate
  override func didSendText(text: String!, fromSender sender: String!, onDate date: NSDate!) {
    sendTextMessage(text)
    var message = XHMessage(text: text, sender: sender, timestamp: date)
    message.avatar = UIImage(named: "ic_home_nor")
    
    addMessage(message)
    finishSendMessageWithBubbleMessageType(.Text)
  }
  
  override func didSendPhoto(photo: UIImage!, fromSender sender: String!, onDate date: NSDate!) {
    sendImageMessage(photo)
    var message = XHMessage(photo: photo, thumbnailUrl: nil, originPhotoUrl: nil, sender: sender, timestamp: date)
    message.avatar = UIImage(named: "ic_home_nor")
    
    addMessage(message)
    finishSendMessageWithBubbleMessageType(.Photo)
  }
  
  override func didSendVoice(voicePath: String!, voiceDuration: String!, fromSender sender: String!, onDate date: NSDate!) {
    sendTextMessage(voicePath)
    var message = XHMessage(voicePath: voicePath, voiceUrl: nil, voiceDuration: voiceDuration, sender: sender, timestamp: date, isRead: true)
    message.avatar = UIImage(named: "ic_home_nor")
    
    addMessage(message)
    finishSendMessageWithBubbleMessageType(.Voice)
  }
  
  // MARK: - XHMessageTableViewCellDelegate
  override func multiMediaMessageDidSelectedOnMessage(message: XHMessageModel!, atIndexPath indexPath: NSIndexPath!, onMessageTableViewCell messageTableViewCell: XHMessageTableViewCell!) {
    var displayVC: UIViewController
    switch message.messageMediaType() {
    case .Photo:
      var messageDisplayTextView = XHDisplayMediaViewController()
      messageDisplayTextView.message = message
      displayVC = messageDisplayTextView
    case .Voice:
      message.setIsRead!(true)
      messageTableViewCell.messageBubbleView.voiceUnreadDotImageView.hidden = true
      
//      XHAudioPlayerHelper.shareInstance().setDelegate((NSFileManagerDelegate)self)
    default:
      break
    }
  }
  
}
