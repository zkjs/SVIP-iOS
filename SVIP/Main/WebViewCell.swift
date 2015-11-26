//
//  WebViewCell.swift
//  SVIP
//
//  Created by AlexBang on 15/11/12.
//  Copyright © 2015年 zkjinshi. All rights reserved.
//

import UIKit

class WebViewCell: UITableViewCell {
  
  @IBOutlet weak var webView: UIWebView!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    
    webView.scrollView.bounces = false
    webView.scrollView.scrollEnabled = false
  }
  
  class func reuseIdentifier() -> String {
    return "WebViewCell"
  }
  
  class func nibName() -> String {
    return "WebViewCell"
  }
  
  override func setSelected(selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
  }
  
}
