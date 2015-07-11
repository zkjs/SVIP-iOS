//
//  BookConfirmVC.swift
//  SVIP
//
//  Created by dai.fengyi on 15/7/2.
//  Copyright (c) 2015年 zkjinshi. All rights reserved.
//

import UIKit
let buttonCount = 3
class BookConfirmVC: UIViewController {

  @IBOutlet private weak var roomLook: UIImageView!
  @IBOutlet private weak var name: UILabel!
  @IBOutlet private weak var price: UILabel!
  @IBOutlet private weak var preference: UILabel!
  @IBOutlet private weak var inDate: BookDateButton!
  @IBOutlet private weak var outDate: BookDateButton!
  
  @IBOutlet private var buttonMarginConstraintArray: [NSLayoutConstraint]!
  @IBOutlet private var optionButtonArray: [UIButton]!
  //DATA
  var goods:RoomGoods?
  private var order: BookOrder!
  
  override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
    super.init(nibName: "BookConfirmVC", bundle: nil)
  }
  
  required init(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
    loadData()
    setupUI()
    updateSubviews()
  }
  /*
  "id": "3",
  "shopid": "120",
  "room": "豪华",
  "image": "uploads/rooms/3.jpg",
  "type": "大床",
  "meat": "双早",
  "pice": "888.00",
  "logo": "uploads/shops/120.png",
  "fullname": "长沙芙蓉国温德姆至尊豪廷大酒店"
  */
  private func loadData() {
    order = BookOrder()
    if let selectedGoods = goods {
      order.room_typeid = selectedGoods.goodsid
      var room: String! = ""
      var type: String! = ""
      if selectedGoods.room != nil {
        room = selectedGoods.room!
      }
      if selectedGoods.type != nil {
        type = selectedGoods.type!
      }
      order.room_type = "\(room)\(type)"//有问题的，order与goods字段对不上
      order.room_rate = selectedGoods.pice
      order.rooms = "1"
      order.shopid = "1"
      order.guest = "laoliu"
      order.guesttel = "139758"
      order.arrival_date = "2015-12-1"
      order.departure_date = "2015-12-28"
    }
  }
  
  private func setupUI() {
    inDate.baseTitle = "入住时间"
    outDate.baseTitle = "离开时间"
    
    let baseUrl = "http://120.25.241.196/"
    if let goodsImage = goods?.image {
      let urlStr = baseUrl .stringByAppendingString(goodsImage)
      let placeholderImage = UIImage(named: "星空中心")
      let url = NSURL(string: urlStr)
      roomLook.sd_setImageWithURL(url, placeholderImage: placeholderImage, options: SDWebImageOptions.LowPriority | SDWebImageOptions.RetryFailed, completed: nil)
    }
    
    if let preference = order.room_type {
      self.preference.text = preference
    }
    
    for button in optionButtonArray {
      button.layer.borderColor = UIColor .grayColor().CGColor
      button.layer.borderWidth = 1
      button .addTarget(self, action: "optionSelect:", forControlEvents: UIControlEvents.TouchUpInside)
    }
  }
  
  override func updateViewConstraints() {
    var screenWidth = UIScreen.mainScreen().bounds.size.width
    var marginWidth = (Double(screenWidth) - Double(buttonCount) * 70.0) / Double(buttonCount + 1)
    for constrainst in buttonMarginConstraintArray {
      constrainst.constant = CGFloat(marginWidth)
    }
    super.updateViewConstraints()
  }
  
  private func updateSubviews() {
    if inDate.date == nil {
      var calender = NSCalendar .currentCalendar()
      var components = calender .components((NSCalendarUnit.YearCalendarUnit | NSCalendarUnit.MonthCalendarUnit | NSCalendarUnit.DayCalendarUnit), fromDate: NSDate())
      inDate.date = calender .dateFromComponents(components)
    }
    
    if outDate.date == nil {
      outDate.date = inDate.date?.dateByAddingTimeInterval(24 * 60 * 60)
    }
    
    let duration = outDate.date!.timeIntervalSinceDate(inDate.date!)
    let day = duration / 24 / 60 / 60
    let dayInt = Int(day)
    if let roomType = order.room_type {
      name.text = "\(roomType)    共\(dayInt)晚"
    }
    
    if let str = order.room_rate {
      let danjia = (str as NSString).integerValue
      let total = danjia * dayInt

      let dic = NSDictionary(objectsAndKeys: UIFont .systemFontOfSize(18) , NSFontAttributeName, UIColor.orangeColor(), NSForegroundColorAttributeName)
      let attriStr = NSAttributedString(string: "\(total)", attributes: dic as [NSObject : AnyObject])
      
      let dic1 = NSDictionary(objectsAndKeys: UIFont .systemFontOfSize(13) , NSFontAttributeName)
      var mutAttriStr = NSMutableAttributedString(string: "￥", attributes: dic1 as [NSObject : AnyObject])
      
      mutAttriStr .appendAttributedString(attriStr)
      price.attributedText = mutAttriStr
    }
    
  }
//MARK:- BUTTON ACTION
  @IBAction private func dateSelect(sender: BookDateButton) {

    BlurDatePickerView .showInView(self.view, startDate:sender == inDate ? NSDate() : (inDate.date?.dateByAddingTimeInterval(24 * 60 * 60)), success: { (date: NSDate!) -> Void in
      var calender = NSCalendar .currentCalendar()
      var components = calender .components((NSCalendarUnit.YearCalendarUnit | NSCalendarUnit.MonthCalendarUnit | NSCalendarUnit.DayCalendarUnit), fromDate: date)
      sender.date = calender .dateFromComponents(components)
      if sender == self.inDate {
        self.outDate.date = self.inDate.date?.dateByAddingTimeInterval(24 * 60 * 60)
      }
      self.updateSubviews()
    })
  }
  
  func optionSelect(sender: UIButton) {
    sender.selected = !sender.selected
  }
  /*
  [formData appendPartWithFormData:[userID dataUsingEncoding:NSUTF8StringEncoding] name:@"userid"];
  [formData appendPartWithFormData:[token dataUsingEncoding:NSUTF8StringEncoding] name:@"token"];
  [formData appendPartWithFormData:[shopID dataUsingEncoding:NSUTF8StringEncoding] name:@"shopid"];
  [formData appendPartWithFormData:[goodsID dataUsingEncoding:NSUTF8StringEncoding] name:@"room_typeid"];
  [formData appendPartWithFormData:[guest dataUsingEncoding:NSUTF8StringEncoding] name:@"guest"];
  [formData appendPartWithFormData:[guestPhone dataUsingEncoding:NSUTF8StringEncoding] name:@"guesttel"];
  [formData appendPartWithFormData:[arrivalDate dataUsingEncoding:NSUTF8StringEncoding] name:@"arrival_date"];
  [formData appendPartWithFormData:[departureDate dataUsingEncoding:NSUTF8StringEncoding] name:@"departure_date"];
  [formData appendPartWithFormData:[roomNum dataUsingEncoding:NSUTF8StringEncoding] name:@"rooms"];
  [formData appendPartWithFormData:[roomType dataUsingEncoding:NSUTF8StringEncoding] name:@"room_type"];
  [formData appendPartWithFormData:[roomRate dataUsingEncoding:NSUTF8StringEncoding] name:@"room_rate"];
  [formData appendPartWithFormData:[remark dataUsingEncoding:NSUTF8StringEncoding] name:@"remark"];
  [formData appendPartWithFormData:[@"1" dataUsingEncoding:NSUTF8StringEncoding] name:@"set"];
  */
  @IBAction private func commit(sender: UIButton) {
    var remark: String! = ""
    for optionButton in optionButtonArray {
      if optionButton.selected == true {
        remark = remark .stringByAppendingString(optionButton.titleLabel?.text as String!)
      }
    }
    order.remark = remark

    let account = JSHAccountManager .sharedJSHAccountManager()
    ZKJSHTTPSessionManager .sharedInstance() .postBookingInfoWithUserID(account.userid, token: account.token, shopID: order.shopid, goodsID: order.room_typeid, guest: order.guest, guestPhone: order.guesttel, roomNum: order.rooms, arrivalDate: order.arrival_date, departureDate: order.departure_date, roomType: order.room_type, roomRate: order.room_rate, remark: order.remark, success: { (task: NSURLSessionDataTask!, responseObject: AnyObject!) -> Void in
        let payVC = BookPayVC()
        payVC.bkOrder = self.order
        let dic = responseObject as! NSDictionary
        if let orderno = (dic["orderno"] as? String) {
          payVC.bkOrder.orderno = orderno
        }
        self.navigationController? .pushViewController(payVC, animated: true)
      }) { (task: NSURLSessionDataTask!, error: NSError!) -> Void in
    }
  }
}
