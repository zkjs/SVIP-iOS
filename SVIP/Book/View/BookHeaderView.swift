//
//  BookHeaderView.swift
//  SVIP
//
//  Created by AlexBang on 15/12/17.
//  Copyright © 2015年 zkjinshi. All rights reserved.
//

import UIKit

class BookHeaderView: UIView {

  @IBOutlet weak var userImageButton: UIButton! {
    didSet {
      userImageButton.layer.masksToBounds = true
      userImageButton.layer.cornerRadius = 28
    }
  }
  @IBOutlet weak var backButton: UIButton!
  @IBOutlet weak var addressLabel: UILabel!
  @IBOutlet weak var introducesLabel: UILabel! {
    didSet {
      
      introducesLabel.numberOfLines = 0
    
    }
  }
  @IBOutlet weak var explainLabel: UILabel!
  @IBOutlet weak var hotelNameLabel: UILabel!
  @IBOutlet weak var backImageView: UIImageView!
  
  
  class func height() -> CGFloat {
    return 387.0
  }
  
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
extension NSString {
  func textSizeWithFont(font: UIFont, constrainedToSize size:CGSize) -> CGSize {
    var textSize:CGSize!
    if CGSizeEqualToSize(size, CGSizeZero) {
      let attributes = NSDictionary(object: font, forKey: NSFontAttributeName)
      textSize = self.sizeWithAttributes(attributes as? [String : AnyObject])
    } else {
      let option = NSStringDrawingOptions.UsesLineFragmentOrigin
      let attributes = NSDictionary(object: font, forKey: NSFontAttributeName)
      let stringRect = self.boundingRectWithSize(size, options: option, attributes: attributes as? [String : AnyObject], context: nil)
      textSize = stringRect.size
    }
    return textSize
  }
}


