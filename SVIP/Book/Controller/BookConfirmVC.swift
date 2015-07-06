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
//MARK:- BUTTON ACTION
  @IBAction func dateSelect(sender: BookDateButton) {

    BlurDatePickerView .showInView(self.view, success: { (date: NSDate!) -> Void in
      sender.date = date
      print(date)
    })
    
  }
  
  func optionSelect(sender: UIButton) {
    sender.selected = !sender.selected
  }
  
  @IBAction func commit(sender: UIButton) {
  self.navigationController? .pushViewController(BookPayVC.new(), animated: true)
  }


}
