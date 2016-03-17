//
//  RecommandCell.swift
//  SVIP
//
//  Created by AlexBang on 15/12/17.
//  Copyright © 2015年 zkjinshi. All rights reserved.
//

import UIKit

class RecommandCell: UITableViewCell {

  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var contentLabel: UILabel!
  @IBOutlet weak var backImageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
  
  class func reuseIdentifier() -> String {
    return "RecommandCell"
  }
  
  class func nibName() -> String {
    return "RecommandCell"
  }
  
  class func height() -> CGFloat {
    return 240
  }
  func setdata(hotel:Hotel) {
    titleLabel.text = hotel.shopname
    let logoURL = NSURL(string: hotel.bgImgUrl.fullImageUrl)
    backImageView.sd_setImageWithURL(logoURL)
    contentLabel.text = hotel.shoptitle
    contentLabel.sizeToFit()

  }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
