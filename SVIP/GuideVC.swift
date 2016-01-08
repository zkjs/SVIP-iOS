//
//  GuideVC.swift
//  SVIP
//
//  Created by Hanton on 1/8/16.
//  Copyright © 2016 zkjinshi. All rights reserved.
//

import UIKit

class GuideVC: UIViewController {
  
  @IBOutlet weak var scrollView: UIScrollView!
  @IBOutlet weak var pageControl: UIPageControl!
  
  let text1 = UIImageView(image: UIImage(named: "defoult_text_1"))
  let earth = UIImageView(image: UIImage(named: "defoult_earth"))
  let ufo = UIImageView(image: UIImage(named: "defoult_ufo"))
  let cloud1 = UIImageView(image: UIImage(named: "defoult_cloud_2"))
  let cloud2 = UIImageView(image: UIImage(named: "defoult_cloud_1"))
  
  let text2 = UIImageView(image: UIImage(named: "defoult_text_2"))

  let text3 = UIImageView(image: UIImage(named: "defoult_text_3"))

  let text4 = UIImageView(image: UIImage(named: "defoult_text_4"))

  let text5 = UIImageView(image: UIImage(named: "defoult_text_5"))
  let startButton = UIButton()

  
  override func loadView() {
    NSBundle.mainBundle().loadNibNamed("GuideVC", owner:self, options:nil)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupView()
  }
  
  private func setupView() {
    scrollView.frame = CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, UIScreen.mainScreen().bounds.height)
    scrollView.contentSize = CGSizeMake(scrollView.frame.width * 5, scrollView.frame.height)
    scrollView.delegate = self
    pageControl.currentPage = 0
    
    setupPage1()
    setupPage2()
    setupPage3()
    setupPage4()
    setupPage5()
  }
  
  private func setupPage1() {
    let middleX = CGRectGetMidX(UIScreen.mainScreen().bounds)
    let middleY = CGRectGetMidY(UIScreen.mainScreen().bounds)
    let textY = middleY + 120
    
    text1.sizeToFit()
    text1.center = CGPointMake(middleX+300, textY)
    UIView.animateWithDuration(0.6, delay: 0.3, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: .CurveEaseInOut, animations: { () -> Void in
      self.text1.center = CGPointMake(middleX, textY)
      }, completion: nil)
    
    earth.sizeToFit()
    earth.center = CGPointMake(middleX, middleY-100)
    
    cloud1.sizeToFit()
    cloud1.center = CGPointMake(earth.center.x+50, earth.center.y-80)
    cloud1.alpha = 0.0
    UIView.animateWithDuration(0.6, delay: 0.3, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: .CurveEaseInOut, animations: { () -> Void in
      self.cloud1.center = CGPointMake(self.earth.center.x+20, self.earth.center.y-80)
      self.cloud1.alpha = 1.0
      }, completion: nil)
    
    cloud2.sizeToFit()
    cloud2.center = CGPointMake(earth.center.x+130, earth.center.y-30)
    cloud2.alpha = 0.0
    UIView.animateWithDuration(0.6, delay: 0.3, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: .CurveEaseInOut, animations: { () -> Void in
      self.cloud2.center = CGPointMake(self.earth.center.x+80, self.earth.center.y-30)
      self.cloud2.alpha = 1.0
      }, completion: nil)
    
    ufo.sizeToFit()
    ufo.center = CGPointMake(earth.center.x+50, earth.center.y)
    ufo.alpha = 0.0
    UIView.animateWithDuration(0.6, delay: 0.3, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: .CurveEaseInOut, animations: { () -> Void in
      self.ufo.center = CGPointMake(self.earth.center.x-30, self.earth.center.y)
      self.ufo.alpha = 1.0
      }, completion: nil)
    
    scrollView.addSubview(text1)
    scrollView.addSubview(earth)
    scrollView.addSubview(cloud1)
    scrollView.addSubview(cloud2)
    scrollView.addSubview(ufo)
  }
  
  private func setupPage2() {
    text2.sizeToFit()
    text2.hidden = true
    
    scrollView.addSubview(text2)
  }
  
  private func setupPage3() {
    let scrollViewWidth: CGFloat = scrollView.frame.width
    
    let middleX = CGRectGetMidX(UIScreen.mainScreen().bounds)
    let middleY = CGRectGetMidY(UIScreen.mainScreen().bounds)
    let textY = middleY + 120
    
    text3.sizeToFit()
    text3.hidden = true
    
    scrollView.addSubview(text3)
  }
  
  private func setupPage4() {
    let scrollViewWidth: CGFloat = scrollView.frame.width
    
    let middleX = CGRectGetMidX(UIScreen.mainScreen().bounds)
    let middleY = CGRectGetMidY(UIScreen.mainScreen().bounds)
    let textY = middleY + 120
    
    text4.sizeToFit()
    text4.hidden = true
    
    scrollView.addSubview(text4)
  }
  
  private func setupPage5() {
    let scrollViewWidth: CGFloat = scrollView.frame.width
    
    let middleX = CGRectGetMidX(UIScreen.mainScreen().bounds)
    let middleY = CGRectGetMidY(UIScreen.mainScreen().bounds)
    let textY = middleY + 120
    
    text5.sizeToFit()
    text5.hidden = true
    
    startButton.setImage(UIImage(named: "defoult_start"), forState: .Normal)
    startButton.sizeToFit()
    startButton.hidden = true
    startButton.addTarget(self, action: "gotoMain", forControlEvents: .TouchUpInside)
    
    scrollView.addSubview(text5)
    scrollView.addSubview(startButton)
  }
  
  // MARK: - Button Action
  
  func gotoMain() {
    UIApplication.sharedApplication().keyWindow?.backgroundColor = UIColor.hx_colorWithHexString("F5F5F5")
    
    UIView.animateWithDuration(0.4, animations: { () -> Void in
      self.view.transform = CGAffineTransformMakeScale(1.5, 1.5)
      self.view.alpha = 0.0
      }) { (finished: Bool) -> Void in
        if finished {
          let nc = BaseNC(rootViewController: MainTBC())
          UIApplication.sharedApplication().keyWindow?.rootViewController = nc
        }
    }
  }
  
}

extension GuideVC: UIScrollViewDelegate {
  
  func scrollViewDidEndDecelerating(scrollView: UIScrollView){
    
    let pageWidth:CGFloat = CGRectGetWidth(scrollView.frame)
    let currentPage:CGFloat = floor((scrollView.contentOffset.x-pageWidth/2)/pageWidth)+1
    
    let scrollViewWidth: CGFloat = scrollView.frame.width
    let middleX = CGRectGetMidX(UIScreen.mainScreen().bounds)
    let middleY = CGRectGetMidY(UIScreen.mainScreen().bounds)
    let textY = middleY + 120
    
    pageControl.currentPage = Int(currentPage);
    
    if Int(currentPage) == 1 {
      text2.hidden = false
      text2.center = CGPointMake(middleX+scrollViewWidth+300, textY)
      UIView.animateWithDuration(0.6, delay: 0.3, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: .CurveEaseInOut, animations: { () -> Void in
        self.text2.center = CGPointMake(middleX+scrollViewWidth, textY)
        }, completion: nil)
    } else if Int(currentPage) == 2 {
      text3.hidden = false
      text3.center = CGPointMake(middleX+scrollViewWidth*2+300, textY)
      UIView.animateWithDuration(0.6, delay: 0.3, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: .CurveEaseInOut, animations: { () -> Void in
        self.text3.center = CGPointMake(middleX+scrollViewWidth*2, textY)
        }, completion: nil)
    } else if Int(currentPage) == 3 {
      text4.hidden = false
      text4.center = CGPointMake(middleX+scrollViewWidth*3+300, textY)
      UIView.animateWithDuration(0.6, delay: 0.3, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: .CurveEaseInOut, animations: { () -> Void in
        self.text4.center = CGPointMake(middleX+scrollViewWidth*3, textY)
        }, completion: nil)
    } else if Int(currentPage) == 4 {
      text5.hidden = false
      text5.center = CGPointMake(middleX+scrollViewWidth*4+300, textY)
      UIView.animateWithDuration(0.6, delay: 0.3, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: .CurveEaseInOut, animations: { () -> Void in
        self.text5.center = CGPointMake(middleX+scrollViewWidth*4, textY)
        }, completion: nil)
      
      startButton.hidden = false
      startButton.center = CGPointMake(middleX+scrollViewWidth*4+300, textY+90)
      UIView.animateWithDuration(0.6, delay: 0.3, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: .CurveEaseInOut, animations: { () -> Void in
        self.startButton.center = CGPointMake(middleX+scrollViewWidth*4, textY+90)
        }, completion: nil)
    }
  }
  
}
