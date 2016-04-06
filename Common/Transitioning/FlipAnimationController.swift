//
//  FlipAnimationController.swift
//  SVIP
//
//  Created by Qin Yejun on 4/6/16.
//  Copyright © 2016 zkjinshi. All rights reserved.
//

import UIKit

class FlipAnimationController:NSObject, UIViewControllerAnimatedTransitioning {
  var reverse:Bool = false
  
  func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
    return 1.0
  }
  
  func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
    guard let containerView = transitionContext.containerView(),
      let fromVC = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey),
      let toVC = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey) else {
        return
    }
    
    let toView = toVC.view
    let fromView = fromVC.view
    containerView.addSubview(toVC.view)
    
    var transform = CATransform3DIdentity
    transform.m34 = -0.002
    containerView.layer.sublayerTransform = transform
    
    let initialFrame = transitionContext.initialFrameForViewController(fromVC)
    fromView.frame = initialFrame
    toView.frame = initialFrame
    
    let factor = self.reverse ? 1.0 : -1.0
    toView.layer.transform = self.yRotation(CGFloat(factor * -M_PI_2))
    
    let duration = self.transitionDuration(transitionContext)
    
    UIView.animateKeyframesWithDuration(duration, delay: 0.0, options: [], animations: {
      UIView.addKeyframeWithRelativeStartTime(0.0, relativeDuration: 0.5, animations: {
        fromView.layer.transform = self.yRotation(CGFloat(factor * M_PI_2))
      })
      UIView.addKeyframeWithRelativeStartTime(0.5, relativeDuration: 0.5, animations: {
        toView.layer.transform = self.yRotation(0.0)
      })
      
      }, completion: { (finished: Bool) in
        transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
    })
    
  }
  
  func yRotation(angle:CGFloat) -> CATransform3D {
    return CATransform3DMakeRotation(angle, 0.0, 1.0, 0.0)
  }
}

