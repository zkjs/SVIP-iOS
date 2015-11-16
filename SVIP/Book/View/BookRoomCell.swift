//
//  BookRoomCell.swift
//  SVIP
//
//  Created by dai.fengyi on 15/6/30.
//  Copyright (c) 2015年 zkjinshi. All rights reserved.
//

import UIKit

class BookRoomCell: UITableViewCell {
  @IBOutlet private weak var roomLook: UIImageView!
  @IBOutlet private weak var priceTag: UILabel!
  @IBOutlet private weak var selectedView: UIImageView!
  
  //DATA
  var goods: RoomGoods? {
    didSet {
      if let myGoods = goods {
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
          let placeholderImage = UIImage(named: "星空中心")
          var url = NSURL(string: baseUrl)
          url = url?.URLByAppendingPathComponent(goodsImage)
          roomLook.sd_setImageWithURL(url, placeholderImage: placeholderImage, options: [.LowPriority, .RetryFailed], completed: nil)
        }
      }
    }
  }
  
  override func awakeFromNib() {
    super.awakeFromNib()

  }

  override func setSelected(selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    selectedView.hidden = !selected
    // Configure the view for the selected state
  }
}