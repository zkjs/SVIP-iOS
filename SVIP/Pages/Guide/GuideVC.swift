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
  
  let text1 = UILabel()
  let text = UILabel()
  let earth = UIImageView(image: UIImage(named: "default_shenfen"))

  
  let text2 = UIImageView(image: UIImage(named: "defoult_text_2"))
  let text3 = UILabel()
  let text4 = UILabel()
  let bg2 = UIImageView(image: UIImage(named: "default_zhifu"))

  let startButton = UIButton()
  
  
  override func loadView() {
    NSBundle.mainBundle().loadNibNamed("GuideVC", owner:self, options:nil)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupView()
    
    /* clear alias
     * 解决app被删除后再次安装还能收到云巴推送的问题
     */
    YunBaService.setAlias("") { (succ, err) in  }
  }
  
  private func setupView() {
    scrollView.frame = CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, UIScreen.mainScreen().bounds.height)
    scrollView.contentSize = CGSizeMake(scrollView.frame.width * 2, scrollView.frame.height)
    pageControl.currentPage = 0
    scrollView.delegate = self
    setupPage1()
    setupPage2()

  }
  
  private func setupPage1() {
    let middleX = CGRectGetMidX(UIScreen.mainScreen().bounds)
    let middleY = CGRectGetMidY(UIScreen.mainScreen().bounds)
    let textY = middleY + 80
    

    text1.text = "身份象征"
    text1.textColor = UIColor(hex: "#000000")
    text1.font = UIFont.systemFontOfSize(28)
    text1.sizeToFit()
    text1.center = CGPointMake(middleX, textY)

    text.text = "最有面子的认证方式,尊享差异化服务,彰显身份。自由出入重要区域,杜绝尴尬发生。"
    text.textColor = UIColor(hex: "#666666")
    text.lineBreakMode = NSLineBreakMode.ByWordWrapping
    text.numberOfLines = 0
    text.font = UIFont.systemFontOfSize(15)
    text.center = CGPointMake(middleX-200/2, textY+40)
    text.frame.size = CGSize(width: 200, height: 0)
    text.sizeToFit()

    
    earth.sizeToFit()
    earth.center = CGPointMake(middleX, middleY-100)
    
    scrollView.addSubview(text1)
    scrollView.addSubview(earth)
    scrollView.addSubview(text)
    
   
  }
  
  private func setupPage2() {
    let scrollViewWidth: CGFloat = scrollView.frame.width
    
    let middleX = CGRectGetMidX(UIScreen.mainScreen().bounds)
    let middleY = CGRectGetMidY(UIScreen.mainScreen().bounds)
    let textY = middleY + 80
    text3.text = "免操作支付"
    text3.textColor = UIColor(hex: "#000000")
    text3.font = UIFont.systemFontOfSize(28)
    text3.sizeToFit()
    text3.center = CGPointMake(middleX+scrollViewWidth, textY)
    
    text4.text = "最快捷的移动支付,无需操作进行安全支付,节省您的支付时间。"
    text4.textColor = UIColor(hex: "#666666")
    text4.lineBreakMode = NSLineBreakMode.ByWordWrapping
    text4.numberOfLines = 0
    text4.font = UIFont.systemFontOfSize(15)
    text4.center = CGPointMake(middleX-200/2 + scrollViewWidth, textY+40)
    text4.frame.size = CGSize(width: 200, height: 0)
    text4.sizeToFit()


    
    bg2.sizeToFit()
    bg2.center = CGPointMake(middleX+scrollViewWidth, middleY-100)
    
    startButton.setBackgroundImage(UIImage(named: "btn_kaiqishenfen"), forState: .Normal)
    
    startButton.sizeToFit()
    startButton.addTarget(self, action: "gotoMain", forControlEvents: .TouchUpInside)

    startButton.center = CGPointMake(middleX+scrollViewWidth, middleY+220)

    scrollView.addSubview(startButton)
    scrollView.addSubview(bg2)
    scrollView.addSubview(text3)
    scrollView.addSubview(text4)
  
  }
  
  
  
  
  // MARK: - Button Action
  
  func gotoMain() {
    UIApplication.sharedApplication().keyWindow?.backgroundColor = UIColor(hex:"#F5F5F5")
    
    UIView.animateWithDuration(0.4, animations: { () -> Void in
      self.view.transform = CGAffineTransformMakeScale(1.5, 1.5)
      self.view.alpha = 0.0
      }) { (finished: Bool) -> Void in
        if finished {
          var nc: BaseNC
          if TokenPayload.sharedInstance.isLogin {
            nc = BaseNC(rootViewController: HomeVC())
          } else {
            nc = BaseNC(rootViewController: LoginFirstVC())
          }
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
    
    pageControl.currentPage = Int(currentPage)
    
    if Int(currentPage) == 1 {
      self.text2.center = CGPointMake(middleX+scrollViewWidth, textY)
      } else if Int(currentPage) == 2 {
       
    }
  }
}
