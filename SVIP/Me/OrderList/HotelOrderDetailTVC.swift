//
//  HotelOrderDetailTVC.swift
//  SVIP
//
//  Created by AlexBang on 16/1/3.
//  Copyright © 2016年 zkjinshi. All rights reserved.
//

import UIKit

class HotelOrderDetailTVC:  UITableViewController {
  
  @IBOutlet weak var pendingConfirmationLabel: UILabel!
  @IBOutlet weak var invoiceLabel: UILabel!
  @IBOutlet weak var contacterLabel: UILabel!
  @IBOutlet weak var telphotoLabel: UILabel!
  @IBOutlet weak var smokingLabel: UILabel!
  @IBOutlet weak var breakbreastLabel: UILabel!
  @IBOutlet weak var arrivateLabel: UILabel!
  @IBOutlet weak var roomTypeLabel: UILabel!
  @IBOutlet weak var roomsCountLabel: UILabel!
  @IBOutlet weak var payTypeLabel: UILabel!
  @IBOutlet weak var payButton: UIButton!
  @IBOutlet weak var cancleButton: UIButton!
  
  var reservation_no: String!
  var orderno: String!
  var orderDetail = OrderDetailModel()
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    loadData()
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    
    navigationController?.navigationBar.translucent = false
  }
  
  func loadData() {
    showHUDInView(view, withLoading: "")
    //获取订单详情
    ZKJSJavaHTTPSessionManager.sharedInstance().getOrderDetailWithOrderNo(reservation_no, success: { (task: NSURLSessionDataTask!, responseObject: AnyObject!) -> Void in
      print(responseObject)
      self.hideHUD()
      if let dic = responseObject as? NSDictionary {
        self.orderDetail = OrderDetailModel(dic: dic)
        self.tableView.reloadData()
        self.setUI()
      }
      }) { (task: NSURLSessionDataTask!, error: NSError!) -> Void in
    }
  }
  
  func setUI() {
    arrivateLabel.text = orderDetail.roomInfo
    roomTypeLabel.text = orderDetail.roomtype
    roomsCountLabel.text = String(orderDetail.roomcount)
    contacterLabel.text = orderDetail.orderedby
    telphotoLabel.text = orderDetail.telephone
    invoiceLabel.text = String(orderDetail.isinvoice)
    if orderDetail.paytype == 1 {
      payTypeLabel.text = "在线支付"
      payButton.setTitle("￥\(orderDetail.roomprice)立即支付", forState: UIControlState.Normal)
    }
    if orderDetail.paytype == 0 {
      payButton.hidden = true
      pendingConfirmationLabel.text = "  请您核对订单，并确认。如需修改，请联系客服"
    }
    if orderDetail.orderstatus == "待确认" {
      payButton.addTarget(self, action: "confirm:", forControlEvents: UIControlEvents.TouchUpInside)
      cancleButton.addTarget(self, action: "cancle:", forControlEvents: UIControlEvents.TouchUpInside)
    }
  }
  
  func confirm(sender:UIButton) {
    if orderDetail.paytype == 1 {
      let vc = BookPayVC()
      vc.bkOrder = orderDetail
      navigationController?.pushViewController(vc, animated: true)
    } else {
      ZKJSJavaHTTPSessionManager.sharedInstance().confirmOrderWithOrderNo(orderDetail.orderno, success: { (task: NSURLSessionDataTask!, responsObjects:AnyObject!) -> Void in
        print(responsObjects)
        if let dic = responsObjects as? NSDictionary {
          self.orderno = dic["data"] as! String
          if let result = dic["result"] as? NSNumber {
            if result.boolValue == true {
              ZKJSTool.showMsg("订单已确认")
              self.navigationController?.popViewControllerAnimated(true)
            }
          }
        }
        }) { (task: NSURLSessionDataTask!, eeror: NSError!) -> Void in
          
      }
    }
    
  }
  
  func cancle(sender:UIButton) {
    ZKJSJavaHTTPSessionManager.sharedInstance().cancleOrderWithOrderNo(orderDetail.orderno, success: { (task: NSURLSessionDataTask!, responsObjects:AnyObject!)-> Void in
      if let dic = responsObjects as? NSDictionary {
        self.orderno = dic["data"] as! String
        if let result = dic["result"] as? NSNumber {
          if result.boolValue == true {
            self.navigationController?.popViewControllerAnimated(true)
          }
        }
      }
      }) { (task: NSURLSessionDataTask!, eeror: NSError!) -> Void in
        
    }
  }
  
  override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    // 确定
    if indexPath.section == 5 {
      if orderDetail.orderstatus != nil {
        if orderDetail.orderstatus == "已确认" || orderDetail.orderstatus == "已取消" {
          return 0.0
        }
      }
      
      if orderDetail.paytype != nil && orderDetail.paytype.integerValue == 0 {
        return 0.0
      }
    }
    
    // 取消
    if indexPath.section == 6 {
      if orderDetail.orderstatus != nil {
        if orderDetail.orderstatus == "已确认" || orderDetail.orderstatus == "已取消" {
          return 0.0
        }
      }
    }
    
    return super.tableView(tableView, heightForRowAtIndexPath: indexPath)
  }
  
}
