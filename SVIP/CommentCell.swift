//
//  CommentCell.swift
//  SVIP
//
//  Created by AlexBang on 16/5/7.
//  Copyright © 2016年 zkjinshi. All rights reserved.
//

import UIKit

class CommentCell: UITableViewCell {

  @IBOutlet weak var commentContent: UILabel!
  @IBOutlet weak var commentTime: UILabel!
  @IBOutlet weak var username: UILabel!
  @IBOutlet weak var userImageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
      self.contentView.backgroundColor = UIColor(patternImage: UIImage(named: "texture_bg")!)
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
  
  func configCell(region:RegionComment) {
    commentContent.text = region.content
    let nowDateFormate = NSDateFormatter()
    let nowDate = NSDate()
    nowDateFormate.dateFormat = "MM-dd HH:mm" 
    let nowString = nowDateFormate.stringFromDate(nowDate)
    commentTime.text = nowString
    userImageView.sd_setImageWithURL(NSURL(string: region.avatarUrl!))
    username.text = region.userName
    
    
  }

}
