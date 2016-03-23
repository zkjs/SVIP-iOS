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
      let nibName = UINib(nibName: PaylistCell.nibName(), bundle: nil)
      tableView.registerNib(nibName, forCellReuseIdentifier: PaylistCell.reuseIdentifier())

      if orderStatus == .NotPaid {
        self.title = "支付确认"
      } else if orderStatus == .Paid {
        self.title = "支付记录"
      }
      self.tableView.tableFooterView = UIView()
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
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return paylistArr.count
    }


    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
      let cell = tableView.dequeueReusableCellWithIdentifier(PaylistCell.reuseIdentifier(), forIndexPath: indexPath) as! PaylistCell
      let pay:PaylistmModel = paylistArr[indexPath.row]
      cell.setData(pay)
      cell.selectionStyle = UITableViewCellSelectionStyle.None
      return cell
    }
  
  override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return PaylistCell.height()
  }
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    let pay = paylistArr[indexPath.row]
    if pay.status == .NotPaid {
      let vc = PayInfoVC()
      let childView = vc.view
      vc.payInfo = pay
      self.view.addSubview(childView)
      self.addChildViewController(vc)
      vc.payInfo = pay
      vc.didMoveToParentViewController(self)
      vc.payInfoDismissClosure = {(bool) -> Void in
        if bool == true {
          self.tableView.scrollEnabled = true
        }
      }
      self.tableView.scrollEnabled = false
      childView.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y-100, self.view.frame.size.width, self.view.frame.size.height+100)
    }
   }
  
  func paymentResult() {
    loadOrderList()
  }

    
}
