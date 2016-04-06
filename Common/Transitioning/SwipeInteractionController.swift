//
//  SwipeInteractionController.swift
//  SVIP
//
//  Created by Qin Yejun on 4/6/16.
//  Copyright © 2016 zkjinshi. All rights reserved.
//

import UIKit

class SwipeInteractionController: UIPercentDrivenInteractiveTransition {
  var interactionInProgress = false
  
  private var shouldCompleteTransition = false
  private var navigationController:UINavigationController?
  
  override var completionSpeed:CGFloat {
    get {
      return 1 - self.percentComplete
    }
    set(newVal) {
      self.completionSpeed = newVal
    }
  }
  
  func wireToViewController(viewController: UIViewController) {
    navigationController = viewController.navigationController
    prepareGestureRecognizerInView(viewController.view)
  }
  
  private func prepareGestureRecognizerInView(view: UIView) {
    let gesture = UIPanGestureRecognizer(target: self, action: "handleGesture:")
    view.addGestureRecognizer(gesture)
  }
 
  func handleGesture(gestureRecognizer:UIPanGestureRecognizer) {
    let translation:CGPoint = gestureRecognizer.translationInView(gestureRecognizer.view?.superview)
    switch gestureRecognizer.state {
    case .Began:
      interactionInProgress = true
      navigationController?.popViewControllerAnimated(true)
      break
    case .Changed:
      var fraction = translation.x / 200.0
      fraction = CGFloat(fminf(fmaxf(Float(fraction), 0.0), 1.0))
      shouldCompleteTransition = (fraction > 0.5)
      updateInteractiveTransition(fraction)
      break
    case .Ended, .Cancelled:
      interactionInProgress = false
      if !shouldCompleteTransition || gestureRecognizer.state == .Cancelled {
        cancelInteractiveTransition()
      } else {
        finishInteractiveTransition()
      }
      break
    default:
      break
    }
  }
}