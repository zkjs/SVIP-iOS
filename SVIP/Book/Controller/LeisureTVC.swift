//
//  LeisureTVC.swift
//  SVIP
//
//  Created by AlexBang on 15/12/30.
//  Copyright © 2015年 zkjinshi. All rights reserved.
//

import UIKit

class LeisureTVC: UITableViewController {

  @IBOutlet weak var countSubtractButton: UIButton! {
    didSet {
      countSubtractButton.addTarget(self, action: "countSubtract:", forControlEvents: UIControlEvents.TouchUpInside)
    }
  }

  @IBOutlet weak var countAddBUtton: UIButton! {
    didSet {
      countAddBUtton.addTarget(self, action: "countAdd:", forControlEvents: UIControlEvents.TouchUpInside)
    }
  }

  @IBOutlet weak var invoinceLabel: UILabel!
  @IBOutlet weak var remarkTextView: UITextView!
  @IBOutlet weak var telphotoTextField: UITextField!
  @IBOutlet weak var contacterTextField: UITextField!
  @IBOutlet weak var personNumberTextField: UITextField!
  @IBOutlet weak var arrviteDateLabel: UITextField!
  @IBOutlet weak var roomImage: UIImageView!
  
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
      setUpUI()

    }
  
  func setUpUI() {
    self.personNumberTextField.text = String(roomsCount)
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
    view.endEditing(true)
  }
  
  func chooseRoomType() {
    
  }

  @IBAction func textFieldEditing(sender: UITextField) {
    toolBar.frame = CGRectMake(0, 0, 0, 40)
    arrviteDateLabel.inputAccessoryView = toolBar
    let doneItem = UIBarButtonItem(title: "确认", style: UIBarButtonItemStyle.Done, target: self, action: "sure")
    let btn1 =  UIBarButtonItem(barButtonSystemItem:UIBarButtonSystemItem.FlexibleSpace,
      target:nil, action:nil);
    doneItem.tintColor = UIColor.ZKJS_mainColor()
    toolBar.items = [btn1,doneItem]
    datePickerView.datePickerMode = UIDatePickerMode.DateAndTime
    sender.inputView = datePickerView
    datePickerView.addTarget(self, action: Selector("datePickerValueChanged:"), forControlEvents: UIControlEvents.ValueChanged)
  }

  
  func sure() {
    arrviteDateLabel.text = ""
    let selectedDate = self.datePickerView.date
    let dateFormatter = NSDateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    let dateString = dateFormatter.stringFromDate(selectedDate)
    arrviteDateLabel.text = dateString
    view.endEditing(true)
  }
  
  func datePickerValueChanged(sender:UIDatePicker) {
    let dateFormatter = NSDateFormatter()
    dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
    dateFormatter.timeStyle = NSDateFormatterStyle.NoStyle
    arrviteDateLabel.text = dateFormatter.stringFromDate(sender.date)
    
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
  
  
  @IBAction func submitOrder(sender: AnyObject) {
    submitOrder()
  }
  
  // MARK: - UITextFieldDelegate
  func textFieldShouldReturn(textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    return false
  }

  func submitOrder() {
    print("11")
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
            ZKJSTool.showMsg("暂无客服")
          }
        }
      }
    }
  }
  
  func createConversationWithSalesID(salesID: String, salesName: String) {
    if arrviteDateLabel.text == nil  {
      ZKJSTool.showMsg("请填写时间")
      return
    }
    
    let userID = AccountManager.sharedInstance().userID
    var dic = [String: AnyObject]()
    dic["saleid"] = salesID
    dic["arrivaldate"] = self.arrviteDateLabel.text
    dic["leavedate"] = self.leavedate
    dic["roomtype"] = ""
    dic["roomcount"] = nil
    dic["orderedby"] = self.contacterTextField.text
    dic["telephone"] = self.telphotoTextField.text
    dic["shopid"] = self.shopid
    dic["userid"] = userID
    dic["imgurl"] = ""
    dic["productid"] = ""//goods.goodsid
    dic["roomno"] = ""
    dic["paytype"] = ""
    dic["roomprice"] = ""
    dic["personcount"] = 1
    dic["doublebreakfeast"] = 1
    dic["nosmoking"] = 1
    dic["company"] = ""
    dic["remark"] = self.remarkTextView.text
    
    ZKJSJavaHTTPSessionManager.sharedInstance().addOrderWithCategory("2", data: dic, success: { (task:NSURLSessionDataTask!, responObjects:AnyObject!) -> Void in
      print(responObjects)
      let vc = ChatViewController(conversationChatter: salesID, conversationType: .eConversationTypeChat)
      let order = self.packetOrder()
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
      self.navigationController?.pushViewController(vc, animated: true)
      }) { (task:NSURLSessionDataTask!, error:NSError!) -> Void in
        
    }
  }
  
  func packetOrder() -> BookOrder {
    let order = BookOrder()
    order.shopid = shopid
    order.rooms = NSNumber(integer: Int(personNumberTextField.text!)!)
    order.room_typeid = goods.goodsid
    order.room_type = ""
    order.fullname = shopName
    order.room_image_URL = goods.image
    let dateFormatter = NSDateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    order.arrival_date = arrivaldate
    order.departure_date = leavedate
    order.guest = contacterTextField.text
    order.guesttel = telphotoTextField.text
    order.room_image = roomImage.image
    return order
  }


  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    navigationController?.navigationBar.translucent = false
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
