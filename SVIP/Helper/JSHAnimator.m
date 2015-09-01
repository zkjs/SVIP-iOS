//
//  JSHAnimator.m
//  HotelVIP
//
//  Created by Hanton on 6/6/15.
//  Copyright (c) 2015 ZKJS. All rights reserved.
//

#import "JSHAnimator.h"
#import "SVIP-Swift.h"

@interface JSHAnimator ()
@property (nonatomic, weak) id<UIViewControllerContextTransitioning> transitionContext;
@end

@implementation JSHAnimator

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext {
  return 0.6;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
//  self.transitionContext = transitionContext;
//  
//  UIView *containerView = [transitionContext containerView];
//  MainVC *fromVC = (MainVC *)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
//  JSHInfoEditVC *toVC = (JSHInfoEditVC *)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
//  UIButton *button = fromVC.settingsButton;
//  
//  [containerView addSubview:toVC.view];
//  
//  UIBezierPath *circleMaskPathInitial = [UIBezierPath bezierPathWithOvalInRect:button.frame];
//  CGPoint extremePoint = CGPointMake(button.center.x - 0, button.center.y - CGRectGetHeight(toVC.view.bounds));
//  CGFloat radius = sqrt((extremePoint.x*extremePoint.x) + (extremePoint.y*extremePoint.y));
//  UIBezierPath *circleMaskPathFinal = [UIBezierPath bezierPathWithOvalInRect:CGRectInset(button.frame, -radius, -radius)];
//  
//  CAShapeLayer *maskLayer = [CAShapeLayer new];
//  maskLayer.path = circleMaskPathFinal.CGPath;
//  toVC.view.layer.mask = maskLayer;
//  
//  CABasicAnimation *maskLayerAnimation = [CABasicAnimation animationWithKeyPath:@"path"];
//  maskLayerAnimation.fromValue = (__bridge id)circleMaskPathInitial.CGPath;
//  maskLayerAnimation.toValue = (__bridge id)circleMaskPathFinal.CGPath;
//  maskLayerAnimation.duration = [self transitionDuration:transitionContext];
//  maskLayerAnimation.delegate = self;
//  [maskLayer addAnimation:maskLayerAnimation forKey:@"path"];
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
  [self.transitionContext completeTransition:![self.transitionContext transitionWasCancelled]];
  UIViewController *fromVC = [self.transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
  fromVC.view.layer.mask = nil;
}

@end
