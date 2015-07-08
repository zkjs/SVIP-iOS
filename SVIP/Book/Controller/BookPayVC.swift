//
//  BookPayVC.swift
//  SVIP
//
//  Created by dai.fengyi on 15/7/2.
//  Copyright (c) 2015年 zkjinshi. All rights reserved.
//

import UIKit
let partner = PartnerID
let seller = SellerID
let privateKey = PartnerPrivKey
class BookPayVC: UIViewController {
  
  var bkOrder: BookOrder!
  
  override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
    super.init(nibName: "BookPayVC", bundle: nil)
  }

  required init(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
    self.navigationItem.hidesBackButton = true
    let buttonItem = UIBarButtonItem(title: "取消订单", style: UIBarButtonItemStyle.Plain, target: self, action: NSSelectorFromString("cancelOrder"))
    self.navigationItem.rightBarButtonItem = buttonItem
  }
  

  func cancelOrder() {
    ZKJSTool .showLoading("正在取消订单")
    let account = JSHAccountManager .sharedJSHAccountManager()
    ZKJSHTTPSessionManager .sharedInstance() .cancelOrderWithUserID(account.userid, token: account.token, orderID: bkOrder.orderno, success: { (task: NSURLSessionDataTask!, responseObject: AnyObject!) -> Void in
          ZKJSTool .showMsg("订单已取消")
          self .dismissViewControllerAnimated(true, completion: nil)
      }) { (task: NSURLSessionDataTask!, error: NSError!) -> Void in
        ZKJSTool .showMsg("订单取消失败，请进入订单列表取消订单")
        self .dismissViewControllerAnimated(true, completion: nil)
    }

  }
  @IBAction func zhifubao(sender: UIButton) {
    payAliOrder(bkOrder)
  }
  @IBAction func weixinzhifu(sender: UIButton) {
  }
  @IBAction func payInHotel(sender: UIButton) {
    

    let chatVC = JSHChatVC(chatType: .CallingWaiter)
    chatVC.location = "不在酒店"
//    let navController = UINavigationController(rootViewController: chatVC)
//    navController.navigationBar.tintColor = UIColor.blackColor()
//    navController.navigationBar.translucent = false
//    //    presentViewController(navController, animated: true, completion: nil)
//    UIApplication .sharedApplication().keyWindow?.rootViewController!.presentViewController(navController, animated: true) { () -> Void in
//      self.dismissViewControllerAnimated(false, completion: nil)
//      
//    }
    chatVC.navigationItem.hidesBackButton = true
    self.navigationController?.navigationBar.tintColor = UIColor.blackColor()
    self.navigationController?.navigationBar.translucent = false
    self.navigationController?.pushViewController(chatVC, animated: true)
    

//    let chatVC = JSHChatVC(chatType: .CallingWaiter)
//    chatVC.location = "不在酒店"
//    let navController = UINavigationController(rootViewController: chatVC)
//    navController.navigationBar.tintColor = UIColor.blackColor()
//    navController.navigationBar.translucent = false
////    presentViewController(navController, animated: true, completion: nil)
//    presentViewController(navController, animated: true) { () -> Void in
////      self.dismissViewControllerAnimated(false, completion: nil)
//
//    }
  }

//MARK:- ALIPAY
  func payAliOrder(AbookOrder: BookOrder) {
    let aliOrder = AlipayOrder()
    aliOrder.partner = partner
    aliOrder.seller = seller
//    aliOrder.tradeNO = tradeNo  //need to fetch 
    aliOrder.tradeNO = AbookOrder.orderno
    aliOrder.productName = AbookOrder.room_type
    aliOrder.productDescription = "needtoknow"
    if let rooms = AbookOrder.rooms.toInt() {
      let amount = (AbookOrder.room_rate as NSString).doubleValue * Double(rooms)
//    aliOrder.amount = NSString(format:"%.2f", amount) as String
      aliOrder.amount = "0.02"
    }
    
    aliOrder.notifyURL = "http:www.baidu.com"
    aliOrder.service = "mobile.securitypay.pay"
    aliOrder.paymentType = "1"
    aliOrder.inputCharset = "utf-8"
    aliOrder.itBPay = "30m"
    aliOrder.showUrl = "m.alipay.com"
    
    //应用注册scheme,在AlixPayDemo-Info.plist定义URL types
    let appScheme = "SVIPPAY"
    
    //将商品信息拼接成字符串
    let orderSpec = aliOrder.description
    print(orderSpec)
    
    //获取私钥并将商户信息签名,外部商户可以根据情况存放私钥和签名,只需要遵循RSA签名规范,并将签名字符串base64编码和UrlEncode
//    id<DataSigner> signer = CreateRSADataSigner(privateKey);
//    NSString *signedString = [signer signString:orderSpec];
    let signer = CreateRSADataSigner(privateKey)
    if let signedString = signer.signString(orderSpec) {
      let orderString = String(format: "%@&sign=\"%@\"&sign_type=\"%@\"", orderSpec, signedString, "RSA")
      let service = AlipaySDK .defaultService()
//      service .payOrder("abc", fromScheme: "abc", callback: { (resultDic: AnyObject!) -> Void in
//
//      })
      service .payOrder(orderString, fromScheme: appScheme, callback: { ([NSObject : AnyObject]!) -> Void in
        
      })
      
    }
    
    //将签名成功字符串格式化为订单字符串,请严格按照该格式
//    NSString *orderString = nil;
//    if (signedString != nil) {
//      orderString = [NSString stringWithFormat:@"%@&sign=\"%@\"&sign_type=\"%@\"",
//      orderSpec, signedString, @"RSA"];
//      
//      [[AlipaySDK defaultService] payOrder:orderString fromScheme:appScheme callback:^(NSDictionary *resultDic) {
//      NSLog(@"reslut = %@",resultDic);
//      }];
//
//    }

  }
  
  
  
}
