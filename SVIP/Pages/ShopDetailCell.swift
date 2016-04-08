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
  @IBOutlet weak var seperatorLine: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
      
      self.contentView.backgroundColor = UIColor(patternImage: UIImage(named: "texture_bg")!)
      seperatorLine.backgroundColor = UIColor(patternImage: UIImage(named: "home_line")!)
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
    if shopmod.title.isEmpty  {
      titleConstraint.constant = 0
    } else {
      titleConstraint.constant = 25
      titleLabel.text = shopmod.title
    }
    
    if shopmod.photos.count > 0  {
      titleAndImageConstraint.constant = 25
      imageHeightConstraint.constant = 210
      
      customImageView.sd_setImageWithURL(NSURL(string: shopmod.photos[0]))
    } else {
      titleAndImageConstraint.constant = 0
      imageHeightConstraint.constant = 0
    }
    
    if let body:String = shopmod.body {
      introduceLabel.text = body
    }
    
  }
    
}
