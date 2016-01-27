//
//  HotelOrderDetailTVC.swift
//  SVIP
//
//  Created by AlexBang on 16/1/3.
//  Copyright © 2016年 zkjinshi. All rights reserved.
//

import UIKit

let kGotoOrderList = "kGotoOrderList"

@objc protocol HotelOrderDetailTVCDelegate {
  func shouldSendTextMessage(message: String)
}

class HotelOrderDetailTVC:  UITableViewController {
  
  @IBOutlet weak var commentsButton: UIButton!
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
  @IBOutlet weak var hotelImageView: UIImageView!
  
  var delegate: HotelOrderDetailTVCDelegate? = nil
  var reservation_no: String!
  var orderno: String!
  var orderDetail = OrderDetailModel()
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    title = "订单管理"
    tableView.backgroundColor = UIColor(hexString: "#EFEFF4")
    tableView.bounces = false
    let image = UIImage(named: "ic_fanhui_orange")
    let item = UIBarButtonItem(image: image, style:.Done, target: self, action: "back")
    self.navigationItem.leftBarButtonItem = item
    loadData()
    
    if tableView.respondsToSelector(Selector("setSeparatorInset:")) {
      tableView.separatorInset = UIEdgeInsetsZero
    }
    if tableView.respondsToSelector(Selector("setLayoutMargins:")) {
      tableView.layoutMargins = UIEdgeInsetsZero
    }
  }
  

  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    navigationController?.navigationBar.translucent = false
  }
  
  override func viewWillDisappear(animated: Bool) {
    super.viewWillDisappear(animated)
    self.hideHUD()
  }
  
  override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
    
    if cell.respondsToSelector(Selector("setSeparatorInset:")) {
      cell.separatorInset = UIEdgeInsetsZero
    }
    if cell.respondsToSelector(Selector("setLayoutMargins:")) {
      cell.layoutMargins = UIEdgeInsetsZero
    }
  }
  
  func back() {
    
    if let parentVC = self.parentViewController {
      if let parentVC = parentVC as? OrderListTVC {
        self.navigationController?.popToViewController(parentVC, animated: true)
      } else  {
        let appWindow = UIApplication.sharedApplication().keyWindow
        let mainTBC = MainTBC()
        mainTBC.selectedIndex = 3
        NSUserDefaults.standardUserDefaults().setBool(true, forKey: kGotoOrderList)
        let nc = BaseNC(rootViewController: mainTBC)
        appWindow?.rootViewController = nc
      }
    }
   
    
    
    
  }
  
  func loadData() {
    //获取订单详情
    guard let reservation_no = reservation_no else { return }
    showHUDInView(view, withLoading: "")
    tableView.scrollEnabled = false
    ZKJSJavaHTTPSessionManager.sharedInstance().getOrderDetailWithOrderNo(reservation_no, success: { (task: NSURLSessionDataTask!, responseObject: AnyObject!) -> Void in

      if let dic = responseObject as? NSDictionary {
        print(dic)
        self.orderDetail = OrderDetailModel(dic: dic)
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
          self.setUI()
          self.tableView.reloadData()
        })
        
      }
      self.hideHUD()
      self.tableView.scrollEnabled = true
      }) { (task: NSURLSessionDataTask!, error: NSError!) -> Void in
        self.hideHUD()
    }
  }
  
  func setUI() {
   
    remark.text = orderDetail.remark
    arrivateLabel.text = orderDetail.roomInfo
    roomTypeLabel.text = orderDetail.roomtype
    roomsCountLabel.text = String(orderDetail.roomcount)
    privilageLabel.text = orderDetail.privilegeName
    ordernoLabel.text = orderDetail.orderno
    let url = NSURL(string: kImageURL)
    if let shoplogo = orderDetail.imgurl {
      let urlStr = url?.URLByAppendingPathComponent("\(shoplogo)")
      hotelImageView.sd_setImageWithURL(urlStr, placeholderImage: UIImage(named: "bg_zuijinliulan"))
    }
    if orderDetail.orderstatus == "已取消" {
      pendingConfirmationLabel.text = "  您的订单已取消"
      commentsButton.setTitle("已取消", forState: .Normal)
      commentsButton.enabled = false
      commentsButton.backgroundColor = UIColor.ZKJS_navegationTextColor()
    }
    if orderDetail.orderstatus == "待处理" {
      pendingConfirmationLabel.text = "  请等待客服确认"
    }else {
      pendingConfirmationLabel.text = "  请您核对订单，并确认。如需修改，请联系客服"
    }
    
    if orderDetail.orderedby == "" {
      contacterLabel.text = "暂未填写信息"
      contacterLabel.textColor = UIColor.ZKJS_textColor()
    } else {
      contacterLabel.text = orderDetail.orderedby
    }
    
    if orderDetail.telephone == "" {
      telphotoLabel.text = "暂未填写手机号"
      telphotoLabel.textColor = UIColor.ZKJS_textColor()
    } else {
      telphotoLabel.text = orderDetail.telephone
    }
    
    if orderDetail.company == "" {
      invoiceLabel.text = "暂未填写"
      invoiceLabel.textColor = UIColor.ZKJS_textColor()
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
      payTypeLabel.text = "￥\(orderDetail.roomprice) 在线支付"
      payButton.setTitle("￥\(orderDetail.roomprice)立即支付", forState: UIControlState.Normal)
      payButton.addTarget(self, action: "pay:", forControlEvents: UIControlEvents.TouchUpInside)
      cancleButton.addTarget(self, action: "cancle:", forControlEvents: UIControlEvents.TouchUpInside)
    }
    if orderDetail.paytype == 2 {
       payTypeLabel.text =  "￥\(orderDetail.roomprice)" + "到店支付"
    }
    if orderDetail.paytype == 3 {
      payTypeLabel.text =  "￥\(orderDetail.roomprice)" + "挂账"
    }
    if orderDetail.paytype == 0 {
      payTypeLabel.textColor = UIColor.ZKJS_textColor()
      payButton.hidden = true
      
    }
    if orderDetail.paytype != 1 {
      payButton.titleLabel?.text = "￥\(orderDetail.roomprice) 确认"
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
              self.sendMessageNotificationWithText("订单已确认")
              self.hideHUD()
              self.navigationController?.popViewControllerAnimated(true)
            }
          }
        }
        }) { (task: NSURLSessionDataTask!, eeror: NSError!) -> Void in
          
      }
    
    
  }
  
  func cancle(sender:UIButton) {
    let alertController = UIAlertController(title: "取消订单提示", message: "您真的要取消吗", preferredStyle: .Alert)
    let upgradeAction = UIAlertAction(title: "确认", style: .Default, handler: { (action: UIAlertAction) -> Void in
        self.cancleOrder()
    })
    alertController.addAction(upgradeAction)
    let cancelAction = UIAlertAction(title: "取消", style: .Cancel, handler: nil)
    alertController.addAction(cancelAction)
    self.presentViewController(alertController, animated: true, completion: nil)
    
     }
  
  func cancleOrder() {
    showHUDInTableView(tableView, withLoading: "")
    ZKJSJavaHTTPSessionManager.sharedInstance().cancleOrderWithOrderNo(orderDetail.orderno, success: { (task: NSURLSessionDataTask!, responsObjects:AnyObject!)-> Void in
      if let dic = responsObjects as? NSDictionary {
        self.orderno = dic["data"] as! String
        if let result = dic["result"] as? NSNumber {
          if result.boolValue == true {
            self.sendMessageNotificationWithText("订单已取消")
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
      payVC.delegate = self
      payVC.bkOrder = orderDetail
      navigationController?.pushViewController(payVC, animated: true)
    } else {
      showHUDInView(view, withLoading: "")
      ZKJSJavaHTTPSessionManager.sharedInstance().confirmOrderWithOrderNo(orderDetail.orderno,status:2, success: { (task: NSURLSessionDataTask!, responseObject: AnyObject!) -> Void in
        print(responseObject)
        self.sendMessageNotificationWithText("订单已确认")
        self.hideHUD()
        self.navigationController?.popViewControllerAnimated(true)
        }, failure: { (task: NSURLSessionDataTask!, error: NSError!) -> Void in
          print(error)
          self.hideHUD()
      })
    }
    
  }
  
  func sendMessageNotificationWithText(text: String) {
//    // 发送环信消息
//    let userName = AccountManager.sharedInstance().userName
//    let txtChat = EMChatText(text: text)
//    let body = EMTextMessageBody(chatObject: txtChat)
//    let message = EMMessage(receiver: orderDetail.saleid, bodies: [body])
//    let ext = ["shopId": orderDetail.shopid,
//      "shopName": orderDetail.shopname,
//      "toName": "",
//      "fromName": userName]
//    message.ext = ext
//    message.messageType = .eMessageTypeChat
//    EaseMob.sharedInstance().chatManager.asyncSendMessage(message, progress: nil)
    
//    NSNotificationCenter.defaultCenter().postNotificationName(kSendMessageNotification, object: nil, userInfo: ["text": text])
    delegate?.shouldSendTextMessage(text)
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
        if  orderDetail.orderstatus != "待评价" &&  orderDetail.orderstatus != "已取消" {
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

extension HotelOrderDetailTVC: BookPayVCDelegate {
  
  func didFinishPaymentWithStatus(status: PaymentStatusType) {
    if status == PaymentStatusType.Success {
      let alertController = UIAlertController(title: "支付成功", message: "", preferredStyle: .Alert)
      let okAction = UIAlertAction(title: NSLocalizedString("OK", comment: "OK action"), style: .Default, handler: { (action: UIAlertAction) -> Void in
        self.loadData()
      })
      alertController.addAction(okAction)
      presentViewController(alertController, animated: true, completion: nil)
    } else {
      showAlertWithTitle("支付失败", message: "")
    }
  }
  
}
