//
//  AboutUsViewController.swift
//  SVIP
//
//  Created by dai.fengyi on 15/9/8.
//  Copyright (c) 2015年 zkjinshi. All rights reserved.
//

import UIKit

class AboutUsVC: UIViewController {
  
  var webView: UIWebView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    initSubviews()
  }
  
  func initSubviews() {
    webView = UIWebView(frame: view.bounds)
    let url = NSURL(string: "http://www.zkjinshi.com/about_us/")
    webView.loadRequest(NSURLRequest(URL: url!))
    webView.scrollView.bounces = false
    webView.delegate = self
    view.addSubview(webView)
  }
  
}

extension AboutUsVC: UIWebViewDelegate {
  
  func webViewDidStartLoad(webView: UIWebView) {
    showHUDInView(view, withLoading: "")
  }
  
  func webViewDidFinishLoad(webView: UIWebView) {
    hideHUD()
  }
  
}
