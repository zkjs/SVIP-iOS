//
//  HotelCell.swift
//  SVIP
//
//  Created by AlexBang on 15/11/10.
//  Copyright © 2015年 zkjinshi. All rights reserved.
//

import UIKit

class HotelCell: UITableViewCell {

  
  @IBOutlet weak var customLabel: UILabel!
  @IBOutlet weak var hotelNameLabel: UILabel!
  @IBOutlet weak var hotelImageView: UIImageView!
//    {
//    didSet {
//      hotelImageView.layer.masksToBounds = true
//      hotelImageView.layer.cornerRadius = 30
//    }
//  }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
  class func reuseIdentifier() -> String {
    return "HotelCell"
  }
  
  class func nibName() -> String {
    return "HotelCell"
  }
  
  class func height() -> CGFloat {
    return 321
  }
  func setData(hotel:Hotel) {
    hotelNameLabel.text = hotel.shopname
    let placeholderImage = UIImage(named: "img_hotel_zhanwei")
    let urlString = "\(kBaseURL)\(hotel.shoplogo)"
    let logoURL = NSURL(string: urlString)
    hotelImageView.sd_setImageWithURL(logoURL, placeholderImage: placeholderImage)
  }


    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
