//
//  PaylistCell.swift
//  SVIP
//
//  Created by AlexBang on 16/3/19.
//  Copyright © 2016年 zkjinshi. All rights reserved.
//

import UIKit

class MesssageListCell: UITableViewCell {

  @IBOutlet weak var moneyPayLabel: UILabel!
  @IBOutlet weak var timeLabel: UILabel!
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var msgImgView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

  class func reuseIdentifier() -> String {
    return "MesssageListCell"
  }

  class func nibName() -> String {
    return "MesssageListCell"
  }

  class func height() -> CGFloat {
    return 100
  }

  func configCellWithPayInfo(pay:PaylistmModel) {
    msgImgView.hidden = true
    moneyPayLabel.hidden = false
    
    moneyPayLabel.text = pay.displayAmount
    timeLabel.text = pay.createtime
    titleLabel.text = pay.shopname
  }
  
  func configCellWithPushMessage(message:PushMessage) {
    msgImgView.hidden = false
    moneyPayLabel.hidden = true
    
    titleLabel.text = message.title
    timeLabel.text = message.timestamp.formatted
    if let imgUrl = message.imgUrl, url = NSURL(string: imgUrl.fullImageUrlWith(width: 240)) {
      msgImgView?.sd_setImageWithURL(url)
    }
  }
}
