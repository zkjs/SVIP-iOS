//
//  HotelCell.swift
//  SVIP
//
//  Created by AlexBang on 15/11/10.
//  Copyright © 2015年 zkjinshi. All rights reserved.
//

import UIKit

class HotelCell: UITableViewCell {
  typealias ButtonTapHandler = () -> Void
  var salesmanTapHandler: ButtonTapHandler?

  
  @IBOutlet weak var userImageButton: UIButton! {
    didSet {
      userImageButton.layer.masksToBounds = true
      userImageButton.layer.cornerRadius = 24
    }
  }
  @IBOutlet weak var descriptionLabel: UILabel! {
    didSet {
      descriptionLabel.textColor = UIColor.ZKJS_textColor()
    }
  }
  @IBOutlet weak var addressLabel: UILabel! {
    didSet {
      addressLabel.numberOfLines = 0
    }
  }
  @IBOutlet weak var customLabel: UILabel! {
    didSet {
      customLabel.text = ""
    }
  }
  @IBOutlet weak var hotelNameLabel: UILabel! {
    didSet {
      hotelNameLabel.text = ""
    }
  }

  @IBOutlet weak var hotelImageView: UIImageView!

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
    return 317
  }
  
  func configCell(shop:Shop, salesmanTapHandler:ButtonTapHandler?) {
    self.salesmanTapHandler = salesmanTapHandler
    selectionStyle = UITableViewCellSelectionStyle.None
    hotelNameLabel.text = shop.shopname
    descriptionLabel.text = shop.shopaddress
    addressLabel.text = shop.recomm
    customLabel.text = shop.shoptitle
    customLabel.sizeToFit()
    hotelImageView.sd_setImageWithURL(NSURL(string: shop.bgimgurl.fullImageUrl), placeholderImage: nil)
    userImageButton.sd_setBackgroundImageWithURL(NSURL(string: shop.shoplogo.fullImageUrl), forState: UIControlState.Normal,placeholderImage: UIImage(named: "img_hotel_zhanwei"))
  }


  override func setSelected(selected: Bool, animated: Bool) {
      super.setSelected(selected, animated: animated)

      // Configure the view for the selected state
  }
    
  @IBAction func salesmanButtonTapped(sender: UIButton) {
    salesmanTapHandler?()
  }
  
}
