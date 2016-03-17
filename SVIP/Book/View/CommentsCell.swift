//
//  CommentsCell.swift
//  SVIP
//
//  Created by AlexBang on 16/1/3.
//  Copyright © 2016年 zkjinshi. All rights reserved.
//

import UIKit

class CommentsCell: UITableViewCell {

  @IBOutlet weak var contentEvaluation: UILabel!
  @IBOutlet weak var commentsDateLabel: UILabel!
  @IBOutlet weak var appraiserNameLabel: UILabel!
  @IBOutlet weak var appraiserImage: UIImageView!{
    didSet {
      appraiserImage.layer.masksToBounds = true
      appraiserImage.layer.cornerRadius = appraiserImage.frame.width / 2.0
    }
  }

  override func awakeFromNib() {
      super.awakeFromNib()
      // Initialization code
  }

  class func reuseIdentifier() -> String {
    return "CommentsCell"
  }
  
  class func nibName() -> String {
    return "CommentsCell"
  }
  
  class func height() -> CGFloat {
    return 130.0
  }

  override func setSelected(selected: Bool, animated: Bool) {
      super.setSelected(selected, animated: animated)

      // Configure the view for the selected state
  }
  
  func configCell(comment:CommentModel) {
    selectionStyle = UITableViewCellSelectionStyle.None
    appraiserNameLabel.text = comment.username
    let hotelUrl = "\(kImageURL)/uploads/users/\(comment.userid).jpg"
    appraiserImage.sd_setImageWithURL(NSURL(string: hotelUrl), placeholderImage: UIImage(named: "img_hotel_zhanwei"))
    contentEvaluation.text = comment.content
    commentsDateLabel.text = comment.createtime
  }
    
}
