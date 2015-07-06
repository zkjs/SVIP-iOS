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

  @IBOutlet weak var roomLook: UIImageView!
  @IBOutlet weak var name: UILabel!
  @IBOutlet weak var price: UILabel!
  @IBOutlet weak var preference: UILabel!
  @IBOutlet weak var inDate: BookDateButton!
  @IBOutlet weak var outDate: BookDateButton!
  
  @IBOutlet var buttonMarginConstraintArray: [NSLayoutConstraint]!
  @IBOutlet var optionButtonArray: [UIButton]!
  //DATA
  var goods:RoomGoods?
  private var order: BookOrder?
  
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
  
  func loadData() {
    order = BookOrder()
    if let selectedGoods = goods {
      order!.room_typeid = selectedGoods.goodsid
      order!.room_type = selectedGoods.name
      order!.room_rate = selectedGoods.market_price
      order!.rooms = "1"
    }
  }
  
  func setupUI() {
    inDate.baseTitle = "入住时间"
    outDate.baseTitle = "离开时间"
    
    let baseUrl = "http://172.21.7.54/"
    if let goodsImage = goods?.goods_img {
      let urlStr = baseUrl .stringByAppendingString(goodsImage)
      let placeholderImage = UIImage(named: "星空中心")
      let url = NSURL(string: urlStr)
      roomLook.sd_setImageWithURL(url, placeholderImage: placeholderImage, options: SDWebImageOptions.LowPriority | SDWebImageOptions.RetryFailed, completed: nil)
    }
    
    if let preference = goods?.keywords {
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
  
  func updateSubviews() {
    if inDate.date == nil {
      inDate.date = NSDate()
    }
    
    if outDate.date == nil {
      outDate.date = inDate.date?.dateByAddingTimeInterval(24 * 60 * 60)
    }
    
    let duration = outDate.date!.timeIntervalSinceDate(inDate.date!)
    let day = duration / 24 / 60 / 60
    let dayInt = Int(day)
    if let roomType = order?.room_type {
      name.text = "\(roomType)    共\(dayInt)晚"
    }
    
    if let str = order?.room_rate {
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
  @IBAction func dateSelect(sender: BookDateButton) {

    BlurDatePickerView .showInView(self.view, startDate:sender == inDate ? NSDate() : (inDate.date?.dateByAddingTimeInterval(24 * 60 * 60)), success: { (date: NSDate!) -> Void in
      sender.date = date
      if sender == self.inDate {
        self.outDate.date = self.inDate.date?.dateByAddingTimeInterval(24 * 60 * 60)
      }
      self.updateSubviews()
    })
  }
  
  func optionSelect(sender: UIButton) {
    sender.selected = !sender.selected
  }
  
  @IBAction func commit(sender: UIButton) {
  self.navigationController? .pushViewController(BookPayVC.new(), animated: true)
  }


}
