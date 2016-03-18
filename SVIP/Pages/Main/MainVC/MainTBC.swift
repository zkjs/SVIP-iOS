//
//  MainTBC.swift
//  SVIP
//
//  Created by AlexBang on 15/12/4.
//  Copyright © 2015年 zkjinshi. All rights reserved.
//

import UIKit


let kGotoContactList = "kGotoContactList"

class MainTBC: UITabBarController {
  
  var heightDifference:CGFloat!
  var  isUnSelected = false
  let tipView = UIView()
  let maskLayer1 = CAShapeLayer()
  let guideButton1 = UIButton()
  let guideText1 = UIImageView()
  let maskLayer2 = CAShapeLayer()
  let guideButton2 = UIButton()
  let guideText2 = UIImageView()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    view.backgroundColor = UIColor.whiteColor()
    
    //首页
    let vc1 = HomeVC()
    let nc1 = BaseNC(rootViewController: vc1)
    let image1 = UIImage(named: "ic_shouye_nor")
    vc1.tabBarItem.image = image1
    vc1.tabBarItem.imageInsets = UIEdgeInsetsMake(6, 0, -6, 0)
    
    
    viewControllers = [nc1]
    tabBar.tintColor = UIColor.ZKJS_mainColor()
    
    // 检查版本更新
    checkVersion()
    
    // 新手用户使用指南
    if (!(NSUserDefaults.standardUserDefaults().boolForKey("everLaunched"))) {
      NSUserDefaults.standardUserDefaults().setBool(true, forKey:"everLaunched")
      showTipView()
    }
  }
  
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    
  }
  
  func showTipView() {
    tipView.frame = view.bounds
    let radius: CGFloat = 60.0
    let path = UIBezierPath(roundedRect: CGRectMake(0, 0, view.frame.size.width, view.frame.size.height), cornerRadius: 0.0)
    let circlePath = UIBezierPath(roundedRect: CGRectMake(view.frame.size.width-radius-30, 309, radius, radius), cornerRadius: radius)
    path.appendPath(circlePath)
    path.usesEvenOddFillRule = true
    maskLayer1.path = path.CGPath
    maskLayer1.fillRule = kCAFillRuleEvenOdd
    maskLayer1.fillColor = UIColor.blackColor().CGColor
    maskLayer1.opacity = 0.8
    tipView.layer.addSublayer(maskLayer1)
    view.addSubview(tipView)
    
    guideButton1.setImage(UIImage(named: "default_btn_wozhidaola"), forState: .Normal)
    guideButton1.sizeToFit()
    guideButton1.center = CGPointMake(CGRectGetMidX(view.frame), 309+100)
    guideButton1.addTarget(self, action: "nextTipView", forControlEvents: .TouchUpInside)
    view.addSubview(guideButton1)
 
    guideText1.image = UIImage(named: "default_zhijian")
    guideText1.sizeToFit()
    guideText1.center = CGPointMake(CGRectGetMidX(view.frame)-30, 309+10)
    view.addSubview(guideText1)
  }
  
  func nextTipView() {
    maskLayer1.hidden = true
    guideButton1.hidden = true
    guideText1.hidden = true
    
    let radius: CGFloat = 40.0
    let circleX = CGRectGetMidX(view.frame)+CGRectGetWidth(view.frame)/8.0-radius/2.0
    let circleY = CGRectGetHeight(view.frame)-radius-5
    let path = UIBezierPath(roundedRect: CGRectMake(0, 0, view.frame.size.width, view.frame.size.height), cornerRadius: 0.0)
    let circlePath = UIBezierPath(roundedRect: CGRectMake(circleX, circleY, radius, radius), cornerRadius: radius)
    path.appendPath(circlePath)
    path.usesEvenOddFillRule = true
    maskLayer2.path = path.CGPath
    maskLayer2.fillRule = kCAFillRuleEvenOdd
    maskLayer2.fillColor = UIColor.blackColor().CGColor
    maskLayer2.opacity = 0.8
    tipView.layer.addSublayer(maskLayer2)
    view.addSubview(tipView)
    
    guideButton2.setImage(UIImage(named: "default_btn_zhaokefu"), forState: .Normal)
    guideButton2.sizeToFit()
    guideButton2.center = CGPointMake(CGRectGetMidX(view.frame), circleY-190)
    guideButton2.addTarget(self, action: "finishTipView", forControlEvents: .TouchUpInside)
    view.addSubview(guideButton2)
    
    guideText2.image = UIImage(named: "default_xiaoxi")
    guideText2.sizeToFit()
    guideText2.center = CGPointMake(circleX-radius/2.0, circleY-80)
    view.addSubview(guideText2)
  }
  
  func finishTipView() {
    tipView.hidden = true
    guideButton2.hidden = true
    guideText2.hidden = true
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    navigationController?.navigationBarHidden = true
  }
  
  override func viewWillDisappear(animated: Bool) {
    super.viewWillDisappear(animated)
    navigationController?.navigationBarHidden = false
  }
  
  func checkVersion() {
    HttpService.sharedInstance.checkNewVersion { (isForceUpgrade, hasNewVersion) -> Void in
      if isForceUpgrade {
        // 强制更新
        let alertController = UIAlertController(title: "升级提示", message: "请您升级到最新版本，以保证软件的正常使用", preferredStyle: .Alert)
        let upgradeAction = UIAlertAction(title: "升级", style: .Default, handler: { (action: UIAlertAction) -> Void in
          let url  = NSURL(string: "itms-apps://itunes.apple.com/us/app/chao-ji-shen-fen/id1018581123?ls=1&mt=8")
          if UIApplication.sharedApplication().canOpenURL(url!) {
            UIApplication.sharedApplication().openURL(url!)
          }
        })
        alertController.addAction(upgradeAction)
        self.presentViewController(alertController, animated: true, completion: nil)
      } else if hasNewVersion {
        // 提示更新
        let alertController = UIAlertController(title: "升级提示", message: "已有新版本可供升级", preferredStyle: .Alert)
        let upgradeAction = UIAlertAction(title: "升级", style: .Default, handler: { (action: UIAlertAction) -> Void in
          let url  = NSURL(string: "itms-apps://itunes.apple.com/us/app/chao-ji-shen-fen/id1018581123?ls=1&mt=8")
          if UIApplication.sharedApplication().canOpenURL(url!) {
            UIApplication.sharedApplication().openURL(url!)
          }
        })
        alertController.addAction(upgradeAction)
        let cancelAction = UIAlertAction(title: "取消", style: .Cancel, handler: nil)
        alertController.addAction(cancelAction)
        self.presentViewController(alertController, animated: true, completion: nil)
      }
        
    }
  }
  
  deinit {
    //unregisterNotification()
  }

}
