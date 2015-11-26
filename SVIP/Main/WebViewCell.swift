//
//  WebViewCell.swift
//  SVIP
//
//  Created by AlexBang on 15/11/12.
//  Copyright © 2015年 zkjinshi. All rights reserved.
//

import UIKit
var Height: CGFloat!
class WebViewCell: UITableViewCell,UIWebViewDelegate{

  @IBOutlet weak var webView: UIWebView! {
    didSet {
      webView.delegate = self
    }
  }
  override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
  class func reuseIdentifier() -> String {
    return "WebViewCell"
  }
  
  class func nibName() -> String {
    return "WebViewCell"
  }
  class func height() -> CGFloat {
    if Height == nil {
      return 0
    }else {
      return Height
    }
}
  
  func setwebView(request:NSURLRequest) {
    webView.loadRequest(request)
  }
  func webViewDidFinishLoad(webView: UIWebView) {
    Height = webView.scrollView.contentSize.height
   
  }
  
  override func setSelected(selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)

    }
    
}
