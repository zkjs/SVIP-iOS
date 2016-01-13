//
//  HotelOrderTVC.swift
//  SVIP
//
//  Created by AlexBang on 15/12/29.
//  Copyright © 2015年 zkjinshi. All rights reserved.
//

import UIKit

class HotelOrderTVC: UITableViewController,UITextFieldDelegate {

  @IBOutlet weak var roomImage: UIImageView!
  @IBOutlet weak var daysLabel: UILabel!
  @IBOutlet weak var roomsTypeLabel: UILabel!
  @IBOutlet weak var roomsTextField: UITextField!
  @IBOutlet weak var contactTextField: UITextField!
  @IBOutlet weak var telphoneTextField: UITextField!
  @IBOutlet weak var paymentLabel: UILabel!
  @IBOutlet weak var invoinceLabel: UILabel!
  @IBOutlet weak var breakfeastSwitch: UISwitch!
  @IBOutlet weak var isSmokingSwitch: UISwitch!
  @IBOutlet weak var remarkTextView: UITextView! {
    didSet {
//      remarkTextView.layer.borderWidth = 1 //边框粗细
//      remarkTextView.layer.borderColor = UIColor.hx_colorWithHexString("B8B8B8").CGColor
      
    }
  }
  @IBOutlet weak var countSubtractButton: UIButton! {
    didSet {
      countSubtractButton.addTarget(self, action: "countSubtract:", forControlEvents: UIControlEvents.TouchUpInside)
      countSubtractButton.layer.borderWidth = 1
      countSubtractButton.layer.borderColor = UIColor.ZKJS_lineColor().CGColor
    }
  }
  @IBOutlet weak var countAddButton: UIButton! {
    didSet {
      countAddButton.addTarget(self, action: "countAdd:", forControlEvents: UIControlEvents.TouchUpInside)
      countAddButton.layer.borderWidth = 1
      countAddButton.layer.borderColor = UIColor.ZKJS_lineColor().CGColor
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
  var goods: RoomGoods!
  var paytypeArray = ["未设置", "在线支付", "到店支付", "挂帐"]
  var paytype = "0"
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    title = shopName
    tableView.backgroundColor = UIColor.hx_colorWithHexString("#EFEFF4")
    roomImage.image = UIImage(named: "bg_dingdanzhuangtai")
    tableView.bounces = false
    setUpUI()
  }
  
  
  override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
    view.endEditing(true)
  }
  
  func countAdd(sender: AnyObject) {
    self.countSubtractButton.enabled = true
    roomsCount++
    setUpUI()
  }
  func countSubtract(sender: AnyObject) {
   
    if roomsCount < 2 {
      self.countSubtractButton.enabled = false
      return
    }
    roomsCount--
    setUpUI()
  }
  
  func setUpUI() {
    self.roomsTextField.text = String(roomsCount)
  }
  
  // MARK: - Table view data source
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = super.tableView(tableView, cellForRowAtIndexPath: indexPath)
    cell.selectionStyle = UITableViewCellSelectionStyle.None
    if indexPath.section == 0 && (indexPath.row == 0 || indexPath.row == 2)  || indexPath.section == 4 || indexPath.section == 5 {
      
    } else {
      cell.accessoryView = UIImageView(image: UIImage(named: "ic_right_orange"))
    }
    
    return cell
  }
  
  override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    if section == 0 {
      return 0
    }
    return 20
  }
  
  override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let header = UIView()
    header.backgroundColor = UIColor.clearColor()
    return header
  }
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    if indexPath == NSIndexPath(forRow: 3, inSection: 0) {
      chooseDate()
    }
    if indexPath == NSIndexPath(forRow: 1, inSection: 0) {
      chooseRoomType()
    }
    if indexPath == NSIndexPath(forRow: 1, inSection: 2) {
      let vc = InvoiceVC()
      vc.selection = { [unowned self] (invoice:  InvoiceModel) ->() in
        self.invoinceLabel.text = invoice.title
        self.invoinceLabel.textColor = UIColor.ZKJS_navTitleColor()
      }
      self.navigationController?.pushViewController(vc, animated: true)
    }
    if indexPath == NSIndexPath(forRow: 0, inSection: 2) {
      choosePayStatus()
    }
    view.endEditing(true)
  }
  
  
  @IBAction func submitOrder(sender: AnyObject) {
    submitOrder()
  }
  
  func choosePayStatus() {
    let alertView = UIAlertController(title: "选择订单状态", message: "", preferredStyle: .ActionSheet)
    for index in 1..<paytypeArray.count {
      alertView.addAction(UIAlertAction(title: paytypeArray[index], style: .Default, handler: { [unowned self] (action: UIAlertAction!) -> Void in
        self.paymentLabel.text = self.paytypeArray[index]
        // 更新订单
        self.paytype = "\(index)"
        self.paymentLabel.textColor = UIColor.ZKJS_navTitleColor()
        }))
    }
    alertView.addAction(UIAlertAction(title: "取消", style: .Cancel, handler: nil))
    presentViewController(alertView, animated: true, completion: nil)
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
      self.daysLabel.textColor = UIColor.ZKJS_navTitleColor()
    }
    navigationController?.pushViewController(vc, animated: true)
  }
  
  func chooseRoomType() {
    let vc = BookVC()
    vc.shopid = self.shopid
    vc.selection = { (goods:RoomGoods ) ->() in
      self.roomsTypeLabel.text = goods.room
      self.roomsTypeLabel.textColor = UIColor.ZKJS_navTitleColor()
      self.goods = goods
      let baseUrl = kImageURL
      if let goodsImage = goods.image {
        var url = NSURL(string: baseUrl)
        url = url?.URLByAppendingPathComponent(goodsImage)
        self.roomImage.sd_setImageWithURL(url, placeholderImage: UIImage(named: "bg_dingdanzhuangtai"))
      }
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
    gotoChatVC()
  }
  
  func gotoChatVC() {
    showHUDInView(view, withLoading: "")
    ZKJSHTTPSessionManager.sharedInstance().getMerchanCustomerServiceListWithShopID(String(shopid), success: { (task: NSURLSessionDataTask!, responseObject: AnyObject!) -> Void in
      if responseObject == nil {
        return
      }
      print(responseObject)
      self.chooseChatterWithData(responseObject)
      }) { (task: NSURLSessionDataTask!, error: NSError!) -> Void in
        print(error)
    }
  }
  
  func chooseChatterWithData(data: AnyObject) {
    if let head = data["head"] as? [String: AnyObject] {
      if let set = head["set"] as? NSNumber {
        if set.boolValue {
          if let exclusive_salesid = head["exclusive_salesid"] as? String,let exclusive_name = head["exclusive_name"] as? String {
            self.createConversationWithSalesID(exclusive_salesid, salesName: exclusive_name)
          } else if let data = data["data"] as? [[String: AnyObject]] where data.count > 0 {
            for sale in data {
              if let roleid = sale["roleid"] as? NSNumber {
                if roleid == 1 {
                 let salesid = sale["salesid"] as? String
                 let name = sale["name"] as? String
                self.createConversationWithSalesID(salesid!, salesName: name!)
                }
              }
            }
          } else {
            ZKJSTool.showMsg("商家暂无客服")
          }
        }
      }
    }
  }
  
  func createConversationWithSalesID(salesID: String, salesName: String) {
    hideHUD()
    if arrivaldate == nil || arrivaldate.isEmpty == true {
      ZKJSTool.showMsg("请填写时间")
      return
    }
    if self.roomsTypeLabel.text == "请选择房型" {
      ZKJSTool.showMsg("请选择房型")
      return
    }
    
    if roomsTextField.text <= "0" {
      ZKJSTool.showMsg("请添加房间数量")
      return
    }
    
    let userID = AccountManager.sharedInstance().userID
    var dic = [String: AnyObject]()
    dic["saleid"] = salesID
    dic["arrivaldate"] = self.arrivaldate
    dic["leavedate"] = self.leavedate
    dic["roomtype"] = self.roomsTypeLabel.text!
    dic["roomcount"] = Int(self.roomsTextField.text!)
    dic["orderedby"] = self.contactTextField.text
    dic["telephone"] = self.telphoneTextField.text
    dic["shopid"] = self.shopid
    dic["userid"] = userID
    dic["imgurl"] = goods.image
    dic["productid"] = goods.goodsid
    dic["roomno"] = ""
    dic["paytype"] = self.paytype
    dic["roomprice"] = ""
    dic["telephone"] = self.telphoneTextField.text
    dic["personcount"] = 1
//    dic["doublebreakfeast"] = breakfeastSwitch.on ? 1 : 0
    dic["nosmoking"] = isSmokingSwitch.on ? 1 : 0
    dic["company"] = invoinceLabel.text
    dic["remark"] = self.remarkTextView.text
    
    ZKJSJavaHTTPSessionManager.sharedInstance().addOrderWithCategory("0", data: dic, success: { (task:NSURLSessionDataTask!, responObjects:AnyObject!) -> Void in
      if let orderno = responObjects["data"] as? String {
        let vc = ChatViewController(conversationChatter: salesID, conversationType: .eConversationTypeChat)
        let order = self.packetOrderWithOrderNO(orderno)
        print(order)
        vc.title = self.shopName
        // 扩展字段
        let userName = AccountManager.sharedInstance().userName
        let ext = ["shopId": self.shopid.stringValue,
          "shopName": self.shopName,
          "toName": salesName,
          "fromName": userName]
        vc.conversation.ext = ext
        vc.firstMessage = "Card"
        vc.order = order
        self.navigationController?.pushViewController(vc, animated: true)
      }
      }) { (task:NSURLSessionDataTask!, error:NSError!) -> Void in
        print(error)
    }
  }

  func packetOrderWithOrderNO(orderNO: String) -> OrderDetailModel {
    let order = OrderDetailModel()
    order.roomtype = roomsTypeLabel.text!
    order.arrivaldate = arrivaldate
    order.leavedate = leavedate
    order.imgurl = goods.image
    order.orderno = orderNO
    order.orderstatus = "待处理"
    return order
  }
  
}

extension HotelOrderTVC: UITextViewDelegate {
  
  func textViewDidBeginEditing(textView: UITextView) {
    if textView.text == "如有其他需求，请在此说明" {
      textView.text = ""
      textView.textColor = UIColor.blackColor()
    }
    textView.becomeFirstResponder()
  }
  
  func textViewDidEndEditing(textView: UITextView) {
    if textView.text == "" {
      textView.text = "如有其他需求，请在此说明"
      textView.textColor = UIColor.lightGrayColor()
    }
    textView.resignFirstResponder()
  }
  
}
