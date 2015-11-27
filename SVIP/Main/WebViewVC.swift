//
//  WebViewVC.swift
//  SVIP
//
//  Created by AlexBang on 15/11/27.
//  Copyright © 2015年 zkjinshi. All rights reserved.
//

import UIKit

class WebViewVC: UIViewController {
  var url : NSURLRequest!
  @IBOutlet weak var webView: UIWebView!
    override func viewDidLoad() {
        super.viewDidLoad()
      webView.loadRequest(url)

        // Do any additional setup after loading the view.
    }
  override func loadView() {
    NSBundle.mainBundle().loadNibNamed("WebViewVC", owner:self, options:nil)
  }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
