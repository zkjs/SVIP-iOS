//
//  DotLine.swift
//  SVIP
//
//  Created by Hanton on 6/30/15.
//  Copyright (c) 2015 zkjinshi. All rights reserved.
//

import UIKit

class DotLine: UIImageView {
  
  override func layoutSubviews() {
    UIGraphicsBeginImageContext(bounds.size);
    image?.drawInRect(CGRectMake(0.0, 0.0, bounds.size.width, bounds.size.height))
    CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
    let dashArray:[CGFloat] = [2, 2]
    let context = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(context, UIColor.grayColor().CGColor);
    CGContextSetLineDash(context, 0, dashArray, 2);
    CGContextMoveToPoint(context, 0.0, 0.0);
    CGContextAddLineToPoint(context, bounds.size.width, 0.0);
    CGContextStrokePath(context);
    image = UIGraphicsGetImageFromCurrentImageContext();
  }
}
