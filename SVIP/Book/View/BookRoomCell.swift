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
  
  
  class func reuseIdentifier() -> String {
    return "BookRoomCell"
  }
  
  class func nibName() -> String {
    return "BookRoomCell"
  }
  
  class func height() -> CGFloat {
    return 171.0
  }
  
  //DATA
  
  func setData(goods: RoomGoods) {
    var room: String! = ""
    if goods.room != nil {
      room = goods.room
    }
    priceTag.text = room
    
    if let goodsImage = goods.image {
      roomLook.sd_setImageWithURL(NSURL(string: goodsImage.fullImageUrl))
    }
  }
  
  override func awakeFromNib() {
    super.awakeFromNib()
    
  }
  
  override func setSelected(selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    selectedView.hidden = !selected
  }
  
}