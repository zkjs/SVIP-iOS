//
//  KTVTableView.swift
//  SVIP
//
//  Created by AlexBang on 15/12/30.
//  Copyright © 2015年 zkjinshi. All rights reserved.
//

import UIKit

class KTVTableView: UITableViewController {

  @IBOutlet weak var roomTypeLabel: UILabel!

  
  @IBOutlet weak var dateTextField: UITextField!
  
  @IBOutlet weak var invoinceLabel: UILabel!
  @IBOutlet weak var roomsTextField: UITextField!
  @IBOutlet weak var roomImage: UIImageView!
  @IBOutlet weak var remarkView: UITextView!

  @IBOutlet weak var telphonetextFiled: UITextField!
  @IBOutlet weak var contacterTextFiled: UITextField!
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
  var goods: RoomGoods!
  var datePickerView = UIDatePicker()
  var toolBar = UIToolbar()

    override func viewDidLoad() {
        super.viewDidLoad()
      title = shopName
      roomImage.image = UIImage(named: "bg_dingdanzhuangtai")
      setUpUI()

      
    }
  
  func setUpUI() {
    self.roomsTextField.text = String(roomsCount)
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = super.tableView(tableView, cellForRowAtIndexPath: indexPath)
    cell.selectionStyle = UITableViewCellSelectionStyle.None
    return cell
  }
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    if indexPath == NSIndexPath(forRow: 1, inSection: 0) {
      chooseRoomType()
    }
    if indexPath == NSIndexPath(forRow: 1, inSection: 2) {
      let vc = InvoiceVC()
      vc.selection = { [unowned self] (invoice:  InvoiceModel) ->() in
        self.invoinceLabel.text = invoice.title
      }
      self.navigationController?.pushViewController(vc, animated: true)
    }
    
  }

  @IBAction func textFieldEditing( sender: UITextField) {
    toolBar.frame = CGRectMake(0, 0, 0, 40)
    dateTextField.inputAccessoryView = toolBar
    let doneItem = UIBarButtonItem(title: "确认", style: UIBarButtonItemStyle.Done, target: self, action: "sure")
    let btn1 =  UIBarButtonItem(barButtonSystemItem:UIBarButtonSystemItem.FlexibleSpace,
      target:nil, action:nil);
        doneItem.tintColor = UIColor.ZKJS_mainColor()
    toolBar.items = [btn1,doneItem]
    datePickerView.datePickerMode = UIDatePickerMode.DateAndTime
    sender.inputView = datePickerView
    datePickerView.addTarget(self, action: Selector("datePickerValueChanged:"), forControlEvents: UIControlEvents.ValueChanged)
  }
  
  func chooseRoomType() {
   
  }
  
  func sure() {
    let selectedDate = self.datePickerView.date
    let dateFormatter = NSDateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    let dateString = dateFormatter.stringFromDate(selectedDate)
    dateTextField.text = dateString
    view.endEditing(true)
  }
  
  func datePickerValueChanged(sender:UIDatePicker) {
    let dateFormatter = NSDateFormatter()
    dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
    dateFormatter.timeStyle = NSDateFormatterStyle.NoStyle
    dateTextField.text = dateFormatter.stringFromDate(sender.date)
    
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


  // MARK: - UITextFieldDelegate
  func textFieldShouldReturn(textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    return false
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    navigationController?.navigationBar.translucent = false
  }
  
  @IBAction func submitOrder(sender: AnyObject) {
    submitOrder()
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
          } else {
            ZKJSTool.showMsg("商家暂无客服")
          }
        }
      }
    }
  }
  
  func createConversationWithSalesID(salesID: String, salesName: String) {
    if dateTextField.text == "" {
      ZKJSTool.showMsg("请填写时间")
      return
    }
    if self.roomTypeLabel.text == "请选择房型" {
      ZKJSTool.showMsg("请选择房型")
      return
    }
    
    let userID = AccountManager.sharedInstance().userID
    var dic = [String: AnyObject]()
    dic["saleid"] = salesID
    dic["arrivaldate"] = dateTextField.text
    dic["leavedate"] = self.leavedate
    dic["roomtype"] = self.roomTypeLabel.text!
    dic["roomcount"] = Int(self.roomsTextField.text!)
    dic["orderedby"] = self.contacterTextFiled.text
    dic["telephone"] = self.telphonetextFiled.text
    dic["shopid"] = self.shopid
    dic["userid"] = userID
    dic["imgurl"] = ""
    dic["productid"] = ""
    dic["roomno"] = ""
    dic["paytype"] = ""
    dic["roomprice"] = ""
    dic["personcount"] = 1
    dic["doublebreakfeast"] = 1
    dic["nosmoking"] = 1
    dic["company"] = ""
    dic["remark"] = self.remarkView.text
   
    
    ZKJSJavaHTTPSessionManager.sharedInstance().addOrderWithCategory("1", data: dic, success: { (task:NSURLSessionDataTask!, responObjects:AnyObject!) -> Void in
      print(responObjects)
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
    order.roomtype = ""
    order.arrivaldate = arrivaldate
    order.leavedate = leavedate
    order.imgurl = goods.image
    order.orderno = orderNO
    order.orderstatus = "待处理"
    return order
  }
  
  override func viewWillDisappear(animated: Bool) {
    super.viewWillDisappear(animated)
    navigationController?.navigationBar.translucent = true
  }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

//    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
//        // #warning Incomplete implementation, return the number of sections
//        return 0
//    }
//
//    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        // #warning Incomplete implementation, return the number of rows
//        return 0
//    }

    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
