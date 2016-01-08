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
  let bg2 = UIImageView(image: UIImage(named: "defoult_bg_2"))
  let bicycle = UIImageView(image: UIImage(named: "defoult_Bicycle"))
  let car = UIImageView(image: UIImage(named: "defoult_car"))

  let text3 = UIImageView(image: UIImage(named: "defoult_text_3"))
  let bg3 = UIImageView(image: UIImage(named: "defoult_bg_3"))
  let liwu = UIImageView(image: UIImage(named: "defoult_liwu"))
  let guangyun = UIImageView(image: UIImage(named: "defoult_guangyun"))
  let pass = UIImageView(image: UIImage(named: "defoult_pass"))
  let jiu = UIImageView(image: UIImage(named: "defoult_jiu"))
  let hua = UIImageView(image: UIImage(named: "defoult_hua"))

  let text4 = UIImageView(image: UIImage(named: "defoult_text_4"))
  let bg4 = UIImageView(image: UIImage(named: "defoult_bg_4"))
  
  let p_7 = UIImageView(image: UIImage(named: "defoult_p_7"))
  let p_11 = UIImageView(image: UIImage(named: "defoult_p_11"))
  let p_15 = UIImageView(image: UIImage(named: "defoult_p_15"))

  let p_8 = UIImageView(image: UIImage(named: "defoult_p_8"))
  let p_12 = UIImageView(image: UIImage(named: "defoult_p_12"))
  let p_16 = UIImageView(image: UIImage(named: "defoult_p_16"))

  let p_9 = UIImageView(image: UIImage(named: "defoult_p_9"))
  let p_13 = UIImageView(image: UIImage(named: "defoult_p_13"))
  let p_17 = UIImageView(image: UIImage(named: "defoult_p_17"))

  let p_19 = UIImageView(image: UIImage(named: "defoult_p_19"))
  let p_14 = UIImageView(image: UIImage(named: "defoult_p_14"))
  let p_18 = UIImageView(image: UIImage(named: "defoult_p_18"))
  
  let p_20 = UIImageView(image: UIImage(named: "defoult_p_20"))
  let p_10 = UIImageView(image: UIImage(named: "defoult_p_10"))
  let p_21 = UIImageView(image: UIImage(named: "defoult_p_21"))

  let text5 = UIImageView(image: UIImage(named: "defoult_text_5"))
  let bg5 = UIImageView(image: UIImage(named: "defoult_bg_5"))
  let startButton = UIButton()
  let p_5 = UIImageView(image: UIImage(named: "defoult_p_5"))
  let huangguan = UIImageView(image: UIImage(named: "defoult_huangguan"))
  let guanghuan = UIImageView(image: UIImage(named: "defoult_guanghuan"))

  
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
    let scrollViewWidth: CGFloat = scrollView.frame.width
    
    let middleX = CGRectGetMidX(UIScreen.mainScreen().bounds)
    let middleY = CGRectGetMidY(UIScreen.mainScreen().bounds)

    text2.sizeToFit()
    text2.hidden = true
    
    bg2.sizeToFit()
    bg2.center = CGPointMake(middleX+scrollViewWidth, middleY-100)
    
    bicycle.sizeToFit()
    bicycle.center = CGPointMake(middleX+scrollViewWidth, middleY-100)
    bicycle.transform = CGAffineTransformMakeScale(1.2, 1.2)
    
    car.sizeToFit()
    car.alpha = 0
    car.center = CGPointMake(middleX+scrollViewWidth, middleY-100)
    
    scrollView.addSubview(text2)
    scrollView.addSubview(bg2)
    scrollView.addSubview(bicycle)
    scrollView.addSubview(car)
  }
  
  private func setupPage3() {
    let scrollViewWidth: CGFloat = scrollView.frame.width
    
    let middleX = CGRectGetMidX(UIScreen.mainScreen().bounds)
    let middleY = CGRectGetMidY(UIScreen.mainScreen().bounds)
    
    text3.sizeToFit()
    text3.hidden = true
    
    bg3.sizeToFit()
    bg3.center = CGPointMake(middleX+scrollViewWidth*2, middleY-100)
    
    liwu.sizeToFit()
    liwu.alpha = 0
    
    guangyun.sizeToFit()
    guangyun.alpha = 0
    
    pass.sizeToFit()
    pass.alpha = 0
    
    jiu.sizeToFit()
    jiu.alpha = 0
    
    hua.sizeToFit()
    hua.alpha = 0
    
    scrollView.addSubview(text3)
    scrollView.addSubview(bg3)
    scrollView.addSubview(liwu)
    scrollView.addSubview(guangyun)
    scrollView.addSubview(pass)
    scrollView.addSubview(jiu)
    scrollView.addSubview(hua)
  }
  
  private func setupPage4() {
    let scrollViewWidth: CGFloat = scrollView.frame.width
    
    let middleX = CGRectGetMidX(UIScreen.mainScreen().bounds)
    let middleY = CGRectGetMidY(UIScreen.mainScreen().bounds)
    
    text4.sizeToFit()
    text4.hidden = true
    
    bg4.sizeToFit()
    bg4.center = CGPointMake(middleX+scrollViewWidth*3, middleY-100)
    
    p_20.sizeToFit()
    p_20.center = CGPointMake(middleX+scrollViewWidth*3-60, middleY-100-70)
    p_10.sizeToFit()
    p_10.center = CGPointMake(middleX+scrollViewWidth*3-60, middleY-100)
    p_21.sizeToFit()
    p_21.center = CGPointMake(middleX+scrollViewWidth*3-60, middleY-100+70)
    
    p_7.sizeToFit()
    p_7.center = CGPointMake(middleX+scrollViewWidth*3-30, middleY-100-70)
    p_11.sizeToFit()
    p_11.center = CGPointMake(middleX+scrollViewWidth*3-30, middleY-100)
    p_15.sizeToFit()
    p_15.center = CGPointMake(middleX+scrollViewWidth*3-30, middleY-100+70)
    
    p_8.sizeToFit()
    p_8.center = CGPointMake(middleX+scrollViewWidth*3, middleY-100-70)
    p_12.sizeToFit()
    p_12.center = CGPointMake(middleX+scrollViewWidth*3, middleY-100)
    p_16.sizeToFit()
    p_16.center = CGPointMake(middleX+scrollViewWidth*3, middleY-100+70)
    
    p_9.sizeToFit()
    p_9.center = CGPointMake(middleX+scrollViewWidth*3+30, middleY-100-70)
    p_13.sizeToFit()
    p_13.center = CGPointMake(middleX+scrollViewWidth*3+30, middleY-100)
    p_17.sizeToFit()
    p_17.center = CGPointMake(middleX+scrollViewWidth*3+30, middleY-100+70)
    
    p_19.sizeToFit()
    p_19.center = CGPointMake(middleX+scrollViewWidth*3+60, middleY-100-70)
    p_14.sizeToFit()
    p_14.center = CGPointMake(middleX+scrollViewWidth*3+60, middleY-100)
    p_18.sizeToFit()
    p_18.center = CGPointMake(middleX+scrollViewWidth*3+60, middleY-100+70)
    
    scrollView.addSubview(text4)
    scrollView.addSubview(bg4)
  }
  
  private func setupPage5() {
    let scrollViewWidth: CGFloat = scrollView.frame.width
    
    let middleX = CGRectGetMidX(UIScreen.mainScreen().bounds)
    let middleY = CGRectGetMidY(UIScreen.mainScreen().bounds)
    
    text5.sizeToFit()
    text5.hidden = true
    
    bg5.sizeToFit()
    bg5.center = CGPointMake(middleX+scrollViewWidth*4, middleY-100)
    
    startButton.setImage(UIImage(named: "defoult_start"), forState: .Normal)
    startButton.sizeToFit()
    startButton.hidden = true
    startButton.addTarget(self, action: "gotoMain", forControlEvents: .TouchUpInside)
    
    p_5.sizeToFit()
    p_5.center = CGPointMake(middleX+scrollViewWidth*4, middleY-50)
    
    huangguan.sizeToFit()
    
    guangyun.sizeToFit()
    guangyun.center = CGPointMake(middleX+scrollViewWidth*4, middleY-100)
    
    scrollView.addSubview(text5)
    scrollView.addSubview(startButton)
    scrollView.addSubview(bg5)
    scrollView.addSubview(p_5)
    scrollView.addSubview(huangguan)
    scrollView.addSubview(guangyun)
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
      
      bicycle.transform = CGAffineTransformMakeScale(1.2, 1.2)
      bicycle.alpha = 1
      UIView.animateWithDuration(0.6, delay: 0.3, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: .CurveEaseInOut, animations: { () -> Void in
        self.bicycle.transform = CGAffineTransformMakeScale(0.1, 0.1)
        self.bicycle.alpha = 0
        }, completion: nil)
      
      car.transform = CGAffineTransformMakeScale(0.1, 0.1)
      car.alpha = 0
      UIView.animateWithDuration(0.6, delay: 0.3, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: .CurveEaseInOut, animations: { () -> Void in
        self.car.transform = CGAffineTransformIdentity
        self.car.alpha = 1
        }, completion: nil)
    } else if Int(currentPage) == 2 {
      text3.hidden = false
      text3.center = CGPointMake(middleX+scrollViewWidth*2+300, textY)
      UIView.animateWithDuration(0.6, delay: 0.3, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: .CurveEaseInOut, animations: { () -> Void in
        self.text3.center = CGPointMake(middleX+scrollViewWidth*2, textY)
        }, completion: nil)
      
      liwu.center = CGPointMake(middleX+scrollViewWidth*2, middleY-100)
      UIView.animateWithDuration(0.6, delay: 0.3, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: .CurveEaseInOut, animations: { () -> Void in
        self.liwu.center = CGPointMake(middleX+scrollViewWidth*2, middleY-50)
        }, completion: nil)
      
      guangyun.center = CGPointMake(middleX+scrollViewWidth*2, middleY-70)
      guangyun.alpha = 0
      guangyun.transform = CGAffineTransformMakeScale(0.1, 0.1)
      UIView.animateWithDuration(0.6, delay: 0.3+0.2, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: .CurveEaseInOut, animations: { () -> Void in
        self.guangyun.transform = CGAffineTransformIdentity
        }, completion: nil)
      
      pass.center = CGPointMake(middleX+scrollViewWidth*2-50, middleY-80)
      pass.alpha = 0
      pass.transform = CGAffineTransformMakeScale(0.1, 0.1)
      UIView.animateWithDuration(0.6, delay: 0.3+0.3, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: .CurveEaseInOut, animations: { () -> Void in
        self.pass.transform = CGAffineTransformIdentity
        }, completion: nil)
      
      jiu.center = CGPointMake(middleX+scrollViewWidth*2, middleY-90)
      jiu.alpha = 0
      jiu.transform = CGAffineTransformMakeScale(0.1, 0.1)
      UIView.animateWithDuration(0.6, delay: 0.3+0.3, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: .CurveEaseInOut, animations: { () -> Void in
        self.jiu.transform = CGAffineTransformIdentity
        }, completion: nil)
      
      hua.center = CGPointMake(middleX+scrollViewWidth*2+50, middleY-80)
      hua.alpha = 0
      hua.transform = CGAffineTransformMakeScale(0.1, 0.1)
      UIView.animateWithDuration(0.6, delay: 0.3+0.3, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: .CurveEaseInOut, animations: { () -> Void in
        self.hua.transform = CGAffineTransformIdentity
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
      
      huangguan.center = CGPointMake(middleX+scrollViewWidth*4, middleY-150)
      huangguan.alpha = 0
      UIView.animateWithDuration(0.6, delay: 0.3, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: .CurveEaseInOut, animations: { () -> Void in
        self.huangguan.center = CGPointMake(middleX+scrollViewWidth*4, middleY-120)
        self.huangguan.alpha = 1
        }, completion: nil)
      
      guangyun.transform = CGAffineTransformMakeScale(0.1, 0.1)
      guangyun.alpha = 0
      UIView.animateWithDuration(0.6, delay: 0.3, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: .CurveEaseInOut, animations: { () -> Void in
        self.guangyun.transform = CGAffineTransformIdentity
        self.guangyun.alpha = 1
        }, completion: nil)
    }
  }
  
}
