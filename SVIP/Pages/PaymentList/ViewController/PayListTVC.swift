//
//  PayListTVC.swift
//  SVIP
//
//  Created by AlexBang on 16/3/19.
//  Copyright © 2016年 zkjinshi. All rights reserved.
//

import UIKit

class PayListTVC: UITableViewController {
  var orderStatus: FacePayOrderStatus!
  var paylistArr = [PaylistmModel]()
  

  override func viewDidLoad() {
      super.viewDidLoad()
    tableView.registerNib(UINib(nibName: PaylistCell.nibName(), bundle: nil),
        forCellReuseIdentifier: PaylistCell.reuseIdentifier())
    tableView.registerNib(UINib(nibName: TableViewCellNoData.nibName(), bundle: nil),
        forCellReuseIdentifier: TableViewCellNoData.reuseIdentifier())

    if orderStatus == .NotPaid {
      self.title = "支付确认"
    } else if orderStatus == .Paid {
      self.title = "支付记录"
    }
    tableView.tableFooterView = UIView()
    tableView.separatorStyle  = .None
    tableView.backgroundColor = UIColor(hex: "#f0f0f0")
    
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "paymentResult", name: FACEPAY_RESULT_NOTIFICATION, object: nil)

  }

  override func loadView() {
    NSBundle.mainBundle().loadNibNamed("PayListTVC", owner:self, options:nil)
  }



  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(true)
    self.showHUDInView(view, withLoading: "")
    
    loadOrderList()
  }

  override func didReceiveMemoryWarning() {
      super.didReceiveMemoryWarning()
      // Dispose of any resources that can be recreated.
  }

  func loadOrderList() {
    HttpService.sharedInstance.userPaylistInfo(orderStatus, page: 0) {[weak self] (data,error) -> Void in
      guard let strongSelf = self else {
        return
      }
      if let _ = error {
        strongSelf.hideHUD()
        
      } else {
        if let json = data {
          strongSelf.paylistArr = json
          strongSelf.tableView.reloadData()
          strongSelf.hideHUD()
          if json.count > 0 && strongSelf.orderStatus == .NotPaid {
            AccountManager.sharedInstance().savePayCreatetime(json[0].createtime)
          }
        }
      }
      
    }
  }

  // MARK: - Table view data source
 
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
      return 2
  }

  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return section == 0 ? paylistArr.count : (paylistArr.count > 0 ? 0 : 1)
  }

  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    if indexPath.section == 0 {
      let cell = tableView.dequeueReusableCellWithIdentifier(PaylistCell.reuseIdentifier(), forIndexPath: indexPath) as! PaylistCell
      let pay:PaylistmModel = paylistArr[indexPath.row]
      cell.setData(pay)
      cell.selectionStyle = UITableViewCellSelectionStyle.None
      return cell
    } else {
      let cell = tableView.dequeueReusableCellWithIdentifier(TableViewCellNoData.reuseIdentifier(), forIndexPath: indexPath) as! TableViewCellNoData
      cell.setTips("没有待支付记录")
      cell.selectionStyle = UITableViewCellSelectionStyle.None
      return cell
    }
  }
  
  override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return PaylistCell.height()
  }
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    if indexPath.section != 0 {
      return
    }
    let pay = paylistArr[indexPath.row]
    if pay.status == .NotPaid {
      let vc = PayInfoVC()
      vc.payInfo = pay
      
      vc.modalPresentationStyle = .OverFullScreen
      self.presentViewController(vc, animated: true, completion: nil)
      
    }
   }
  
  func paymentResult() {
    loadOrderList()
  }

    
}
