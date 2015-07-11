//
//  BookItemButton.swift
//  SVIP
//
//  Created by dai.fengyi on 15/7/2.
//  Copyright (c) 2015年 zkjinshi. All rights reserved.
//

import UIKit

class BookItemButton: UIButton {
  required init(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    self.titleLabel?.textAlignment = NSTextAlignment.Center
    self.imageView?.contentMode = UIViewContentMode.Center
  }
  override init(frame: CGRect) {
    super.init(frame: frame)
    self.titleLabel?.textAlignment = NSTextAlignment.Center
    self.imageView?.contentMode = UIViewContentMode.Center
  }
  
  override func imageRectForContentRect(contentRect: CGRect) -> CGRect {
    let imageX : CGFloat = 0;
    let imageY : CGFloat = 0;
    let imageWidth = contentRect.size.width
    let imageHeight = contentRect.size.height * (1 - 0.3)
    return CGRectMake(imageX, imageY, imageWidth, imageHeight)
  }
  
  override func titleRectForContentRect(contentRect: CGRect) -> CGRect {
    let titleX : CGFloat = 0
    let titleHeight = contentRect.size.height * 0.3
    let titleY = contentRect.size.height - titleHeight - 3
    let titleWidth = contentRect.size.width
    return CGRectMake(titleX, titleY, titleWidth, titleHeight)
  }
  
}
