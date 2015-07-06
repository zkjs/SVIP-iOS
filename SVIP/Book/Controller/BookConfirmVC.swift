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

  @IBOutlet weak var avatar: UIImageView!
  @IBOutlet weak var name: UILabel!
  @IBOutlet weak var price: UILabel!
  @IBOutlet weak var inDate: BookDateButton!
  @IBOutlet weak var outDate: BookDateButton!
  
  @IBOutlet var buttonMarginConstraintArray: [NSLayoutConstraint]!
  @IBOutlet var optionButtonArray: [UIButton]!
  //DATA
  var order: BookOrder?
  
  override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
    super.init(nibName: "BookConfirmVC", bundle: nil)
  }
  
  required init(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
    setupUI()
    updateSubviews()
  }
  
  func setupUI() {
    inDate.baseTitle = "入住时间"
    outDate.baseTitle = "离开时间"
    
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
      price.text = "预计价格：￥\(total)"
    }
    
//    price.text = "预计价格：\(totalMoney)"
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
