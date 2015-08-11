//
//  InfoEditVC.swift
//  SVIP
//
//  Created by dai.fengyi on 15/8/11.
//  Copyright (c) 2015年 zkjinshi. All rights reserved.
//

import UIKit

class InfoEditVC: UIViewController {
  var scrollView: UIScrollView
  //    override func loadView() {
  //        NSBundle.mainBundle() .loadNibNamed("InfoEditVC", owner: self, options: nil)
  //    }
  required override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
    scrollView = UIScrollView(frame: CGRectZero)
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
  }

  required init(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    initSubviews()
    // Do any additional setup after loading the view.
  }
  func initSubviews() {
    let frame = self.view.bounds
    scrollView.frame = frame
    scrollView.contentSize = CGSizeMake(frame.width, frame.height * 3)
    self.view.addSubview(scrollView)
    
    let firstPage: UIView = NSBundle.mainBundle().loadNibNamed("InfoEditFirstPage", owner: self, options: nil).last as! UIView
    let secondPage: UIView = NSBundle.mainBundle().loadNibNamed("InfoEditSecondPage", owner: self, options: nil).last as! UIView
    let thirdPage: UIView = NSBundle.mainBundle().loadNibNamed("InfoEditThirdPage", owner: self, options: nil).last as! UIView
    firstPage.frame = frame
    secondPage.frame = CGRectMake(0, CGRectGetMaxY(firstPage.frame), frame.width, frame.height)
    thirdPage.frame = CGRectMake(0, CGRectGetMaxY(secondPage.frame), frame.width, frame.height)
    scrollView .addSubview(firstPage)
    scrollView .addSubview(secondPage)
    scrollView .addSubview(thirdPage)
  }
  
  
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)

  }
}
