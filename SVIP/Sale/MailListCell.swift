//
//  MailListCell.swift
//  SVIP
//
//  Created by AlexBang on 15/11/28.
//  Copyright © 2015年 zkjinshi. All rights reserved.
//

import UIKit

class MailListCell: UITableViewCell {

  @IBOutlet weak var contactNameLabel: UILabel!
  @IBOutlet weak var contactImageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
    }
  
  class func reuseIdentifier() -> String {
    return "MailListCell"
  }
  
  class func nibName() -> String {
    return "MailListCell"
  }
  
  class func height() -> CGFloat {
    return 80
  }
  
  func setData(contact:ContactModel) {
    contactNameLabel.text = contact.fname
    let url = NSURL(string: kBaseURL)
    let urlStr = url?.URLByAppendingPathComponent("uploads/users/\(contact.userid).jpg")
    contactImageView.sd_setImageWithURL(urlStr, placeholderImage: UIImage(named: "img_hotel_zhanwei"))

  }


    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
