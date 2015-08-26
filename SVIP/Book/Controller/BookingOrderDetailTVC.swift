//
//  BookingOrderDetailTVC.swift
//  SVIP
//
//  Created by Hanton on 8/25/15.
//  Copyright (c) 2015 zkjinshi. All rights reserved.
//

import UIKit

private let kNameSection = 2
private let partner = PartnerID
private let seller = SellerID
private let privateKey = PartnerPrivKey

class BookingOrderDetailTVC: UITableViewController, UITextFieldDelegate {
  
  @IBOutlet weak var roomCountLabel: UILabel!
  @IBOutlet weak var startDateLabel: UILabel!
  @IBOutlet weak var endDateLabel: UILabel!
  @IBOutlet var nameTextFields: [UITextField]!
  @IBOutlet weak var paymentLabel: UILabel!
  @IBOutlet weak var paymentButton: UIButton!
  @IBOutlet weak var receiptLabel: UILabel!
  @IBOutlet weak var remarkTextView: UITextView!
  
  var roomCount = 1
  var shopID = ""
  var bkOrder: BookOrder!
  
  // MARK: - View Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    title = "确定订单"
    self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "确定", style: UIBarButtonItemStyle.Plain, target: self, action: "gotoChatVC")
    
    roomCount = 1
    shopID = "120"
    
    let totoal = 1890
    let payed = 314
    let remain = totoal - payed
    paymentLabel.text = "应该支付\(totoal)元，还要支付\(remain)元"
    
    paymentButton.setTitle("立即支付", forState: UIControlState.Normal)
//    paymentButton.setTitleColor(UIColor.blueColor(), forState: UIControlState.Normal)
    
    bkOrder = BookOrder()
    bkOrder.reservation_no = "HXXXXXXXXX"
    bkOrder.room_type = "商务大床"
    bkOrder.rooms = "2"
    bkOrder.room_rate = "1200"
  }
  
  // MARK: - Public
  
  func gotoChatVC() {
    let chatVC = JSHChatVC(chatType: .NewSession)
    chatVC.shopID = shopID
    navigationController?.pushViewController(chatVC, animated: true)
  }
  
  // MARK: - Private
  
  private func payAliOrder(AbookOrder: BookOrder) {
    let aliOrder = AlipayOrder()
    aliOrder.partner = partner
    aliOrder.seller = seller
    aliOrder.tradeNO = AbookOrder.reservation_no
    aliOrder.productName = AbookOrder.room_type
    aliOrder.productDescription = "needtoknow"
    if let rooms = AbookOrder.rooms.toInt() {
      let amount = (AbookOrder.room_rate as NSString).doubleValue * Double(rooms)
      aliOrder.amount = NSString(format:"%.2f", amount) as String
    }
    
    aliOrder.notifyURL = "http://api.zkjinshi.com/alipay/notify"
    aliOrder.service = "mobile.securitypay.pay"
    aliOrder.paymentType = "1"
    aliOrder.inputCharset = "utf-8"
    aliOrder.itBPay = "30m"
    aliOrder.showUrl = "m.alipay.com"
    
    //应用注册scheme,在AlixPayDemo-Info.plist定义URL types
    let appScheme = "SVIPPAY"
    
    //将商品信息拼接成字符串
    let orderSpec = aliOrder.description
    print(orderSpec)
    
    //获取私钥并将商户信息签名,外部商户可以根据情况存放私钥和签名,只需要遵循RSA签名规范,并将签名字符串base64编码和UrlEncode
    let signer = CreateRSADataSigner(privateKey)
    if let signedString = signer.signString(orderSpec) {
      let orderString = String(format: "%@&sign=\"%@\"&sign_type=\"%@\"", orderSpec, signedString, "RSA")
      let service = AlipaySDK .defaultService()
      service .payOrder(orderString, fromScheme: appScheme, callback: { [unowned self] (aDictionary) -> Void in
        let resultStatus = aDictionary["resultStatus"] as! String
        let result = aDictionary["result"] as! NSString
        if self.validateResult(result) && resultStatus == "9000" {
          //支付成功
          let totoal = 1890
          let payed = 314
          let remain = totoal - payed
          self.paymentLabel.text = "应该支付\(totoal)元，还要支付\(remain)元"
          self.paymentButton.setTitle("您已支付", forState: UIControlState.Normal)
          self.paymentButton.setTitleColor(UIColor.grayColor(), forState: UIControlState.Normal)
        }else {
          ZKJSTool.showMsg("支付失败")
        }
        })
    }
  }
  
  private func validateResult(result: NSString) -> Bool{
    let range = result .rangeOfString("success=\"")
    if range.length == 0 {
      return false
    }
    let str = result .substringWithRange(NSRange(location: range.location + range.length, length: 4))
    return str == "true"
  }
  
  // MARK: - Action
  
  @IBAction func payOrder(sender: AnyObject) {
    let alertView = UIAlertController(title: "请选择支付方式", message: "", preferredStyle: .ActionSheet)
    alertView.addAction(UIAlertAction(title: "取消", style: .Cancel, handler: nil))
    let wechatAction = UIAlertAction(title: "微信支付", style: .Default, handler: { [unowned self] (alertAction) -> Void in
      self.payAliOrder(self.bkOrder)
      })
//    wechatAction.setValue(UIImage(named: "ic_weixinzhifu"), forKey: "image")
    alertView.addAction(wechatAction)
    presentViewController(alertView, animated: true, completion: nil)
  }
  
  @IBAction func confirmOrder(sender: AnyObject) {
    gotoChatVC()
  }
  
  @IBAction func cancelOrder(sender: AnyObject) {
    let chatVC = JSHChatVC(chatType: .NewSession)
    chatVC.shopID = shopID
    navigationController?.pushViewController(chatVC, animated: true)
  }
  
  // MARK: - Table view datasource
  
  override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    if indexPath.section == kNameSection {
      if indexPath.row > roomCount {
        return 0.0
      }
    }
    return super.tableView(tableView, heightForRowAtIndexPath: indexPath)
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    var count = super.tableView(tableView, numberOfRowsInSection: section)
    if section == kNameSection {
      count = roomCount
    }
    return count
  }
  
  // MARK: - UITextFieldDelegate
  func textFieldShouldReturn(textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    return false
  }
  
}
