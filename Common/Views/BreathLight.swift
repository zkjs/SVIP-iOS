//
//  BreathLight.swift
//  SVIP
//
//  Created by Qin Yejun on 3/19/16.
//  Copyright © 2016 zkjinshi. All rights reserved.
//

import UIKit

let π:CGFloat = CGFloat(M_PI)

@IBDesignable
class BreathLight: UIControl {
  @IBInspectable
  var lineColor: UIColor = UIColor(hex: "#ffc56e") {
    didSet {
      setNeedsDisplay()
    }
  }
  @IBInspectable
  var lineWidth: Double = 2 {
    didSet {
      setNeedsDisplay()
    }
  }
  
  override func drawRect(rect: CGRect) {
    let center = CGPoint(x:bounds.width/2, y: bounds.height/2)
    let arcWidth:CGFloat = CGFloat(lineWidth)
    let startAngle: CGFloat = 0
    let endAngle: CGFloat = 2 * π
    
    let maxRadius: CGFloat = max(bounds.width, bounds.height) / 2
    
    // outer circle
    let path = UIBezierPath(arcCenter: center,
      radius: maxRadius - arcWidth/2,
      startAngle: startAngle,
      endAngle: endAngle,
      clockwise: true)
    
    path.lineWidth = arcWidth
    lineColor.setStroke()
    path.stroke()
    
    // middle circle
    let radiusMiddle: CGFloat = maxRadius / 2
    let pathMiddle = UIBezierPath(arcCenter: center,
      radius: radiusMiddle,
      startAngle: startAngle,
      endAngle: endAngle,
      clockwise: true)
    
    pathMiddle.lineWidth = arcWidth
    lineColor.setStroke()
    pathMiddle.stroke()
    
    //innder dot
    let innerDot = UIBezierPath(arcCenter: center,
      radius: CGFloat(lineWidth) - arcWidth/2,
      startAngle: startAngle,
      endAngle: endAngle,
      clockwise: true)
    
    innerDot.lineWidth = arcWidth
    lineColor.setStroke()
    innerDot.stroke()
  }
  
  func startAnimation(duration:NSTimeInterval = 0.5) {
    let opacityAnim = CABasicAnimation(keyPath: "opacity")
    opacityAnim.fromValue = 1.0
    opacityAnim.toValue = 0.5
    opacityAnim.autoreverses = true
    opacityAnim.duration = duration
    opacityAnim.repeatCount = .infinity
    self.layer.addAnimation(opacityAnim, forKey: "keyBreath")
  }
  
  func stopAnimation() {
    self.layer.removeAnimationForKey("keyBreath")
  }
}
