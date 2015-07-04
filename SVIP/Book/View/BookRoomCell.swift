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
  
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
    Avatar.layer.cornerRadius = Avatar.bounds.size.height / 2
    Avatar.clipsToBounds = true
    

  }

  override func setSelected(selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)

    // Configure the view for the selected state
  }
  
}
