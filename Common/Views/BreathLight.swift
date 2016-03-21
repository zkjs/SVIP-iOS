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
  private(set) var isAnimating = false
  //let outerCircleLayer = CAShapeLayer()
  //let middleCircleLayer = CAShapeLayer()
  //let innerDotLayer = CAShapeLayer()
  
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
  
  /*
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    
    let maxRadius: CGFloat = max(bounds.width, bounds.height) / 2
    let pathWidth = CGFloat(lineWidth)
    
    outerCircleLayer.strokeColor = lineColor.CGColor
    outerCircleLayer.fillColor = UIColor.clearColor().CGColor
    outerCircleLayer.lineWidth = pathWidth
    outerCircleLayer.path = UIBezierPath(ovalInRect: CGRect(
      x: frame.size.width/2 - maxRadius,
      y: frame.size.height/2 - maxRadius,
      width: 2 * maxRadius,
      height: 2 * maxRadius)
      ).CGPath
    layer.addSublayer(outerCircleLayer)
    
    middleCircleLayer.strokeColor = lineColor.CGColor
    middleCircleLayer.fillColor = UIColor.clearColor().CGColor
    middleCircleLayer.lineWidth = pathWidth
    middleCircleLayer.path = UIBezierPath(ovalInRect: CGRect(
      x: frame.size.width/2 - maxRadius/2 - pathWidth/2,
      y: frame.size.height/2 - maxRadius/2 - pathWidth/2,
      width: maxRadius + pathWidth,
      height: maxRadius + pathWidth)
      ).CGPath
    layer.addSublayer(middleCircleLayer)
    
    innerDotLayer.strokeColor = lineColor.CGColor
    innerDotLayer.fillColor = lineColor.CGColor
    innerDotLayer.lineWidth = pathWidth
    innerDotLayer.path = UIBezierPath(ovalInRect: CGRect(
      x: frame.size.width/2 - pathWidth,
      y: frame.size.height/2 - pathWidth,
      width: pathWidth * 2,
      height: pathWidth * 2)
      ).CGPath
    layer.addSublayer(innerDotLayer)
  }*/
  
  func startAnimation(duration:NSTimeInterval = 1.0) {
    isAnimating = true
    
    let opacityAnim = CABasicAnimation(keyPath: "opacity")
    opacityAnim.fromValue = 0.2
    opacityAnim.toValue = 1.0
    
    let scaleAnim = CABasicAnimation(keyPath: "transform.scale")
    scaleAnim.fromValue = 1.0
    scaleAnim.toValue = 1.2

    /*let colorAnim = CABasicAnimation(keyPath: "strokeColor")
    colorAnim.fromValue = lineColor.CGColor
    colorAnim.toValue = UIColor.yellowColor().CGColor
    colorAnim.autoreverses = true
    colorAnim.duration = duration
    colorAnim.repeatCount = .infinity
    self.innerDotLayer.addAnimation(colorAnim, forKey: nil)*/
    
    let groupAnim = CAAnimationGroup()
    groupAnim.autoreverses = true
    groupAnim.duration = duration
    groupAnim.repeatCount = .infinity
    groupAnim.animations = [opacityAnim,scaleAnim]
    
    self.layer.addAnimation(groupAnim, forKey: "keyBreath")
  }
  
  func stopAnimation() {
    isAnimating = false
    self.layer.removeAnimationForKey("keyBreath")
  }
}
