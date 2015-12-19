//
//  AboutUsViewController.swift
//  SVIP
//
//  Created by dai.fengyi on 15/9/8.
//  Copyright (c) 2015年 zkjinshi. All rights reserved.
//

import UIKit

class WebViewVC: UIViewController {
  
  var webView: UIWebView!
  var url = ""
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    initSubviews()
  }
  
  func initSubviews() {
    webView = UIWebView(frame: view.bounds)
    let url = NSURL(string: self.url)  
    webView.loadRequest(NSURLRequest(URL: url!))
    webView.scrollView.bounces = false
    webView.delegate = self
    view.addSubview(webView)
  }
  
}

extension WebViewVC: UIWebViewDelegate {
  
  func webViewDidStartLoad(webView: UIWebView) {
    showHUDInView(view, withLoading: "")
  }
  
  func webViewDidFinishLoad(webView: UIWebView) {
    hideHUD()
  }
  
}
