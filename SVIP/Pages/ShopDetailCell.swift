//
//  ShopDetailCell.swift
//  SVIP
//
//  Created by AlexBang on 16/4/7.
//  Copyright © 2016年 zkjinshi. All rights reserved.
//

import UIKit

class ShopDetailCell: UITableViewCell {

  @IBOutlet weak var introduceLabel: UILabel!
  @IBOutlet weak var customImageView: UIImageView!
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var imageHeightConstraint: NSLayoutConstraint!
  @IBOutlet weak var titleConstraint: NSLayoutConstraint!
  @IBOutlet weak var titleAndImageConstraint: NSLayoutConstraint!
    override func awakeFromNib() {
        super.awakeFromNib()
      
      self.contentView.backgroundColor = UIColor(patternImage: UIImage(named: "texture_bg")!)
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
  
  
  class func reuseIdentifier() -> String {
    return "ShopDetailCell"
  }
  
  class func nibName() -> String {
    return "ShopDetailCell"
  }
  
  func configCell(shopmod:ShopmodsModel) {
    guard let title:String = shopmod.title else {
      titleConstraint.constant = 0
      return
    }
    titleLabel.text = title
    guard let arr:NSArray = shopmod.photos where arr.count > 0 else {return}
    guard let url:String = arr[0] as? String else {
      titleAndImageConstraint.constant = 0
      imageHeightConstraint.constant = 0
      return
    }
    customImageView.sd_setImageWithURL(NSURL(string: url))
    guard let body:String = shopmod.body else {
      
      return
    }
    introduceLabel.text = body
  }
    
}
