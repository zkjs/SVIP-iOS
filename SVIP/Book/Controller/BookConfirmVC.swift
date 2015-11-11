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
  
  var goods:RoomGoods?
  
  private var order: BookOrder!
  
  
  // MARK: - Initialization
  
  override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
    super.init(nibName: "BookConfirmVC", bundle: nil)
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  
  // MARK: - View Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    loadData()
    setupUI()
    updateSubviews()
  }
  
  
  // MARK: - Constraints
  
  override func updateViewConstraints() {
    let screenWidth = UIScreen.mainScreen().bounds.size.width
    let marginWidth = (Double(screenWidth) - Double(buttonCount) * 70.0) / Double(buttonCount + 1)
    for constrainst in buttonMarginConstraintArray {
      constrainst.constant = CGFloat(marginWidth)
    }
    super.updateViewConstraints()
  }
  
  
  // MARK: - Private

  private func loadData() {
    order = BookOrder()
    if let selectedGoods = goods {
      order.room_typeid = selectedGoods.goodsid
      var room = ""
      var type = ""
      if let goodsRoom = selectedGoods.room {
        room = goodsRoom
      }
      if let goodsType = selectedGoods.type {
        type = goodsType
      }
      order.room_type = "\(room)\(type)"//有问题的，order与goods字段对不上
      order.room_rate = selectedGoods.price
      order.rooms = "1"
      order.shopid = selectedGoods.shopid
      let localBaseInfo = JSHStorage.baseInfo()
      order.guest = localBaseInfo.username
      order.guesttel = localBaseInfo.phone
    }
  }
  
  private func setupUI() {
    inDate.baseTitle = "入住时间"
    outDate.baseTitle = "离开时间"
    
    let baseUrl = kBaseURL
    if let goodsImage = goods?.image {
      let placeholderImage = UIImage(named: "星空中心")
      var url = NSURL(string: baseUrl)
      url = url?.URLByAppendingPathComponent(goodsImage)
      roomLook.sd_setImageWithURL(url,
        placeholderImage: placeholderImage,
        options: [SDWebImageOptions.LowPriority, SDWebImageOptions.RetryFailed],
        completed: nil)
    }
    
    if let remark = order.remark {
      preference.text = remark
    }
    
    for button in optionButtonArray {
      button.layer.borderColor = UIColor.grayColor().CGColor
      button.layer.borderWidth = 1
      button.addTarget(self, action: "optionSelect:", forControlEvents: .TouchUpInside)
    }
  }
  
  private func updateSubviews() {
    if inDate.date == nil {
      let calender = NSCalendar.currentCalendar()
      let components = calender.components(([.Year, .Month, .Day]), fromDate: NSDate())
      inDate.date = calender.dateFromComponents(components)
    }
    
    if outDate.date == nil {
      outDate.date = inDate.date?.dateByAddingTimeInterval(24 * 60 * 60)
    }
    
    let duration = outDate.date!.timeIntervalSinceDate(inDate.date!)
    let day = duration / 24 / 60 / 60
    let dayInt = Int(day)
    order.dayInt = String(dayInt)
    if let roomType = order.room_type {
      name.text = "\(roomType)    共\(dayInt)晚"
    }
    
    if let str = order.room_rate {
      let danjia = (str as NSString).integerValue
      let total = danjia * dayInt

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
      price.attributedText = mutAttriStr
    }
    
  }
  
  
  //MARK: - Button Action
  
  func optionSelect(sender: UIButton) {
    sender.selected = !sender.selected
  }
  
  @IBAction private func dateSelect(sender: BookDateButton) {
    let vc = BookDateSelectionViewController()
    vc.selection = { [unowned self] (startDate: NSDate, endDate: NSDate) ->() in
      self.inDate.date = startDate
      self.outDate.date = endDate
    }
    self.navigationController?.pushViewController(vc, animated: true)
  }

  @IBAction private func commit(sender: UIButton) {
    var remark: String?
    for optionButton in optionButtonArray {
      if optionButton.selected == true {
        if remark == nil {
          remark = optionButton.titleLabel?.text as String!
        }else {
          remark = remark!.stringByAppendingString(",\(optionButton.titleLabel?.text as String!)")
        }
      }
    }
    if remark == nil {
      order.remark = ""
    } else {
      order.remark = remark
    }
    order.arrival_date = inDate.dateString
    order.departure_date = outDate.dateString
    ZKJSHTTPSessionManager.sharedInstance().postBookingInfoWithShopID(order.shopid,
      goodsID: order.room_typeid,
      guest: order.guest,
      guestPhone: order.guesttel,
      roomNum: order.rooms,
      arrivalDate: order.arrival_date,
      departureDate: order.departure_date,
      roomType: order.room_type,
      roomRate: order.room_rate,
      remark: order.remark,
      success: { (task: NSURLSessionDataTask!, responseObject: AnyObject!) -> Void in
        let payVC = BookPayVC()
        payVC.bkOrder = self.order
        let dic = responseObject as! NSDictionary
        if let reservation_no = dic["reservation_no"] as? String {
          payVC.bkOrder.reservation_no = reservation_no
        }
        self.navigationController?.pushViewController(payVC, animated: true)
      }) { (task: NSURLSessionDataTask!, error: NSError!) -> Void in
        
    }
  }
  
}
