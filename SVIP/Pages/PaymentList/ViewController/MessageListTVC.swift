//
//  PayListTVC.swift
//  SVIP
//
//  Created by AlexBang on 16/3/19.
//  Copyright © 2016年 zkjinshi. All rights reserved.
//

import UIKit

class MessageListTVC: UITableViewController {
  var payList = [PaylistmModel]()
  var messageList = [PushMessage]()
  
  let shrinkDismissAnimationController = ShrinkDismissAnimationController()
  
  enum Sections:Int {
    case Payment = 0, Message, NoData
  }

  override func viewDidLoad() {
      super.viewDidLoad()
    tableView.registerNib(UINib(nibName: MesssageListCell.nibName(), bundle: nil),
        forCellReuseIdentifier: MesssageListCell.reuseIdentifier())
    tableView.registerNib(UINib(nibName: TableViewCellNoData.nibName(), bundle: nil),
        forCellReuseIdentifier: TableViewCellNoData.reuseIdentifier())


    self.title = "消息"

    tableView.tableFooterView = UIView()
    tableView.separatorStyle  = .None
    tableView.backgroundColor = UIColor(hex: "#f0f0f0")
    
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "paymentResult", name: FACEPAY_RESULT_NOTIFICATION, object: nil)

  }

  override func loadView() {
    NSBundle.mainBundle().loadNibNamed("MessageListTVC", owner:self, options:nil)
  }


  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(true)
    self.showHUDInView(view, withLoading: "")
    
    
    if let msgs = PushMessage.query("userid == '\(TokenPayload.sharedInstance.userID!)'", order: ["timestamp":"DESC"], limit: nil) as? [PushMessage] {
      messageList = msgs
      if msgs.count > PushMessage.MAX_CACHE_COUNT {
        for i in PushMessage.MAX_CACHE_COUNT ..< msgs.count {
          msgs[i].remove()
        }
        PushMessage.saveAllChanges()
        messageList = Array(msgs[0..<PushMessage.MAX_CACHE_COUNT])
      }
    }
    
    loadOrderList()
  }

  override func didReceiveMemoryWarning() {
      super.didReceiveMemoryWarning()
      // Dispose of any resources that can be recreated.
  }

  func loadOrderList() {
    HttpService.sharedInstance.userPaylistInfo(.NotPaid, page: 0) {[weak self] (data,error) -> Void in
      guard let strongSelf = self else {
        return
      }
      if let _ = error {
        strongSelf.hideHUD()
        
      } else {
        if let json = data {
          strongSelf.payList = json
          strongSelf.tableView.reloadData()
          strongSelf.hideHUD()
          if json.count > 0 {
            AccountManager.sharedInstance().savePayCreatetime(json[0].createtime)
          }
        }
      }
      
    }
  }

  // MARK: - Table view data source
 
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
      return 3
  }

  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    switch section {
    case Sections.Payment.rawValue:
      return payList.count
    case Sections.Message.rawValue:
      return messageList.count
    default:
      return (payList.count + messageList.count) > 0 ? 0 : 1
    }
  }

  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    if indexPath.section == Sections.Payment.rawValue {
      let cell = tableView.dequeueReusableCellWithIdentifier(MesssageListCell.reuseIdentifier(), forIndexPath: indexPath) as! MesssageListCell
      let pay:PaylistmModel = payList[indexPath.row]
      cell.configCellWithPayInfo(pay)
      cell.selectionStyle = UITableViewCellSelectionStyle.None
      return cell
    } else if indexPath.section == Sections.Message.rawValue {
      let cell = tableView.dequeueReusableCellWithIdentifier(MesssageListCell.reuseIdentifier(), forIndexPath: indexPath) as! MesssageListCell
      let msg = messageList[indexPath.row]
      cell.configCellWithPushMessage(msg)
      cell.selectionStyle = UITableViewCellSelectionStyle.None
      return cell
    } else {
      let cell = tableView.dequeueReusableCellWithIdentifier(TableViewCellNoData.reuseIdentifier(), forIndexPath: indexPath) as! TableViewCellNoData
      cell.setTips("没有消息记录")
      cell.selectionStyle = UITableViewCellSelectionStyle.None
      return cell
    }
  }
  
  override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return MesssageListCell.height()
  }
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    if indexPath.section == Sections.Payment.rawValue {
      let pay = payList[indexPath.row]
      if pay.status == .NotPaid {
        let vc = PayInfoVC()
        vc.payInfo = pay
        
        vc.transitioningDelegate = self
        vc.modalPresentationStyle = .Custom
        self.presentViewController(vc, animated: false, completion: nil)
      }
    } else if indexPath.section == Sections.Message.rawValue {
      let msg = messageList[indexPath.row]
      let vc = PushMessageVC()
      vc.pushInfo = msg
      
      vc.modalPresentationStyle = .Custom
      self.presentViewController(vc, animated: false, completion: nil)
    }
  }
  
  func paymentResult() {
    loadOrderList()
  }

    
}

extension MessageListTVC: UIViewControllerTransitioningDelegate {
  func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    return shrinkDismissAnimationController
  }
}
