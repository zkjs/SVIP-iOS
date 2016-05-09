//
//  WaiterTipsCell.swift
//  SVIP
//
//  Created by AlexBang on 16/4/22.
//  Copyright © 2016年 zkjinshi. All rights reserved.
//

import UIKit

class WaiterTipsCell: UICollectionViewCell {
    
  @IBOutlet weak var waiterNameLabel: UILabel!
  @IBOutlet weak var waiterImage: UIImageView!
  override func awakeFromNib() {
    
  }
  
  func configCell(user:Waiter) {
    waiterNameLabel.text = user.name
    waiterImage.sd_setImageWithURL(NSURL(string: user.avatar.fullImageUrl), placeholderImage: UIImage(named: ""))
  }
}
