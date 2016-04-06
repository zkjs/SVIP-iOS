//
//  ShrinkDismissAnimationController.swift
//  SVIP
//
//  Created by Qin Yejun on 4/6/16.
//  Copyright © 2016 zkjinshi. All rights reserved.
//

import UIKit

class ShrinkDismissAnimationController: NSObject,UIViewControllerAnimatedTransitioning {
  
  func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
    return 1.0
  }
  
  func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
    guard let toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey),
      let fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey),
      let containerView  = transitionContext.containerView()
    else {
        return
    }
    let finalFrame: CGRect = transitionContext.finalFrameForViewController(toViewController)
    
    toViewController.view.frame = finalFrame
    toViewController.view.alpha = 0.5
    
    containerView.addSubview(toViewController.view)
    containerView.sendSubviewToBack(toViewController.view)

    let screenBounds: CGRect = UIScreen.mainScreen().bounds
    let shrunkenFrame: CGRect = CGRectInset(fromViewController.view.frame, fromViewController.view.frame.size.width/4, fromViewController.view.frame.size.height/4)
    let fromFinalFrame: CGRect = CGRectOffset(shrunkenFrame, 0, screenBounds.size.height)
    let duration: NSTimeInterval = self.transitionDuration(transitionContext)
    // animate with keyframes
    UIView.animateKeyframesWithDuration(duration,
                                        delay: 0.0,
                                      options: [.CalculationModeCubic],
                                   animations: {
        UIView.addKeyframeWithRelativeStartTime(0.0, relativeDuration: 0.5, animations: {
          fromViewController.view.transform = CGAffineTransformMakeScale(0.5, 0.5)
          toViewController.view.alpha = 0.5
        })
                                    
        UIView.addKeyframeWithRelativeStartTime(0.5, relativeDuration: 0.5, animations: {
          fromViewController.view.frame = fromFinalFrame
          toViewController.view.alpha = 1.0
        })
      }, completion: { (finished) in
        // add line below to fix bug 
        // https://github.com/TeehanLax/UIViewController-Transitions-Example/issues/5
        UIApplication.sharedApplication().keyWindow!.addSubview(toViewController.view)
        transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
    })
    
  }
}
