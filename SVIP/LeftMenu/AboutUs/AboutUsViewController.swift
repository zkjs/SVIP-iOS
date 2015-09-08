//
//  AboutUsViewController.swift
//  SVIP
//
//  Created by dai.fengyi on 15/9/8.
//  Copyright (c) 2015年 zkjinshi. All rights reserved.
//

import UIKit

class AboutUsViewController: UIViewController {
  @IBOutlet weak var switchStatus: UILabel!
  @IBOutlet weak var switchButton: UISwitch!
  var webView: UIWebView!
  override func viewDidLoad() {
    super.viewDidLoad()
    initSubviews()
  }
  
  func initSubviews() {
    let v = NSBundle.mainBundle().loadNibNamed("SwitchView", owner: self, options: nil).last as! UIView
    let right = UIBarButtonItem(customView:v)
    self.navigationItem.rightBarButtonItem = right
    
    switchButton.addTarget(self, action:"switchValueChange:", forControlEvents: UIControlEvents.ValueChanged)
    
    webView = UIWebView(frame: view.bounds)
    let url = NSURL(string: "http://iwxy.cc/mqt")
    webView.loadRequest(NSURLRequest(URL: url!))
    webView.scrollView.bounces = false
    view.addSubview(webView)
  }
  
  func switchValueChange(sender: UISwitch) {
    if switchButton.on {
      switchStatus.text = "开启"
    }else {
      switchStatus.text = "关闭"
    }
  }
}
