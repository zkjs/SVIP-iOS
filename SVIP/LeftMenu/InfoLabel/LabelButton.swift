//
//  LabelButton.swift
//  SVIP
//
//  Created by dai.fengyi on 15/8/24.
//  Copyright (c) 2015年 zkjinshi. All rights reserved.
//

import UIKit

class LabelButton: UIButton {
  let kButtonMargin: CGFloat = 20
  let kButtonMinW: CGFloat = 60
  var edit : Bool {//可否自定义 isedit???
    didSet {
      delLogo.hidden = !edit
    }
  }
  private let delLogo = UIImageView(image: UIImage(named: "ic_shanchu_nor"))
  
  required init(title: NSString!, edit: Bool) {
    self.edit = edit
    let size = title.boundingRectWithSize(CGSizeMake(CGFloat.max, CGFloat.max), options: NSStringDrawingOptions.allZeros, attributes: [NSFontAttributeName: UIFont.systemFontOfSize(14)], context: nil)
    let buttonW = size.width + kButtonMargin > 40 ? size.width + kButtonMargin : kButtonMinW
    super.init(frame: CGRectMake(0, 0, buttonW, size.height))
    setUI()
  }
//是否还需要便捷初始化方法???
  convenience init(dic:NSDictionary, edit:Bool) {
    //此tag非彼tag，这里有两个tag
    let tag = dic["tag"] as! String
    self.init(title:tag, edit: edit)
    let tagid = dic["tagid"]!.integerValue!
    self.tag = tagid
  }
  
  required init(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
  }
  
  private func setUI() {
    layer.borderWidth = 1;
    layer.borderColor = UIColor.lightGrayColor().CGColor
    layer.cornerRadius = self.frame.height
    
    titleLabel?.font = UIFont.systemFontOfSize(14)
    setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
    
    delLogo.frame = CGRect(origin: CGPointZero, size: CGSizeMake(12, 12))
    delLogo.center = CGPointMake(self.frame.size.width - 2, 2)
    addSubview(delLogo)
    
  }
  
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
