//
//  AboutUsViewController.swift
//  SVIP
//
//  Created by dai.fengyi on 15/9/8.
//  Copyright (c) 2015年 zkjinshi. All rights reserved.
//

import UIKit
import WebKit

class WebViewVC: UIViewController {
  
  var webView: WKWebView!
  var url = ""
  var webTitle = ""
  
  override func viewDidLoad() {
    super.viewDidLoad()
    navigationController?.navigationBar.translucent = false
    initSubviews()
    title = webTitle
    
    let image = UIImage(named: "ic_fanhui_orange")
    let item1 = UIBarButtonItem(image: image, style:.Done, target: self, action: "back")
    self.navigationItem.leftBarButtonItem = item1
  }
  
  override func viewWillAppear(animated: Bool) {
    navigationController?.navigationBarHidden = false
  }
  
  func initSubviews() {
    webView = WKWebView(frame: UIScreen.mainScreen().bounds)
    let url = NSURL(string: self.url)
    webView.loadRequest(NSURLRequest(URL: url!))
    webView.scrollView.bounces = true
    webView.scrollView.contentInset = UIEdgeInsetsMake(0, 0, 30, 0)
    webView.navigationDelegate = self
    view.addSubview(webView)
  }
  
  func back() {
    if webView.canGoBack {
      webView.goBack()
    } else {
      navigationController?.popViewControllerAnimated(true)
    }
  }
  
}

extension WebViewVC: WKNavigationDelegate {
  func webView(webView: WKWebView, didCommitNavigation navigation: WKNavigation!) {
    showHUDInView(view, withLoading: "")
  }
  
  func webView(webView: WKWebView, didFinishNavigation navigation: WKNavigation!) {
    hideHUD()
  }
}
