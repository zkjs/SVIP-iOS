//
//  HotelOrderDetailTVC.swift
//  SVIP
//
//  Created by AlexBang on 16/1/3.
//  Copyright © 2016年 zkjinshi. All rights reserved.
//

import UIKit

let kGotoOrderList = "kGotoOrderList"

class HotelOrderDetailTVC:  UITableViewController {
  
  @IBOutlet weak var ordernoLabel: UILabel!
  @IBOutlet weak var privilageLabel: UILabel!
  @IBOutlet weak var pendingConfirmationLabel: UILabel!
  @IBOutlet weak var invoiceLabel: UILabel!
  @IBOutlet weak var contacterLabel: UILabel!
  @IBOutlet weak var telphotoLabel: UILabel!
  @IBOutlet weak var smokingLabel: UILabel!
  @IBOutlet weak var remark: UITextView!
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
    tableView.backgroundColor = UIColor.hx_colorWithHexString("#EFEFF4")
    
    let image = UIImage(named: "ic_fanhui_orange")
    let item = UIBarButtonItem(image: image, style:.Done, target: self, action: "back")
    self.navigationItem.leftBarButtonItem = item
    loadData()
  }
  

  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    
    navigationController?.navigationBar.translucent = false
  }
  
  func back() {
    let appWindow = UIApplication.sharedApplication().keyWindow
    let mainTBC = MainTBC()
    mainTBC.selectedIndex = 3
    NSUserDefaults.standardUserDefaults().setBool(true, forKey: kGotoOrderList)
    let nc = BaseNC(rootViewController: mainTBC)
    appWindow?.rootViewController = nc
  }
  
  func loadData() {
    //获取订单详情
    guard let reservation_no = reservation_no else { return }
    showHUDInView(view, withLoading: "")
    ZKJSJavaHTTPSessionManager.sharedInstance().getOrderDetailWithOrderNo(reservation_no, success: { (task: NSURLSessionDataTask!, responseObject: AnyObject!) -> Void in
      print(responseObject)
      self.hideHUD()
      if let dic = responseObject as? NSDictionary {
        print(dic)
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
    privilageLabel.text = orderDetail.privilegeName
    ordernoLabel.text = orderDetail.orderno
    if orderDetail.orderedby == "" {
      contacterLabel.text = "暂未填写信息"
    } else {
      contacterLabel.text = orderDetail.orderedby
    }
    
    if orderDetail.telephone == "" {
      telphotoLabel.text = "暂未填写手机号"
    } else {
      telphotoLabel.text = orderDetail.telephone
    }
    
    if orderDetail.company == "" {
      invoiceLabel.text = "暂未填写"
    } else {
      invoiceLabel.text = orderDetail.company
    }
    
    remark.editable = false
    if orderDetail.nosmoking == 0 {
      smokingLabel.text = "否"
    } else {
      smokingLabel.text = "是"
    }
    
    if orderDetail.paytype == 1 {
      payTypeLabel.text = "在线支付"
      payButton.setTitle("￥\(orderDetail.roomprice)立即支付", forState: UIControlState.Normal)
      payButton.addTarget(self, action: "pay:", forControlEvents: UIControlEvents.TouchUpInside)
      cancleButton.addTarget(self, action: "cancle:", forControlEvents: UIControlEvents.TouchUpInside)
    }
    if orderDetail.paytype == 2 {
       payTypeLabel.text = "到店支付"
    }
    if orderDetail.paytype == 3 {
      payTypeLabel.text = "挂账"
    }
    if orderDetail.paytype == 0 {
      payButton.hidden = true
      pendingConfirmationLabel.text = "  请您核对订单，并确认。如需修改，请联系客服"
    }
    if orderDetail.paytype != 1 {
      payButton.addTarget(self, action: "confirm:", forControlEvents: UIControlEvents.TouchUpInside)
      cancleButton.addTarget(self, action: "cancle:", forControlEvents: UIControlEvents.TouchUpInside)
    }
    
  }
  
  func confirm(sender:UIButton) {
      showHUDInView(view, withLoading: "")
      ZKJSJavaHTTPSessionManager.sharedInstance().confirmOrderWithOrderNo(orderDetail.orderno,status:2, success: { (task: NSURLSessionDataTask!, responsObjects:AnyObject!) -> Void in
        if let dic = responsObjects as? NSDictionary {
          self.orderno = dic["data"] as! String
          if let result = dic["result"] as? NSNumber {
            if result.boolValue == true {
              ZKJSTool.showMsg("订单已确认")
              self.hideHUD()
              self.navigationController?.popViewControllerAnimated(true)
            }
          }
        }
        }) { (task: NSURLSessionDataTask!, eeror: NSError!) -> Void in
          
      }
    
    
  }
  
  func cancle(sender:UIButton) {
    showHUDInTableView(tableView, withLoading: "")
    ZKJSJavaHTTPSessionManager.sharedInstance().cancleOrderWithOrderNo(orderDetail.orderno, success: { (task: NSURLSessionDataTask!, responsObjects:AnyObject!)-> Void in
      if let dic = responsObjects as? NSDictionary {
        self.orderno = dic["data"] as! String
        if let result = dic["result"] as? NSNumber {
          if result.boolValue == true {
            self.navigationController?.popViewControllerAnimated(true)
            self.hideHUD()
          }
        }
      }
      }) { (task: NSURLSessionDataTask!, eeror: NSError!) -> Void in
        
    }
  }
  
  func pay(sender:UIButton) {
    if orderDetail.orderstatus == "待支付" && orderDetail.paytype.integerValue == 1 {
      let payVC = BookPayVC()
      payVC.type = .Push
      payVC.bkOrder = orderDetail
      navigationController?.pushViewController(payVC, animated: true)
    } else {
      showHUDInView(view, withLoading: "")
      ZKJSJavaHTTPSessionManager.sharedInstance().confirmOrderWithOrderNo(orderDetail.orderno,status:2, success: { (task: NSURLSessionDataTask!, responseObject: AnyObject!) -> Void in
        print(responseObject)
        self.hideHUD()
        self.navigationController?.popViewControllerAnimated(true)
        }, failure: { (task: NSURLSessionDataTask!, error: NSError!) -> Void in
          print(error)
          self.hideHUD()
      })
    }
    
  }
  
  @IBAction func comments(sender: AnyObject) {
    let vc = OrderDetailsVC()
    vc.order = self.orderDetail
    navigationController?.pushViewController(vc, animated: true)
  }
  
  override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    //待评价
    if indexPath.section == 5 {
      if orderDetail.orderstatus != nil {
        if  orderDetail.orderstatus != "待评价"  {
          return 0.0
        }
      }
    }
    
    // 确定
    if indexPath.section == 6  {//确认
      if orderDetail.orderstatus != nil {
        if orderDetail.orderstatus == "待确认" || orderDetail.orderstatus == "待支付" {
          
        } else {
          return 0.0
        }
      }
    }
    
    // 取消
    if indexPath.section == 7 {//取消
      if orderDetail.orderstatus != nil {
        if orderDetail.orderstatus == "待处理" || orderDetail.orderstatus == "待确认" || orderDetail.orderstatus == "待支付" || orderDetail.orderstatus == "已确认" {
          
        } else {
          return 0.0
        }
      }
    }
    
    return super.tableView(tableView, heightForRowAtIndexPath: indexPath)
  }
  
  override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    if section == 0 {
      return 0
    }
    // 确定
    if section == 6  {//确认
      if orderDetail.orderstatus != nil {
        if orderDetail.orderstatus == "待确认" || orderDetail.orderstatus == "待支付" {
          
        } else {
          return 0.0
        }
      }
    }
    
    // 取消
    if section == 7 {//取消
      if orderDetail.orderstatus != nil {
        if orderDetail.orderstatus == "待处理" || orderDetail.orderstatus == "待确认" || orderDetail.orderstatus == "待支付" || orderDetail.orderstatus == "已确认" {
          
        } else {
          return 0.0
        }
      }
    }

    return 20
  }
  
  override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let header = UIView()
    header.backgroundColor = UIColor.clearColor()
    return header
  }
  

}
