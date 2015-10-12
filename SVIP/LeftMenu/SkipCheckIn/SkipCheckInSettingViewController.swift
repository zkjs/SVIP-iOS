//
//  SkipCheckInSettingViewController.swift
//  SVIP
//
//  Created by dai.fengyi on 15/8/21.
//  Copyright (c) 2015年 zkjinshi. All rights reserved.
//

import UIKit

class SkipCheckInSettingViewController: UIViewController, UIWebViewDelegate {
  @IBOutlet weak var switchStatus: UILabel!
  @IBOutlet weak var switchButton: UISwitch!
  var webView: UIWebView!
  override func viewDidLoad() {
    super.viewDidLoad()
    initSubviews()
  }
  override func viewWillDisappear(animated: Bool) {
    super.viewWillDisappear(animated)
    ZKJSTool.hideHUD()
  }
  func initSubviews() {
    let switchView = NSBundle.mainBundle().loadNibNamed("SwitchView", owner: self, options: nil).last as! UIView
    let right = UIBarButtonItem(customView:switchView)
    self.navigationItem.rightBarButtonItem = right
    
    switchStatus.text = NSLocalizedString("OFF", comment: "")
    switchButton.addTarget(self, action:"switchValueChange:", forControlEvents: UIControlEvents.ValueChanged)
    
    webView = UIWebView(frame: view.bounds)
    let url = NSURL(string: "http://iwxy.cc/mqt")
    webView.loadRequest(NSURLRequest(URL: url!))
    webView.scrollView.bounces = false
    webView.delegate = self
    view.addSubview(webView)
  }
  
  func switchValueChange(sender: UISwitch) {
    if switchButton.on {
      switchStatus.text = NSLocalizedString("ON", comment: "")
    }else {
      switchStatus.text = NSLocalizedString("OFF", comment: "")
    }
  }
  
  func webViewDidStartLoad(webView: UIWebView) {
    ZKJSTool.showLoading()
  }
  func webViewDidFinishLoad(webView: UIWebView) {
    ZKJSTool.hideHUD()
  }
}
