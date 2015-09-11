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
  
  @IBOutlet weak var amountLabel: UILabel!
  @IBOutlet weak var roomTypeLabel: UILabel!
  @IBOutlet weak var statusLabel: UILabel!
  
  @IBOutlet weak var roomCountLabel: UILabel!
  @IBOutlet weak var startDateLabel: UILabel!
  @IBOutlet weak var endDateLabel: UILabel!
  @IBOutlet var nameTextFields: [UITextField]!
  @IBOutlet weak var paymentLabel: UILabel!
  @IBOutlet weak var paymentButton: UIButton!
  @IBOutlet weak var receiptLabel: UILabel!
  @IBOutlet weak var remarkTextView: UITextView!
  @IBOutlet weak var roomTagView: JCTagListView!
  @IBOutlet weak var serviceTagView: JCTagListView!
  
  let status = ["可取消", "已取消", "已确认", "已完成", "入住中", "已删除"]
  var roomCount = 1
  var shopID: Int = 0
  var reservation_no = ""
  var bkOrder: BookOrder!
  var roomTags = [String]()
  var chosenRoomTags = [String]()
  var serviceTags = [String]()
  var chosenServiceTags = [String]()
  var invoiceDic: [String: String]!
  var privilegeArr: [[String: String]]!
//  var roomDic: [String: String]!
  var roomDic: NSDictionary!
  var roomTagArr: [[String: String]]!
  var userArr: [[String: String]]!
  var arrivalDate: NSDate!
  var arrivalDateStr: String!{
    get {
      let fmt = NSDateFormatter()
      fmt.dateFormat = "MM月dd日"
      return fmt.stringFromDate(arrivalDate)
    }
  }
  var departureDate: NSDate!
  var departureDateStr: String!{
    get {
      let fmt = NSDateFormatter()
      fmt.dateFormat = "MM月dd日"
      return fmt.stringFromDate(departureDate)
    }
  }
  var receiptArray = NSMutableArray()
  // MARK: - View Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()
    
    title = "确定订单"
    tableView.estimatedRowHeight = UITableViewAutomaticDimension
    self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "确定", style: UIBarButtonItemStyle.Plain, target: self, action: "sendConfirmMessageToChatVC")
    shopID = 808
    reservation_no = "H20150910032400"
//    shopID = 120
    bkOrder = BookOrder()
//    bkOrder.reservation_no = "H20150806051741"
    bkOrder.reservation_no = reservation_no
    loadData()
  }
  // MARK: - Public
  
  func sendConfirmMessageToChatVC() {
    let chatVC = JSHChatVC(chatType: .ConfirmOrder)
    chatVC.shopID = "\(shopID)"
    chatVC.firtMessage = "我已经确认订单"
    navigationController?.pushViewController(chatVC, animated: true)
  }
  
  // MARK: - Private
  private func loadData() {
    //获取订单
    ZKJSHTTPSessionManager.sharedInstance().getOrderWithReservation_no(bkOrder.reservation_no, success: { (task: NSURLSessionDataTask!, responseObject: AnyObject!) -> Void in
      if let dic = responseObject as? NSDictionary {
        self.invoiceDic = dic["invoice"] as? [String: String]
        self.privilegeArr = dic["privilege"] as? [[String: String]]
        self.roomDic = dic["room"] as? NSDictionary
        self.roomTagArr = dic["room_tag"] as? [[String: String]]
        self.userArr = dic["users"] as? [[String: String]]
      }
      self.setupData()
      self.setupUI()
      self.setupRoomTagView()
      self.setupServiceTagView()
      }, failure: { (task: NSURLSessionDataTask!, error: NSError!) -> Void in
        
    })
    
//    //获取发票列表
//    ZKJSHTTPSessionManager.sharedInstance().getInvoiceListSuccess({ (task: NSURLSessionDataTask!, responseObject: AnyObject!) -> Void in
//      if let arr = responseObject as? [AnyObject] {
//        self.receiptArray.removeAllObjects()
//        for dic in arr {
//          if let d = dic as? NSDictionary {
//            let is_default = d["is_default"]!.boolValue!
//            if is_default {//默认
//              self.receiptArray.insertObject(d, atIndex: 0)
//              self.receiptLabel.text = d["invoice_title"] as! String
//            }else {//未默认
//              self.receiptArray.addObject(d)
//            }
//          }
//        }
//
////        self.tableView.reloadSections(NSIndexSet(index: 4), withRowAnimation: UITableViewRowAnimation.None)
//      }
//      }, failure: { (task: NSURLSessionDataTask!, error: NSError!) -> Void in
//        
//    })
  }
  private func setupData() {
    roomCount = self.roomDic["rooms"]!.integerValue;
    let formatter = NSDateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    arrivalDate = formatter.dateFromString(self.roomDic["arrival_date"] as! String)
    departureDate = formatter.dateFromString(self.roomDic["departure_date"] as! String)
    
    for dic: [String: String] in self.roomTagArr {
      roomTags.append(dic["content"]!)
    }
    
    for dic: [String: String] in self.privilegeArr {
      serviceTags.append(dic["privilege_name"]!)
    }

  }
  private func setupUI() {
    let rate = self.roomDic["room_rate"]!.floatValue
    let total = rate
    let payed: Float = 0
    let remain = total - payed
    paymentLabel.text = "应该支付\(total)元，还要支付\(remain)元"

    paymentButton.setTitle("立即支付", forState: UIControlState.Normal)
//    paymentButton.setTitleColor(UIColor.blueColor(), forState: UIControlState.Normal)

    bkOrder = BookOrder()
//    bkOrder.reservation_no = "H00120180203"
    bkOrder.room_type = self.roomDic["room_type"] as? String
    bkOrder.rooms = self.roomDic["rooms"]! as! String
    bkOrder.room_rate = self.roomDic["room_rate"] as! String
    
    
    //设置amountLabel
    let dic = NSDictionary(objectsAndKeys: UIFont .systemFontOfSize(18) , NSFontAttributeName, UIColor.orangeColor(), NSForegroundColorAttributeName)
    let attriStr = NSAttributedString(string: "\(total)", attributes: dic as [NSObject : AnyObject])
    let dic1 = NSDictionary(objectsAndKeys: UIFont .systemFontOfSize(13) , NSFontAttributeName)
    var mutAttriStr = NSMutableAttributedString(string: "￥", attributes: dic1 as [NSObject : AnyObject])
    mutAttriStr .appendAttributedString(attriStr)
    amountLabel.attributedText = mutAttriStr
    //设置roomTypeLabel
    roomTypeLabel.text = self.roomDic["room_type"] as? String
    //设置statusLabel
    statusLabel.text = status[self.roomDic["status"]!.integerValue]
    //设置roomCountLabel
    roomCountLabel.text = self.roomDic["rooms"] as? String
    //设置startDateLabel
    startDateLabel.text = arrivalDateStr
    //设置endDateLabel
    endDateLabel.text = departureDateStr
  }
  
  private func setupRoomTagView() {
    roomTagView.canSeletedTags = true
    roomTagView.tagColor = UIColor.blackColor()
    roomTagView.tagCornerRadius = 12.0
    roomTagView.tags.addObjectsFromArray(roomTags)
    roomTagView.setCompletionBlockWithSeleted { (index: Int) -> Void in
      println(self.roomTagView.seletedTags)
    }
  }
  
  private func setupServiceTagView() {
    serviceTagView.canSeletedTags = true
    serviceTagView.tagColor = UIColor.blackColor()
    serviceTagView.tagCornerRadius = 12.0
    serviceTagView.tags.addObjectsFromArray(serviceTags)
    serviceTagView.setCompletionBlockWithSeleted { (index: Int) -> Void in
      println(self.serviceTagView.seletedTags)
    }
  }
  
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
    let wechatAction = UIAlertAction(title: "支付宝支付", style: .Default, handler: { [unowned self] (alertAction) -> Void in
      self.payAliOrder(self.bkOrder)
      })
//    wechatAction.setValue(UIImage(named: "ic_weixinzhifu"), forKey: "image")
    alertView.addAction(wechatAction)
    presentViewController(alertView, animated: true, completion: nil)
  }
  
  @IBAction func confirmOrder(sender: AnyObject) {
    let mutDic = NSMutableDictionary()
    mutDic.setObject(self.roomDic["reservation_no"] as! String, forKey: "reservation_no")
    mutDic.setObject([2], forKey: "status")
//    mutDic.setObject(<#anObject: AnyObject#>, forKey: "users")
//    mutDic.setObject(<#anObject: AnyObject#>, forKey: "invoice[invoice_title]")
//    mutDic.setObject(<#anObject: AnyObject#>, forKey: "invoice[invoice_get_id]")
//    mutDic.setObject(<#anObject: AnyObject#>, forKey: "privilege")
//    mutDic.setObject(<#anObject: AnyObject#>, forKey: "room_tags")
//    mutDic.setObject(<#anObject: AnyObject#>, forKey: "remark")
//    mutDic.setObject(<#anObject: AnyObject#>, forKey: "pay_status")
    
    
    sendConfirmMessageToChatVC()
  }
  
  @IBAction func cancelOrder(sender: AnyObject) {
    ZKJSHTTPSessionManager.sharedInstance().cancelOrderWithReservation_no(bkOrder.reservation_no, success: { (task: NSURLSessionDataTask!, responseObject: AnyObject!) -> Void in
      let chatVC = JSHChatVC(chatType: ChatType.CancelOrder)
      chatVC.shopID = "\(self.shopID)"
      chatVC.firtMessage = "你好，我想取消订单"
      self.navigationController?.pushViewController(chatVC, animated: true)
      }, failure: { (task: NSURLSessionDataTask!, error: NSError!) -> Void in
        ZKJSTool.showMsg(error.localizedDescription)
    })

  }
  
  // MARK: - Table view datasource
  
  override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    if indexPath.section == kNameSection {
      if indexPath.row > roomCount {
        return 0.0
      }
    }
    
//    if indexPath.section == kRoomSection && indexPath.row == kRoomRow {
//      return roomTagView.frame.height
//    }
    
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
      cell.contentView.addSubview(roomTagView)
    } else if indexPath.section == kServiceSection && indexPath.row == kServiceRow {
      cell.contentView.addSubview(serviceTagView)
    }
    
    return cell
  }
  
  // MARK: - Table view delegate
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    println(indexPath)
    
    if indexPath.section == kReceiptSection && indexPath.row == kReceiptRow {  // 房型
      let vc = ReceiptTVC()
      vc.dataArray = self.receiptArray
      vc.selection = { [unowned self] (receiptTitle: String) -> () in
        self.receiptLabel.text = receiptTitle
      }
      navigationController?.pushViewController(vc, animated: true)
//    } else if indexPath.section == kNameSection {  // 入住人
//      let vc = NameTVC()
//      vc.selection = { [unowned self] (name: String) ->() in
//        self.nameTextFields[indexPath.row].text = name
//      }
//      navigationController?.pushViewController(vc, animated: true)
    }
  }
  
  // MARK: - UITextFieldDelegate
  func textFieldShouldReturn(textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    return false
  }
  
}
