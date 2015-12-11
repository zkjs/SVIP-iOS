//
//  HomeHeaderView.swift
//  SVIP
//
//  Created by AlexBang on 15/12/5.
//  Copyright © 2015年 zkjinshi. All rights reserved.
//

import UIKit

class HomeHeaderView: UIView {

  @IBOutlet weak var custonLabel: UILabel! {
    didSet {
      custonLabel.numberOfLines = 0
    }
  }
  @IBOutlet weak var connectButton: UIButton!
  @IBOutlet weak var activateLabel: UILabel!
  @IBOutlet weak var locationImage: UIImageView!
  @IBOutlet weak var usernameLabel: UILabel!
  @IBOutlet weak var currentCityLabe: UILabel!
  @IBOutlet weak var LocationButton: UIButton!{
    didSet {
      LocationButton.layer.masksToBounds = true
      LocationButton.layer.cornerRadius = 30
    }
  }

  @IBOutlet weak var backgroundImage: UIImageView!
  
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
    
      UIView.animateWithDuration(160, delay: 2, usingSpringWithDamping: 0.03, initialSpringVelocity: 0.5, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
        var point = self.locationImage.center
        point.y -= 6
        self.locationImage.center = point
        
        }) { (finished:Bool) -> Void in
      }
    }
  

}
