//
//  HotelCell.swift
//  SVIP
//
//  Created by AlexBang on 15/11/10.
//  Copyright © 2015年 zkjinshi. All rights reserved.
//

import UIKit

class HotelCell: UITableViewCell {

  
  @IBOutlet weak var userImageButton: UIButton! {
    didSet {
      userImageButton.layer.masksToBounds = true
      userImageButton.layer.cornerRadius = 24
    }
  }
  @IBOutlet weak var addressLabel: UILabel! {
    didSet {
      addressLabel.numberOfLines = 0
    }
  }
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
    return 385
  }
  
  
  func setData(hotel:Hotel) {
    hotelNameLabel.text = hotel.shopname
    let placeholderImage = UIImage(named: "img_hotel_zhanwei")
    addressLabel.text = hotel.shopaddress
    let logoURL = NSURL(string: hotel.bgImgUrl)
    hotelImageView.sd_setImageWithURL(logoURL, placeholderImage: placeholderImage)
    if let salesid = hotel.salesid {
      let url = NSURL(string: kBaseURL)
      let urlStr = url?.URLByAppendingPathComponent("uploads/users/\(salesid).jpg")
      userImageButton.sd_setBackgroundImageWithURL(urlStr, forState: UIControlState.Normal)
    }

   
  }


    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
