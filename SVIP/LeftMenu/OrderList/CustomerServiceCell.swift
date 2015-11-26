//
//  CustomerServiceCell.swift
//  SVIP
//
//  Created by AlexBang on 15/11/23.
//  Copyright © 2015年 zkjinshi. All rights reserved.
//

import UIKit

class CustomerServiceCell: UITableViewCell {

  @IBOutlet weak var hotelNameLabel: UILabel!
  @IBOutlet weak var servicerNameLabel: UILabel!
  @IBOutlet weak var hotelImageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
  class func reuseIdentifier() -> String {
    return "CustomerServiceCell"
  }
  
  class func nibName() -> String {
    return "CustomerServiceCell"
  }
  class func height() -> CGFloat {
    return 100
  }
  func setData(servicer:ServicerModel) {
    servicerNameLabel.text = servicer.name
    hotelNameLabel.text = servicer.phone.stringValue
    let salesid = servicer.salesid
    let placeholderImage = UIImage(named: "img_hotel_zhanwei")
    let urlString = "\(kBaseURL)uploads/shops/\(salesid).png"
    let logoURL = NSURL(string: urlString)
    hotelImageView.sd_setImageWithURL(logoURL, placeholderImage: placeholderImage)
    
  }


    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
