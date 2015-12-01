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

class BookingOrderDetailTVC: UITableViewController, UITextFieldDelegate {
  
  @IBOutlet weak var amountLabel: UILabel!
  @IBOutlet weak var roomTypeLabel: UILabel!
  @IBOutlet weak var statusLabel: UILabel!
  
  @IBOutlet weak var payStatusLabel: UILabel!
  @IBOutlet weak var roomCountInfoLabel: UILabel!
  @IBOutlet weak var roomCountLabel: UILabel!
  @IBOutlet weak var dateInfoLabel: UILabel!
  @IBOutlet weak var startDateLabel: UILabel!
  @IBOutlet weak var endDateLabel: UILabel!
  @IBOutlet var nameInfos: [UILabel]!
  @IBOutlet var nameTextFields: [UITextField]!
  @IBOutlet weak var PaymentInfoLabel: UILabel!
  @IBOutlet weak var paymentLabel: UILabel!
  @IBOutlet weak var paymentButton: UIButton!
  @IBOutlet weak var invoiceInfoLabel: UILabel!
  @IBOutlet weak var receiptLabel: UILabel!
  @IBOutlet weak var invoiceFooterLabel: UILabel!
  @IBOutlet weak var remarkInfoLabel: UILabel!
  @IBOutlet weak var remarkInfoPromptLabel: UILabel!
  @IBOutlet weak var remarkTextView: UITextView!
  @IBOutlet weak var roomTagInfoLabel: UILabel!
  @IBOutlet weak var roomTagView: JCTagListView!
  @IBOutlet weak var roomTagFooterLabel: UILabel!
  @IBOutlet weak var serviceInfoLabel: UILabel!
  @IBOutlet weak var serviceTagView: JCTagListView!
  @IBOutlet weak var serviceFooterLabel: UILabel!
  
  @IBOutlet weak var okButton: UIButton!
  @IBOutlet weak var cancelButton: UIButton!
  
  let status = [NSLocalizedString("ORDER_STATUS_BOOKING", comment: ""),
                NSLocalizedString("ORDER_STATUS_CANCEL", comment: ""),
                NSLocalizedString("ORDER_STATUS_CONFIRMED", comment: ""),
                NSLocalizedString("ORDER_STATUS_CHECKOUT", comment: ""),
                NSLocalizedString("ORDER_STATUS_CHECKIN", comment: ""),
                NSLocalizedString("ORDER_STATUS_DELETED", comment: "")]
  var roomCount = 1
  var shopID: Int = 0
  var reservation_no = ""
  var bkOrder: BookOrder!
  var roomTags = [String]()
  var chosenRoomTags = [String]()
  var serviceTags = [String]()
  var chosenServiceTags = [String]()
  var invoiceDic: [String: AnyObject]!
  var privilegeArr: [[String: AnyObject]]!
  var roomDic: NSDictionary!
  var roomTagArr: [[String: AnyObject]]!
  var userArr: [[String: String]]!
  var arrivalDate: NSDate!
  var arrivalDateStr: String!{
    get {
      let fmt = NSDateFormatter()
      fmt.dateFormat = "MM-dd"
      return fmt.stringFromDate(arrivalDate)
    }
  }
  var departureDate: NSDate!
  var departureDateStr: String!{
    get {
      let fmt = NSDateFormatter()
      fmt.dateFormat = "MM-dd"
      return fmt.stringFromDate(departureDate)
    }
  }
  var receiptArray = NSMutableArray()
  // MARK: - View Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()
    
    tableView.contentInset = UIEdgeInsetsMake(-36.0, 0.0, 0.0, 0.0)
    
    title = NSLocalizedString("CONFIRM_ORDER", comment: "")
    roomCountInfoLabel.text = NSLocalizedString("ROOM_COUNT", comment: "")
    dateInfoLabel.text = NSLocalizedString("START_END_DATE", comment: "")
    PaymentInfoLabel.text = NSLocalizedString("PAYMENT_TYPE", comment: "")
    invoiceInfoLabel.text = NSLocalizedString("INVOICE_TYPE", comment: "")
    receiptLabel.text = "[" + NSLocalizedString("CHOOSE_INVOICE", comment: "") + "]"
    invoiceFooterLabel.text = NSLocalizedString("INVOICE_FOOTER", comment: "")
    remarkInfoLabel.text = NSLocalizedString("REMARK_INFO", comment: "")
    remarkInfoPromptLabel.text = NSLocalizedString("REMARK_INFO_PROMPT", comment: "")
    roomTagInfoLabel.text = NSLocalizedString("ROOM_TAG_INFO", comment: "")
    roomTagFooterLabel.text = NSLocalizedString("ROOM_TAG_FOOTER", comment: "")
    serviceInfoLabel.text = NSLocalizedString("SERVICE_INFO", comment: "")
    serviceFooterLabel.text = NSLocalizedString("SERVICE_FOOTER", comment: "")
    okButton.setTitle(NSLocalizedString("CONFIRM", comment: ""), forState: .Normal)
    cancelButton.setTitle(NSLocalizedString("CANCEL", comment: ""), forState: .Normal)
    
    tableView.estimatedRowHeight = UITableViewAutomaticDimension

    bkOrder = BookOrder()
    bkOrder.reservation_no = reservation_no
    loadData()
  }
  
  // MARK: - Public
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    
    loadData()
  }
  
  // MARK: - Private
  
  private func loadData() {
    //获取订单
    ZKJSHTTPSessionManager.sharedInstance().getOrderWithReservation_no(bkOrder.reservation_no, success: { [unowned self] (task: NSURLSessionDataTask!, responseObject: AnyObject!) -> Void in
      if let dic = responseObject as? NSDictionary {
        self.invoiceDic = dic["invoice"] as? [String: AnyObject]
        self.privilegeArr = dic["privilege"] as? [[String: AnyObject]]
        self.roomDic = dic["room"] as? NSDictionary
        self.bkOrder.fullname = self.roomDic["fullname"] as? String
        self.bkOrder.arrival_date = self.roomDic["arrival_date"] as? String
        self.bkOrder.departure_date = self.roomDic["departure_date"] as? String
        self.bkOrder.pay_status = self.roomDic["pay_status"] as? NSNumber
        // 服务器数据类型不统一，有时候是返回是String，有时候是Int
        if let status = self.roomDic["status"] as? NSNumber {
          self.bkOrder.status = status
        } else if let status = self.roomDic["status"] as? String {
          self.bkOrder.status = NSNumber(integer: Int(status)!)
        }
        self.roomTagArr = dic["room_tag"] as? [[String: AnyObject]]
        self.userArr = dic["users"] as? [[String: String]]
        if let shopid = dic["shopid"]?.integerValue {
          self.shopID = shopid
        }
      }
      self.setupData()
      self.tableView.reloadData()
      self.setupUI()
      self.setupRoomTagView()
      self.setupServiceTagView()
      }, failure: { (task: NSURLSessionDataTask!, error: NSError!) -> Void in
        
    })
  }
  
  private func setupData() {
    roomCount = self.roomDic["rooms"]!.integerValue;
    let formatter = NSDateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    arrivalDate = formatter.dateFromString(self.roomDic["arrival_date"] as! String)
    departureDate = formatter.dateFromString(self.roomDic["departure_date"] as! String)
    
    for dic: [String: AnyObject] in self.roomTagArr {
      if let tag = dic["content"] as? String {
        roomTags.append(tag)
      }
    }
    
    for dic: [String: AnyObject] in self.privilegeArr {
      if let tag = dic["privilege_name"] as? String {
        serviceTags.append(tag)
      }
    }
  }
  
  private func setupUI() {
    let rate = roomDic["room_rate"]!.floatValue
    let total = rate
    let totalString = String(Int(total))
    let payed: Float = 0
    let remain = total - payed
    let remainString = String(Int(remain))
    if bkOrder.pay_status == 1 {
      okButton.setTitle("客服", forState: UIControlState.Normal)
      cancelButton.setTitle("退款", forState: UIControlState.Normal)

      payStatusLabel.text = "已支付"
      paymentLabel.text = String(format: NSLocalizedString("PAYED_UNPAY", comment: ""), arguments: [totalString, "0"])
    } else {
      payStatusLabel.text = "待付款"
      paymentLabel.text = String(format: NSLocalizedString("PAYED_UNPAY", comment: ""), arguments: [totalString, remainString])
    }
    bkOrder.room_type = self.roomDic["room_type"] as? String
    
    if let rooms = self.roomDic["rooms"] as? NSNumber {
      bkOrder.rooms = rooms
    }

    if let room_rate = self.roomDic["room_rate"] as? NSNumber {
      bkOrder.room_rate = room_rate
    }

    //设置amountLabel
    let dic: [String: AnyObject] = [
      NSFontAttributeName: UIFont.systemFontOfSize(18),
      NSForegroundColorAttributeName: UIColor.orangeColor()
    ]
    let attriStr = NSAttributedString(string: "\(total)", attributes: dic)
    
    let dic1: [String: AnyObject] = [
      NSFontAttributeName: UIFont.systemFontOfSize(13)
    ]
    let mutAttriStr = NSMutableAttributedString(string: "￥", attributes: dic1)
    mutAttriStr .appendAttributedString(attriStr)
    amountLabel.attributedText = mutAttriStr
    //设置入住人
    for var i = 0 ; i < roomCount; i++ {
      nameInfos[i].text = NSLocalizedString("CLIENT", comment: "") + "\(i+1)"
      nameTextFields[i].placeholder = NSLocalizedString("ONE_ROOM_ONE_PERSON", comment: "")
    }
    //设置roomTypeLabel
    roomTypeLabel.text = bkOrder.room_type
    //设置statusLabel
    statusLabel.text = status[bkOrder.status.integerValue]
    //设置roomCountLabel
    roomCountLabel.text = bkOrder.rooms.stringValue
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
      print(self.roomTagView.seletedTags)
    }
  }
  
  private func setupServiceTagView() {
    serviceTagView.canSeletedTags = true
    serviceTagView.tagColor = UIColor.blackColor()
    serviceTagView.tagCornerRadius = 12.0
    serviceTagView.tags.addObjectsFromArray(serviceTags)
    serviceTagView.setCompletionBlockWithSeleted { (index: Int) -> Void in
      print(self.serviceTagView.seletedTags)
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
  
  @IBAction func confirmOrder(sender: AnyObject) {
    if okButton.titleLabel?.text == "客服"  {
     //订单已经提交，客人跟客服聊天的窗口
    }
    
    let mutDic = NSMutableDictionary()
    mutDic.setObject(self.roomDic["reservation_no"] as! String, forKey: "reservation_no")
    //设置入住人
    let users = NSMutableArray()
    for var i = 0 ; i < roomCount; i++ {
      if self.nameTextFields[i].text!.isEmpty {//判断入住人信息是否已选择
        ZKJSTool.showMsg(NSLocalizedString("CHOOSE_CLIENT", comment: ""))
        return
      } else {
        users.addObject("\(self.nameTextFields[i].tag)")
      }
    }
    mutDic.setObject(users.componentsJoinedByString(","), forKey: "users")
    
    if receiptLabel.text == NSLocalizedString("CHOOSE_INVOICE", comment: "") {//判断发票信息是否已选择
      ZKJSTool.showMsg(NSLocalizedString("CHOOSE_INVOICE", comment: ""))
      return
    }else {
      mutDic.setObject(receiptLabel.text!, forKey: "invoice[invoice_title]")
    }
    
    mutDic.setObject(1, forKey: "invoice[invoice_get_id]")
    
    let privilegeIDs = NSMutableArray()
    for tag in serviceTagView.seletedTags {
      for dic in privilegeArr {
        if let privilege_name = dic["privilege_name"] as? String,
          let tag = tag as? String {
          if privilege_name == tag {
            privilegeIDs.addObject(dic["id"]!)
          }
        }
      }
    }
    if privilegeIDs.count != 0 {
      mutDic.setObject(privilegeIDs.componentsJoinedByString(","), forKey: "privilege")
    }
    
    if roomTagView.seletedTags.count != 0 {
      mutDic.setObject(roomTagView.seletedTags.componentsJoinedByString(","), forKey: "room_tags")
    }
    
    if !remarkTextView.text.isEmpty {
      mutDic.setObject(remarkTextView.text, forKey: "remark")
    }
    
    ZKJSHTTPSessionManager.sharedInstance().modifyOrderWithReservation_no(bkOrder.reservation_no, param: mutDic as [NSObject : AnyObject], success: {[unowned self]  (task: NSURLSessionDataTask!, responseObject: AnyObject!) -> Void in
      self.navigationController?.popViewControllerAnimated(true)
      ZKJSTool.showMsg("订单已确认")
      }, failure: { (task: NSURLSessionDataTask!, error: NSError!) -> Void in
        ZKJSTool.showMsg(error.localizedDescription)
    })
  }
  
  @IBAction func cancelOrder(sender: AnyObject) {
    if cancelButton.titleLabel?.text == "退款" {
      //申请退款
      
    }
    
    if bkOrder.status.integerValue == OrderStatus.Pending.rawValue {
      ZKJSHTTPSessionManager.sharedInstance().cancelOrderWithReservation_no(bkOrder.reservation_no, success: { [unowned self] (task: NSURLSessionDataTask!, responseObject: AnyObject!) -> Void in
        ZKJSTool.showMsg("订单已取消")
        self.navigationController?.popViewControllerAnimated(true)
        }, failure: { (task: NSURLSessionDataTask!, error: NSError!) -> Void in
          ZKJSTool.showMsg(error.localizedDescription)
      })
    }
  }
  
  // MARK: - Table view datasource
  
  override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    if indexPath.section == kNameSection {
      if indexPath.row >= roomCount {
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
      cell.contentView.addSubview(roomTagView)
    } else if indexPath.section == kServiceSection && indexPath.row == kServiceRow {
      cell.contentView.addSubview(serviceTagView)
    }
    
    return cell
  }
  
  // MARK: - Table view delegate
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    print(indexPath)
    
    if indexPath.section == kReceiptSection && indexPath.row == kReceiptRow {  // 房型
      let vc = ReceiptTVC()
      vc.dataArray = self.receiptArray
      vc.selection = { [unowned self] (receiptTitle: String) -> () in
        self.receiptLabel.text = receiptTitle
      }
      navigationController?.pushViewController(vc, animated: true)
    } else if indexPath.section == kNameSection {  // 入住人
      let vc = NameTVC()
      vc.selection = { [unowned self] (name: String, idInt: Int) ->() in
        self.nameTextFields[indexPath.row].text = name
        self.nameTextFields[indexPath.row].tag = idInt
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
