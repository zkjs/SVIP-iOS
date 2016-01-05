//
//  CustonCell.swift
//  SVIP
//
//  Created by AlexBang on 15/12/5.
//  Copyright © 2015年 zkjinshi. All rights reserved.
//

import UIKit

class CustonCell: UITableViewCell {
  

  @IBOutlet weak var bluetoolView: UIView!
  @IBOutlet weak var greetLabel: UILabel!
  @IBOutlet weak var dynamicLabel: UILabel!
  @IBOutlet weak var userNameLabel: UILabel!
  @IBOutlet weak var activeButton: UIButton!
  @IBOutlet weak var loginButton: UIButton!
  @IBOutlet weak var hotelImageView: UIImageView!
  
  var hourLabel = String()
  var sexString = String()//性别
  var nowDate = NSDate()
  var compareNumber:NSNumber!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
    
    bluetoolView.hidden = true
  }
  
  class func reuseIdentifier() -> String {
    return "CustonCell"
  }
  
  class func nibName() -> String {
    return "CustonCell"
  }
  
  class func height() -> CGFloat {
    return 339
  }
  
  func setData(activate:Bool,homeUrl:String) {
    let animation = CABasicAnimation(keyPath:"transform.scale")
    //动画选项设定
    animation.duration = 30
    animation.repeatCount = HUGE
    animation.autoreverses = true
    animation.fromValue = NSNumber(double: 1.0)
    animation.toValue = NSNumber(double: 1.4)
    hotelImageView.layer.addAnimation(animation, forKey: "scale-layer")
    if homeUrl != "" {
      hotelImageView.sd_setImageWithURL(NSURL(string: homeUrl), placeholderImage: nil)
    }
    let nowDate = NSDate()
    let hourFormatter = NSDateFormatter()
    hourFormatter.dateFormat = "HH"
    let time = hourFormatter.stringFromDate(nowDate)
    let beacon = StorageManager.sharedInstance().lastBeacon()
    loginButton.hidden = true
    activeButton.hidden = false
    if(time <= "09" && time > "00" ){
      hourLabel = "早上好"
    }
    if(time <= "11" && time > "09" ){
      hourLabel = "上午好"
    }
    if(time <= "12" && time > "11" ){
      hourLabel = "中午好"
    }
    if(time <= "18" && time > "12" ){
      hourLabel = "下午好"
    }
    if(time <= "24" && time > "18" ){
      hourLabel = "晚上好"
    }
    greetLabel.text = hourLabel
    let sex = AccountManager.sharedInstance().sex
    if sex == "1" {
      sexString = "先生"
    } else {
      sexString  = "女士"
    }
    let loginStats = AccountManager.sharedInstance().isLogin()
//    let image = AccountManager.sharedInstance().avatarImage
    
    if loginStats == false {
      loginButton.hidden = false
      activeButton.hidden = true
      loginButton.setTitle("立即登录", forState: UIControlState.Normal)
      loginButton.tintColor = UIColor.ZKJS_mainColor()
      dynamicLabel.text = "使用超级身份，享受超凡个性服务"
    }
    if loginStats == true && activate == false {
      userNameLabel.text = AccountManager.sharedInstance().userName + " \(self.sexString)"
      activeButton.setTitle("立即激活", forState: UIControlState.Normal)
      activeButton.tintColor = UIColor.ZKJS_mainColor()
      dynamicLabel.text = "输入邀请码激活身份，享受超凡个性服务"
    }
    if loginStats == true && activate == true {
      activeButton.hidden = true
      userNameLabel.text = AccountManager.sharedInstance().userName + " \(self.sexString)"
      dynamicLabel.text = "使用超级身份，享受超凡个性服务"
    }
    if loginStats == true && activate == true && beacon != nil {
      activeButton.hidden = true
      userNameLabel.text = AccountManager.sharedInstance().userName + " \(self.sexString)"
//      dynamicLabel.text = "欢迎光临\(beacon!["remark"])"
      dynamicLabel.text = ""
    }
  }
  
}
