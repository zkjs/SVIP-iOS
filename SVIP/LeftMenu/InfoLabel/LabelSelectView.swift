//
//  LabelSelectView.swift
//  SVIP
//
//  Created by dai.fengyi on 15/8/24.
//  Copyright (c) 2015年 zkjinshi. All rights reserved.
//

import UIKit
protocol LabelSelectViewDelegate {
  func labelSelectView(labelSelectView: LabelSelectView, didSelected dic: NSDictionary ,index: Int)
}
class LabelSelectView: UIView {
  let kMarginW: CGFloat = 8
  let kMarginH: CGFloat = 8
  let kButtonHeight: CGFloat = 30
  
  var delegate: LabelSelectViewDelegate?//若引用???
  var height: CGFloat = 0
  var edit: Bool
  let dataArray: NSMutableArray
  
  required init(array: NSArray, edit: Bool) {
    self.edit = edit
    self.dataArray = NSMutableArray(array: array)
    super.init(frame: CGRectZero)
  }

  required init?(coder aDecoder: NSCoder) {
    edit = false
    dataArray = NSMutableArray()
    super.init(coder: aDecoder)
  }
  
  func addItem(dic: NSDictionary) {
    //判断是否存在
    for d in dataArray {
      if d as! NSObject == dic {
        return
      }
    }
    //增加数据
    dataArray.addObject(dic)
    
    //设置button
    let labelBtn = LabelButton(dic: dic, edit: edit)
    let title = dic["tag"] as? String
    labelBtn.setTitle(title, forState: UIControlState.Normal)
    labelBtn.addTarget(self, action: NSSelectorFromString("buttonClick:"), forControlEvents: UIControlEvents.TouchUpInside)
    
    //处理UI
    setItemsPosition(labelBtn)
    addSubview(labelBtn)
    
    //改view height
    height = CGRectGetMaxY(labelBtn.frame) + kMarginH
  }
  
  func removeItem(index: Int) {//比较拙，直接remove然后add
    //处理数据
    dataArray.removeObjectAtIndex(index)
    // 处理UI
    if let labelBtn = subviews[index] as? LabelButton {
      labelBtn.removeFromSuperview()
    }
    let buttonArr = subviews
    for btn in buttonArr {
      btn.removeFromSuperview()
    }
    
    for button in buttonArr {
      if let btn = button as? LabelButton {
        setItemsPosition(btn)
        addSubview(btn)
      }
    }
    //改view height
    if subviews.count != 0 {
      height = CGRectGetMaxY(subviews.last!.frame) + kMarginH
    }else {
      height = 0
    }
    
  }
  
  private func setItemsPosition(button: LabelButton) {
    let buttonSize = CGSizeMake(button.frame.width, kButtonHeight)
    var buttonOrigin = CGPointZero
    if let lastObject = subviews.last {
      let lastObjectMaxX = CGRectGetMaxX(lastObject.frame)
      if lastObjectMaxX + buttonSize.width + 2 * kMarginW > self.bounds.width {//超过宽度
        buttonOrigin.x = kMarginW
        buttonOrigin.y = CGRectGetMaxY(lastObject.frame) + kMarginH
      }else {//未超宽
        buttonOrigin.x = CGRectGetMaxX(lastObject.frame) + kMarginW
        buttonOrigin.y = lastObject.frame.origin.y
      }
    }else {//第一个
      buttonOrigin.x = kMarginW
      buttonOrigin.y = kMarginH
    }
    button.frame = CGRect(origin: buttonOrigin, size: buttonSize)
  }
  
  //MARK:- Button Action
  func buttonClick(sender: UIButton) {
    let arr = subviews as NSArray
    let index = arr.indexOfObject(sender)
    self.delegate?.labelSelectView(self, didSelected: dataArray[index] as! NSDictionary, index: index)
  }
}
