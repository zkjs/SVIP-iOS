//
//  BookingOrderDetailTVC.swift
//  SVIP
//
//  Created by Hanton on 8/25/15.
//  Copyright (c) 2015 zkjinshi. All rights reserved.
//

import UIKit

private let kNameSection = 2
private let kReceiptSection = 4
private let kReceiptRow = 1
private let kRoomSection = 5
private let kRoomRow = 1
private let kServiceSection = 6
private let kServiceRow = 1
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
  
  let roomTagView = SKTagView()
  let serviceTagView = SKTagView()
  
  var roomCount = 1
  var shopID = ""
  var bkOrder: BookOrder!
  var roomTags = ["无烟房", "加床", "开夜床", "高楼层", "角落房", "安静", "离电梯近", "视野好", "数字敏感"]
  var chosenRoomTags = [String]()
  var serviceTags = ["免前台"]
  var chosenServiceTags = [String]()
  
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
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = super.tableView(tableView, cellForRowAtIndexPath: indexPath)
    
    if indexPath.section == kRoomSection && indexPath.row == kRoomRow {
//      let roomTagView = SKTagView()
      roomTagView.backgroundColor = UIColor.whiteColor()
      roomTagView.setTranslatesAutoresizingMaskIntoConstraints(false)
      roomTagView.padding = UIEdgeInsetsMake(0.0, 15.0, 0.0, 15.0)
      roomTagView.insets = 12.0
      roomTagView.lineSpace = 12
      roomTagView.didClickTagAtIndex = { [unowned self] (indexU: UInt) -> () in
        let index = Int(indexU)
        let clickedTag = self.roomTags[index]
        if let chosenIndex = find(self.chosenRoomTags, clickedTag) {
          let tagButton = self.roomTagView.tags[index] as! SKTag
          tagButton.textColor = UIColor.blackColor()
          tagButton.bgColor = UIColor.whiteColor()
          self.chosenRoomTags.removeAtIndex(chosenIndex)
        }  else {
          let tagButton = self.roomTagView.tags[index] as! SKTag
          tagButton.textColor = UIColor.whiteColor()
          tagButton.bgColor = UIColor.blackColor()
          self.chosenRoomTags.append(self.roomTags[index])
        }
        println(self.chosenRoomTags)
      }
      cell.contentView.addSubview(roomTagView)
      roomTagView.mas_makeConstraints { (make: MASConstraintMaker!) -> Void in
        let superView = cell.contentView
        make.top.equalTo()(superView.mas_top)
        make.bottom.equalTo()(superView.mas_bottom)
        make.leading.equalTo()(superView.mas_leading)
        make.trailing.equalTo()(superView.mas_trailing)
      }
      
      for tag in roomTags {
        let tagButton = SKTag(text: tag)
        tagButton.textColor = UIColor.blackColor()
        tagButton.fontSize = 17
        tagButton.padding = UIEdgeInsetsMake(5.0, 12.0, 5.0, 12.0)
        tagButton.bgColor = UIColor.whiteColor()
        tagButton.borderColor = UIColor.grayColor()
        tagButton.borderWidth = 0.5
        tagButton.cornerRadius = 12.0
        roomTagView.addTag(tagButton)
      }
    } else if indexPath.section == kServiceSection && indexPath.row == kServiceRow {
//      let serviceTagView = SKTagView()
      serviceTagView.backgroundColor = UIColor.whiteColor()
      serviceTagView.setTranslatesAutoresizingMaskIntoConstraints(false)
      serviceTagView.padding = UIEdgeInsetsMake(0.0, 15.0, 0.0, 15.0)
      serviceTagView.insets = 12.0
//      serviceTagView.lineSpace = 10
      serviceTagView.didClickTagAtIndex = { [unowned self] (indexU: UInt) -> () in
        let index = Int(indexU)
        let clickedTag = self.serviceTags[index]
        if let chosenIndex = find(self.chosenServiceTags, clickedTag) {
          let tagButton = self.serviceTagView.tags[index] as! SKTag
          tagButton.textColor = UIColor.blackColor()
          tagButton.bgColor = UIColor.whiteColor()
          self.chosenServiceTags.removeAtIndex(chosenIndex)
        }  else {
          let tagButton = self.serviceTagView.tags[index] as! SKTag
          tagButton.textColor = UIColor.whiteColor()
          tagButton.bgColor = UIColor.blackColor()
          self.chosenServiceTags.append(self.serviceTags[index])
        }
        println(self.chosenServiceTags)
      }
      cell.contentView.addSubview(serviceTagView)
      serviceTagView.mas_makeConstraints { (make: MASConstraintMaker!) -> Void in
        let superView = cell.contentView
        make.top.equalTo()(superView.mas_top)
        make.bottom.equalTo()(superView.mas_bottom)
        make.leading.equalTo()(superView.mas_leading)
        make.trailing.equalTo()(superView.mas_trailing)
      }
      
      for tag in serviceTags {
        let tagButton = SKTag(text: tag)
        tagButton.textColor = UIColor.blackColor()
        tagButton.fontSize = 17
        tagButton.padding = UIEdgeInsetsMake(12.0, 12.0, 12.0, 12.0)
        tagButton.bgColor = UIColor.whiteColor()
        tagButton.borderColor = UIColor.grayColor()
        tagButton.borderWidth = 0.5
        tagButton.cornerRadius = 12.0
        serviceTagView.addTag(tagButton)
      }
    }
    
    return cell
  }
  
  // MARK: - Table view delegate
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    println(indexPath)
    
    if indexPath.section == kReceiptSection && indexPath.row == kReceiptRow {  // 房型
      let vc = ReceiptTVC()
      vc.selection = { [unowned self] (receiptTitle: String) -> () in
        self.receiptLabel.text = receiptTitle
      }
      navigationController?.pushViewController(vc, animated: true)
    }
  }
  
  // MARK: - UITextFieldDelegate
  func textFieldShouldReturn(textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    return false
  }
  
}
