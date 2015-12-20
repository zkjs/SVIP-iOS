//
//  CustomerServiceTVC.swift
//  SVIP
//
//  Created by AlexBang on 15/11/23.
//  Copyright © 2015年 zkjinshi. All rights reserved.
//

import UIKit

class CustomerServiceTVC: UITableViewController {
  var shopID = String()
  var servicerArr = [ServicerModel]()
    override func viewDidLoad() {
        super.viewDidLoad()
      title = "我的专属客服"
      let nibName = UINib(nibName: CustomerServiceCell.nibName(), bundle: nil)
      tableView.registerNib(nibName, forCellReuseIdentifier: CustomerServiceCell.reuseIdentifier())
      tableView.tableFooterView = UIView()
      loadData()


    }
  func loadData() {
    ZKJSHTTPSessionManager.sharedInstance().getMerchanCustomerServiceListWithShopID(shopID, success: { (task:NSURLSessionDataTask!, responsObject:AnyObject!) -> Void in
      let dic = responsObject as! NSDictionary
     if  let array = dic["data"] as? NSArray {
      for dic in array {
        let servicer = ServicerModel(dic: dic as![String:AnyObject])
        self.servicerArr.append(servicer)
      }
      self.tableView.reloadData()
      }
      }) { (task: NSURLSessionDataTask!, error: NSError!) -> Void in
      
    }
  }
  override func loadView() {
    NSBundle.mainBundle().loadNibNamed("CustomerServiceTVC", owner:self, options:nil)
  }
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(true)
    tableView.reloadData()
  }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return servicerArr.count
    }
  override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return CustomerServiceCell.height()
  }

  
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(CustomerServiceCell.reuseIdentifier(), forIndexPath: indexPath) as! CustomerServiceCell
      let servicer = servicerArr[indexPath.row]
      cell.setData(servicer)
      cell.selectionStyle = UITableViewCellSelectionStyle.None
        return cell
    }
  
 
}
