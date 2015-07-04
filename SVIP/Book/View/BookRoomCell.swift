//
//  BookRoomCell.swift
//  SVIP
//
//  Created by dai.fengyi on 15/6/30.
//  Copyright (c) 2015年 zkjinshi. All rights reserved.
//

import UIKit

class BookRoomCell: UITableViewCell {

  @IBOutlet weak var Avatar: UIImageView!
  @IBOutlet weak var name: UILabel!
  @IBOutlet weak var roomLook: UIImageView!
  @IBOutlet weak var priceTag: UILabel!
  @IBOutlet weak var selectedView: UIImageView!
  
  //DATA
  var order: BookOrder? {
    didSet {
      if order != nil {
        name.text = order!.name
        var nameStr = ""
        var priceStr = ""
        if let a = order?.name {
          nameStr = a
        }
        if let b = order?.market_price {
          priceStr = b
        }
        let tagStr = "  \(nameStr)   $\(priceStr)"
        priceTag.text = tagStr

        let baseUrl = "http://172.21.7.54/"
        if let goodsImage = order?.goods_img {
          let urlStr = baseUrl .stringByAppendingString(goodsImage)
          let placeholderImage = UIImage(named: "星空中心")
          let url = NSURL(string: urlStr)
          roomLook.sd_setImageWithURL(url, placeholderImage: placeholderImage, options: SDWebImageOptions.LowPriority | SDWebImageOptions.RetryFailed, completed: nil)
        }
      }
    }
  }
  
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
    Avatar.layer.cornerRadius = Avatar.bounds.size.height / 2
    Avatar.clipsToBounds = true
  }

  override func setSelected(selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    selectedView.hidden = !selected
    // Configure the view for the selected state
  }
}