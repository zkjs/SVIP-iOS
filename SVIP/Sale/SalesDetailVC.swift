//
//  SalesDetailVC.swift
//  SVIP
//
//  Created by Hanton on 12/17/15.
//  Copyright © 2015 zkjinshi. All rights reserved.
//

import UIKit

class SalesDetailVC: UIViewController {
  
  @IBOutlet weak var tableView: UITableView!
  
  var salesid = ""
  var sales: SalesModel? = nil
  
  
  // MARK: - View Lifecycle
  
  override func loadView() {
    NSBundle.mainBundle().loadNibNamed("SalesDetailVC", owner:self, options:nil)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupView()
    loadData()
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    
    navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: .Default)
    navigationController?.navigationBar.shadowImage = UIImage()
    navigationController?.navigationBar.translucent = true
    navigationController?.view.backgroundColor = UIColor.clearColor()
    automaticallyAdjustsScrollViewInsets = false
    navigationController?.navigationBar.tintColor = UIColor.whiteColor()
  }
  
  override func viewWillDisappear(animated: Bool) {
    super.viewWillDisappear(animated)
    
    navigationController?.navigationBarHidden = false
    navigationController?.navigationBar.tintColor = UIColor.ZKJS_mainColor()
    navigationController?.navigationBar.translucent = false
  }
  
  func setupView() {
    let phoneNib = UINib(nibName: PhoneCell.nibName(), bundle: nil)
    tableView.registerNib(phoneNib, forCellReuseIdentifier: PhoneCell.reuseIdentifier())
    
    let ratingNib = UINib(nibName: RatingCell.nibName(), bundle: nil)
    tableView.registerNib(ratingNib, forCellReuseIdentifier: RatingCell.reuseIdentifier())
    
    tableView.tableFooterView = UIView()
  }
  
  func loadData() {
    ZKJSHTTPSessionManager.sharedInstance().getSalesWithID(salesid, success: { (task: NSURLSessionDataTask!, responseObject: AnyObject!) -> Void in
      print(responseObject)
      if let data = responseObject as? [String: AnyObject] {
        if let set = data["set"] as? NSNumber {
          if set.boolValue == false {
            if let err = data["err"] as? NSNumber {
              if err.integerValue == 404 {
                self.showHint("此销售不存在")
              }
            }
          } else {
            self.sales = SalesModel(dictionary: data)
            self.tableView.reloadData()
          }
        }
      }
      }) { (task: NSURLSessionDataTask!, error: NSError!) -> Void in
        
    }
  }
  
  @IBAction func chat(sender: AnyObject) {
    guard let sales = self.sales else { return }
    let vc = ChatViewController(conversationChatter: sales.userid, conversationType: .eConversationTypeChat)
    vc.title = sales.username
    // 扩展字段
    let userName = AccountManager.sharedInstance().userName
    let ext = ["shopId": sales.shopid.stringValue,
      "shopName": sales.shop_name,
      "toName": sales.username,
      "fromName": userName]
    vc.conversation.ext = ext
    navigationController?.pushViewController(vc, animated: true)
  }
  
}

extension SalesDetailVC: UITableViewDataSource, UITableViewDelegate {
  
  func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 2
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if sales == nil {
      return 0
    }
    return 1
  }
  
  func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    if section == 0 {
      return 262.0
    }
    return 0.0
  }
  
  func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    if section == 0 {
      let headerView = NSBundle.mainBundle().loadNibNamed("SalesDetailHeaderView", owner: self, options: nil).first as! SalesDetailHeaderView
      if let sales = self.sales {
        let url = NSURL(string: kImageURL)?.URLByAppendingPathComponent("/uploads/users/\(sales.userid).jpg")
        headerView.avatarImageView.sd_setImageWithURL(url)
        headerView.nameLabel.text = sales.username
        headerView.shopNameLabel.text = sales.shop_name
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        if let date = dateFormatter.dateFromString(sales.lasttime) {
          dateFormatter.dateFormat = "M月d日 hh:mm"
          let lastLogin = dateFormatter.stringFromDate(date)
          headerView.lastLoginLabel.text = "最近 \(lastLogin) 在线"
        }
      }
      return headerView
    }
    return UIView()
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    if indexPath.section == 0 {
      let cell = tableView.dequeueReusableCellWithIdentifier(PhoneCell.reuseIdentifier(), forIndexPath: indexPath) as! PhoneCell
      if let data = sales {
        cell.setData(data)
      }
      return cell
    } else if indexPath.section == 1 {
      let cell = tableView.dequeueReusableCellWithIdentifier(RatingCell.reuseIdentifier(), forIndexPath: indexPath) as! RatingCell
      if let data = sales {
        cell.setData(data)
      }
      return cell
    }
    return UITableViewCell()
  }
  
}
