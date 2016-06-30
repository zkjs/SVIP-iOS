//
//  NumberControl.swift
//  SVIP
//
//  Created by Qin Yejun on 6/29/16.
//  Copyright © 2016 zkjinshi. All rights reserved.
//

import Foundation

@objc protocol NumbersControlDelegate {
  func numberChanged(control:NumbersControl) -> ()
}

class NumbersControl: UIView {
  weak var delegate : NumbersControlDelegate?
  var initialValue:Int = 1 {
    didSet {
      currentValue = initialValue
      textLabel.text = "\(currentValue)"
      updateButtonsState()
    }
  }
  var minValue:Int = 0 {
    didSet {
      updateButtonsState()
    }
  }
  var maxValue:Int = 0 {
    didSet {
      updateButtonsState()
    }
  }
  
  var disable:Bool = false {
    didSet {
      if disable {
        minusButton.enabled = false
        addButton.enabled = false
      } else {
        updateButtonsState()
      }
    }
  }
  
  var textColor:UIColor = UIColor.blackColor()
  var minusImage:UIImage = UIImage(named:"ic_minus_yellow")!
  var minusDisabledImage:UIImage = UIImage(named: "ic_minus_gray")!
  var addImage:UIImage = UIImage(named: "ic_add_yellow")!
  var addDisabledImage:UIImage = UIImage(named: "ic_add_gray")!
  
  var currentVal : Int {
    return currentValue
  }
  
  
  private let BUTTON_SIZE = CGFloat(30)
  
  private var textLabel : UILabel!
  private var minusButton : UIButton!
  private var addButton : UIButton!
  private var currentValue: Int = 0
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    initializeControls()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    initializeControls()
  }
  
  func initializeControls() {
    currentValue = initialValue
    minusButton = UIButton(frame: CGRectMake(0, (self.frame.height - BUTTON_SIZE)/2, BUTTON_SIZE, BUTTON_SIZE))
    addButton = UIButton(frame: CGRectMake(self.frame.width-BUTTON_SIZE, (self.frame.height - BUTTON_SIZE)/2, BUTTON_SIZE, BUTTON_SIZE))
    textLabel = UILabel(frame: CGRectMake(BUTTON_SIZE, 0, (self.frame.width - BUTTON_SIZE * 2 ), self.frame.size.height))
    textLabel.textAlignment = NSTextAlignment.Center
    
    textLabel.text = "\(initialValue)"
    minusButton.setImage(minusImage, forState: .Normal)
    minusButton.setImage(minusDisabledImage, forState: .Disabled)
    addButton.setImage(addImage, forState: .Normal)
    addButton.setImage(addDisabledImage, forState: .Disabled)
    
    addSubview(textLabel)
    addSubview(minusButton)
    addSubview(addButton)
    
    minusButton.addTarget(self, action: #selector(minusAction), forControlEvents: UIControlEvents.TouchUpInside)
    addButton.addTarget(self, action: #selector(addAction), forControlEvents: UIControlEvents.TouchUpInside)
    updateButtonsState()
    
  }
  
  func updateButtonsState() {
    if currentValue <= minValue {
      currentValue = minValue
      minusButton.enabled = false
    } else {
      minusButton.enabled = true
    }
    
    if maxValue > minValue {
      if currentValue >= maxValue {
        currentValue = maxValue
        addButton.enabled = false
      } else {
        addButton.enabled = true
      }
    } else {
      addButton.enabled = true
    }
  }
  
  func minusAction() {
    if currentValue > minValue {
      currentValue -= 1
      textLabel.text = "\(currentValue)"
    }
    updateButtonsState()
    delegate?.numberChanged(self)
  }
  
  func addAction() {
    if (maxValue   > minValue && currentValue < maxValue) || maxValue <= minValue {
      currentValue += 1
      textLabel.text = "\(currentValue)"
    }
    updateButtonsState()
    delegate?.numberChanged(self)
  }
  
  
}
