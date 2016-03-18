//
//  HomeCell.swift
//  SVIP
//
//  Created by AlexBang on 15/12/13.
//  Copyright © 2015年 zkjinshi. All rights reserved.
//

import UIKit
import SDWebImage

class HomeCell: UITableViewCell {
  
  @IBOutlet weak var pushImage: UIImageView!
  @IBOutlet weak var nextLabel: UILabel! {
    didSet {
      nextLabel.numberOfLines = 0
      
    }
  }
  @IBOutlet weak var subjectLabel: UILabel!
  @IBOutlet weak var backImageView: UIImageView! {
    didSet {
      backImageView.layer.borderWidth = 0.5
      backImageView.layer.borderColor = UIColor.lightGrayColor().CGColor
      backImageView.layer.cornerRadius = 28
    }
  }
  
  var resolution:Int32!
  
  
  class func reuseIdentifier() -> String {
    return "HomeCell"
  }
  
  class func nibName() -> String {
    return "HomeCell"
  }
  
  class func height() -> CGFloat {
    return 200
  }
  
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
  }
  
  override func setSelected(selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    // Configure the view for the selected state
  }
  
  func configCell(pushInfo pushInfo:PushInfoModel) {
    selectionStyle = UITableViewCellSelectionStyle.None
    resolution = ZKJSTool.getResolution()
    let BaseURL = ZKJSConfig.sharedInstance.BaseImageURL + "\(pushInfo.iconbaseurl)" + "picture/ios/" + "\(resolution)" + "\(pushInfo.iconfilename)"
    let url = NSURL(string: BaseURL)
    pushImage.sd_setImageWithURL(url, placeholderImage: UIImage(named: "ic_v_orange"))
    subjectLabel.text = pushInfo.title
    subjectLabel.sizeToFit()
    nextLabel.text = pushInfo.desc.isEmpty ? pushInfo.shopName : pushInfo.desc
    nextLabel.sizeToFit()
    let frame = nextLabel.frame
    nextLabel.frame = CGRectMake(CGRectGetMinX(frame), CGRectGetMaxY(subjectLabel.frame)+8, CGRectGetWidth(frame), CGRectGetHeight(frame))
    if pushInfo.shopid.isEmpty {//&& pushInfo.orderNo.isEmpty {
      accessoryView = nil
    } else {
      accessoryView = UIImageView(image: UIImage(named: "ic_right_orange"))
    }
  }
  
  func configCell(privilege privilege:PrivilegeModel) {
    let pushInfo = PushInfoModel()
    pushInfo.iconbaseurl = privilege.privilegeIcon
    pushInfo.title = privilege.privilegeName
    pushInfo.desc = privilege.privilegeDesc
    
    configCell(pushInfo: pushInfo)
    accessoryView = nil
  }
  
}
