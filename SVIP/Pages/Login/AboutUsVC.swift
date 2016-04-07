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
    navigationController?.navigationBar.translucent = false
    initSubviews()
    
    let image = UIImage(named: "ic_fanhui_orange")
    let item1 = UIBarButtonItem(image: image, style:.Done, target: self, action: "back")
    self.navigationItem.leftBarButtonItem = item1
  }
  
  override func viewWillAppear(animated: Bool) {
    navigationController?.navigationBarHidden = false
  }
  
  func initSubviews() {
    webView = UIWebView(frame: UIScreen.mainScreen().bounds)
    webView.scalesPageToFit = true
    let url = NSURL(string: self.url)
    webView.loadRequest(NSURLRequest(URL: url!))
    webView.scrollView.bounces = true
    webView.scrollView.contentInset = UIEdgeInsetsMake(0, 0, 30, 0)
    webView.delegate = self
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

extension WebViewVC: UIWebViewDelegate {
  
  func webViewDidStartLoad(webView: UIWebView) {
    showHUDInView(view, withLoading: "")
  }
  
  func webViewDidFinishLoad(webView: UIWebView) {
    let result = webView.stringByEvaluatingJavaScriptFromString("document.body.offsetHeight;")
    let height = CGFloat((result! as NSString).doubleValue)
    webView.frame = CGRectMake(0, 0, self.view.bounds.size.width, height)
    hideHUD()
  }
  
}
