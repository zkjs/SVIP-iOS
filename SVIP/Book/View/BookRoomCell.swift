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
  var goods: RoomGoods? {
    didSet {
      if goods != nil {
        name.text = goods!.fullname
        var nameStr = ""
        var priceStr = ""
        if let a = goods?.fullname {
          nameStr = a
        }
        if let b = goods?.pice {
          priceStr = b
        }
        var room: String! = ""
        var type: String! = ""
        if goods?.room != nil {
          room = goods?.room
        }
        if goods?.type != nil {
          type = goods?.type
        }
        let tagStr = "  \(room)\(type)   $\(priceStr)"
        priceTag.text = tagStr

        let baseUrl = "http://120.25.241.196/"
        if let goodsImage = goods?.image {
          let urlStr = baseUrl .stringByAppendingString(goodsImage)
          let placeholderImage = UIImage(named: "星空中心")
          let url = NSURL(string: urlStr)
          roomLook.sd_setImageWithURL(url, placeholderImage: placeholderImage, options: SDWebImageOptions.LowPriority | SDWebImageOptions.RetryFailed, completed: nil)
        }
        if let logo = goods?.logo {
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