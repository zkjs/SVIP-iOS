//
//  SkipCheckInSettingViewController.swift
//  SVIP
//
//  Created by dai.fengyi on 15/8/21.
//  Copyright (c) 2015年 zkjinshi. All rights reserved.
//

import UIKit

class SkipCheckInSettingViewController: UIViewController, UIWebViewDelegate {

  var webView: UIWebView!
  override func viewDidLoad() {
    super.viewDidLoad()
    initSubviews()
  }
  override func viewWillDisappear(animated: Bool) {
    super.viewWillDisappear(animated)
    hideHUD()
  }
  func initSubviews() {
    webView = UIWebView(frame: view.bounds)
    let url = NSURL(string: "http://iwxy.cc/mqt")
    webView.loadRequest(NSURLRequest(URL: url!))
    webView.scrollView.bounces = false
    webView.delegate = self
    view.addSubview(webView)
  }
  
  func webViewDidStartLoad(webView: UIWebView) {
    showHUDInView(view, withLoading: "")
  }
  func webViewDidFinishLoad(webView: UIWebView) {
    hideHUD()
  }
}
