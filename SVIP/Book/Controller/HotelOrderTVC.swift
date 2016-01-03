//
//  HotelOrderTVC.swift
//  SVIP
//
//  Created by AlexBang on 15/12/29.
//  Copyright © 2015年 zkjinshi. All rights reserved.
//

import UIKit

class HotelOrderTVC: UITableViewController,UITextFieldDelegate {

  @IBOutlet weak var daysLabel: UILabel!
  @IBOutlet weak var roomsTypeLabel: UILabel!
  @IBOutlet weak var roomsTextField: UITextField!
  @IBOutlet weak var contactTextField: UITextField!
  @IBOutlet weak var telphoneTextField: UITextField!
  @IBOutlet weak var paymentLabel: UILabel!
  @IBOutlet weak var invoinceLabel: UILabel!
  @IBOutlet weak var breakfeastSwitch: UISwitch!
  @IBOutlet weak var isSmokingSwitch: UISwitch!
  @IBOutlet weak var remarkTextView: UITextView!
  @IBOutlet weak var countSubtractButton: UIButton! {
    didSet {
      countSubtractButton.addTarget(self, action: "countSubtract:", forControlEvents: UIControlEvents.TouchUpInside)
    }
  }
  @IBOutlet weak var countAddButton: UIButton! {
    didSet {
      countAddButton.addTarget(self, action: "countAdd:", forControlEvents: UIControlEvents.TouchUpInside)
    }
  }

  var shopid: NSNumber!
  var shopName: String!
  var saleid: String!
  var roomsCount = 1
  var leavedate:String!
  var arrivaldate: String!
  var breakfeastCount = 0 //无早餐
  var smokingCount = 0 // 无烟房
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    title = shopName
    roomImage.image = UIImage(named: "bg_dingdanzhuangtai")
    setUpUI()
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    navigationController?.navigationBar.translucent = false
   
  }
  
  override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
    view.endEditing(true)
  }
  
  override func viewWillDisappear(animated: Bool) {
    super.viewWillDisappear(animated)
    navigationController?.navigationBar.translucent = true
  }
  
  func countAdd(sender: AnyObject) {
    self.countSubtractButton.enabled = true
    roomsCount++
    setUpUI()
  }
  func countSubtract(sender: AnyObject) {
    roomsCount--
    if roomsCount < 1 {
      self.countSubtractButton.enabled = false
    }
    setUpUI()
  }
  
  func setUpUI() {
    self.roomsTextField.text = String(roomsCount)
  }
  // MARK: - Table view data source
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = super.tableView(tableView, cellForRowAtIndexPath: indexPath)
    cell.selectionStyle = UITableViewCellSelectionStyle.None
    return cell
  }
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    if indexPath == NSIndexPath(forRow: 1, inSection: 0) {
      chooseDate()
    }
    if indexPath == NSIndexPath(forRow: 2, inSection: 0) {
      chooseRoomType()
    }
    if indexPath == NSIndexPath(forRow: 1, inSection: 2) {
      navigationController?.pushViewController(InvoiceVC(), animated: true)
    }
    if indexPath == NSIndexPath(forRow: 0, inSection: 5) {
      
    }
    
  }
  
  @IBAction func submitOrder(sender: AnyObject) {
    submitOrder()
  }
  
  func chooseDate() {
    let vc = BookDateSelectionViewController()
    vc.selection = { [unowned self] (startDate: NSDate, endDate: NSDate) ->() in
      let dateFormatter = NSDateFormatter()
      dateFormatter.dateFormat = "M/dd"
      
      let formatter = NSDateFormatter()
      formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
      self.arrivaldate = formatter.stringFromDate(startDate)
      self.leavedate = formatter.stringFromDate(endDate)
      let start = dateFormatter.stringFromDate(startDate)
      let end = dateFormatter.stringFromDate(endDate)
      let duration = NSDate.daysFromDate(startDate, toDate: endDate)
      self.daysLabel.text = "\(start)-\(end)共\(duration)晚"
    }
    navigationController?.pushViewController(vc, animated: true)
  }
  
  func chooseRoomType() {
    let vc = BookVC()
    vc.shopid = self.shopid
    vc.selection = { (goods:RoomGoods ) ->() in
      self.roomsTypeLabel.text = goods.room + goods.type
      self.goods = goods
      let urlString = kBaseURL + goods.image
      self.roomImage.sd_setImageWithURL(NSURL(string: urlString))
    }
    navigationController?.pushViewController(vc, animated: true)
  }
  
  
  @IBAction func switchBreakfast(sender: AnyObject) {
    if  breakfeastSwitch.on == true {
      
    }
  }
  @IBAction func smokingSwitch(sender: AnyObject) {
    if isSmokingSwitch.on {
      
    }
  }
  // MARK: - UITextFieldDelegate
  func textFieldShouldReturn(textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    return false
  }
  
  func submitOrder() {
    if AccountManager.sharedInstance().isLogin() == false {
      let nc = BaseNC(rootViewController: LoginVC())
      presentViewController(nc, animated: true, completion: nil)
      return
    }
    let userID = AccountManager.sharedInstance().userID
    var dic = [String: AnyObject]()
    dic["saleid"] = self.saleid
    dic["arrivaldate"] = self.arrivaldate
    dic["leavedate"] = self.leavedate
    dic["roomtype"] = self.roomsTypeLabel.text!
    dic["roomcount"] = Int(self.roomsTextField.text!)
    dic["orderedby"] = self.contactTextField.text
    dic["telephone"] = self.telphoneTextField.text
    dic["shopid"] = self.shopid
    dic["userid"] = userID
    dic["imgurl"] = ""
    dic["productid"] = ""
    dic["roomno"] = ""
    dic["paytype"] = ""
    dic["roomprice"] = ""
    dic["telephone"] = self.telphoneTextField.text
    dic["personcount"] = 1
    dic["doublebreakfeast"] = breakfeastSwitch.on ? 1 : 0
    dic["nosmoking"] = isSmokingSwitch.on ? 1 : 0
    dic["company"] = ""
    dic["remark"] = self.remarkTextView.text
    if arrivaldate == nil || arrivaldate.isEmpty == true {
      ZKJSTool.showMsg("请填写时间")
      return
    }
    if self.roomsTypeLabel.text == "请选择房型" {
      ZKJSTool.showMsg("请选择房型")
      return
    }
    
    ZKJSJavaHTTPSessionManager.sharedInstance().addOrderWithCategory("0", data: dic, success: { (task:NSURLSessionDataTask!, responObjects:AnyObject!) -> Void in
      print(responObjects)
      self.gotoChatVC()
      }) { (task:NSURLSessionDataTask!, error:NSError!) -> Void in
        
    }
  }
  
  func gotoChatVC() {
    ZKJSHTTPSessionManager.sharedInstance().getMerchanCustomerServiceListWithShopID(String(shopid), success: { (task: NSURLSessionDataTask!, responseObject: AnyObject!) -> Void in
      print(responseObject)
      self.chooseChatterWithData(responseObject)
      }) { (task: NSURLSessionDataTask!, error: NSError!) -> Void in
        
    }
  }
  
  func chooseChatterWithData(data: AnyObject) {
    if let head = data["head"] as? [String: AnyObject] {
      if let set = head["set"] as? NSNumber {
        if set.boolValue {
          if let exclusive_salesid = head["exclusive_salesid"] as? String {
            if let data = data["data"] as? [[String: AnyObject]] {
              for sale in data {
                if let salesid = sale["salesid"] as? String {
                  if salesid == exclusive_salesid {
                    if let name = sale["name"] as? String {
                      self.createConversationWithSalesID(salesid, salesName: name)
                    }
                  }
                }
              }
            }
          } else if let data = data["data"] as? [[String: AnyObject]] where data.count > 0 {
            let randomIndex = Int(arc4random_uniform(UInt32(data.count)))
            let sale = data[randomIndex]
            if let salesid = sale["salesid"] as? String,
              let name = sale["name"] as? String {
                self.createConversationWithSalesID(salesid, salesName: name)
            }
          }
        }
      }
    }
  }
  
  func createConversationWithSalesID(salesID: String, salesName: String) {
    let vc = ChatViewController(conversationChatter: salesID, conversationType: .eConversationTypeChat)
    let order = packetOrder()
    print(order)
    vc.title = order.fullname
    // 扩展字段
    let userName = AccountManager.sharedInstance().userName
    let ext = ["shopId": order.shopid.stringValue,
      "shopName": order.fullname,
      "toName": salesName,
      "fromName": userName]
    vc.conversation.ext = ext
    vc.firstMessage = "Card"
    vc.order = order
    navigationController?.pushViewController(vc, animated: true)
  }

  func packetOrder() -> BookOrder {
    let order = BookOrder()
    order.shopid = shopid
    order.rooms = NSNumber(integer: Int(roomsTextField.text!)!)
    order.room_typeid = goods.goodsid
    order.room_type = roomsTypeLabel.text!
    order.fullname = shopName
    order.room_image_URL = goods.image
    let dateFormatter = NSDateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    order.arrival_date = arrivaldate
    order.departure_date = leavedate
    order.guest = contactTextField.text
    order.guesttel = telphoneTextField.text
    order.room_image = roomImage.image
    return order
 
  }
  
}
