//
//  BookRoomCell.swift
//  SVIP
//
//  Created by dai.fengyi on 15/6/30.
//  Copyright (c) 2015年 zkjinshi. All rights reserved.
//

import UIKit

class BookRoomCell: UITableViewCell {
  @IBOutlet private weak var Avatar: UIImageView!
  @IBOutlet private weak var name: UILabel!
  @IBOutlet private weak var roomLook: UIImageView!
  @IBOutlet private weak var priceTag: UILabel!
  @IBOutlet private weak var selectedView: UIImageView!
  
  //DATA
  var goods: RoomGoods? {
    didSet {
      if let myGoods = goods {
        name.text = myGoods.fullname
        var priceStr = ""
        var room: String! = ""
        var type: String! = ""
        if let b = myGoods.price {
          priceStr = b
        }
        if myGoods.room != nil {
          room = myGoods.room
        }
        if myGoods.type != nil {
          type = myGoods.type
        }
        let tagStr = "  \(room)\(type)   ¥\(priceStr)"
        priceTag.text = tagStr

        let baseUrl = "http://120.25.241.196/"
        if let goodsImage = myGoods.image {
          let urlStr = baseUrl .stringByAppendingString(goodsImage)
          let placeholderImage = UIImage(named: "星空中心")
          let url = NSURL(string: urlStr)
          roomLook.sd_setImageWithURL(url, placeholderImage: placeholderImage, options: SDWebImageOptions.LowPriority | SDWebImageOptions.RetryFailed, completed: nil)
        }
        if let logo = myGoods.logo {
          let urlStr = baseUrl .stringByAppendingString(logo)
          let placeholderImage = UIImage(named: "星空中心")
          let url = NSURL(string: urlStr)
          Avatar.sd_setImageWithURL(url, placeholderImage: placeholderImage, options: SDWebImageOptions.LowPriority | SDWebImageOptions.RetryFailed, completed: nil)
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