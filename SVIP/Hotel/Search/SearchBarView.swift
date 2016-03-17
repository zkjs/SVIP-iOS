//
//  SearchBarView.swift
//  SVIP
//
//  Created by AlexBang on 15/11/12.
//  Copyright © 2015年 zkjinshi. All rights reserved.
//

import UIKit

class SearchBarView: UIView,UISearchBarDelegate {

  @IBOutlet weak var searchBar: UISearchBar! {
    didSet {
      searchBar.delegate = self
//      searchBar.layer.borderColor = UIColor.whiteColor().CGColor
      searchBar.layer.cornerRadius = 8
      searchBar.layer.masksToBounds = true
      searchBar.layer.borderWidth = 8
    }
  }
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
