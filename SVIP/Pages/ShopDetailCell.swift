//
//  ShopDetailCell.swift
//  SVIP
//
//  Created by AlexBang on 16/4/7.
//  Copyright © 2016年 zkjinshi. All rights reserved.
//

import UIKit
protocol PhotoViewerDelegate {
  func gotoPhotoViewerDelegate(brower:AnyObject)
}
class ShopDetailCell: UITableViewCell,MWPhotoBrowserDelegate {

  @IBOutlet weak var introduceLabel: UILabel!
  @IBOutlet weak var customImageView: UIImageView!
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var imageHeightConstraint: NSLayoutConstraint!
  @IBOutlet weak var titleConstraint: NSLayoutConstraint!
  @IBOutlet weak var titleAndImageConstraint: NSLayoutConstraint!
  @IBOutlet weak var seperatorLine: UIView!
  var photosArray = NSMutableArray()
  var photo = MWPhoto()
  var delegate:PhotoViewerDelegate?
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
      let tapGR = UITapGestureRecognizer(target: self, action: "photoViewer")
      customImageView.addGestureRecognizer(tapGR)
      photosArray.removeAllObjects()
      for image in shopmod.photos {
        let url = NSURL(string: image)
        self.photo = MWPhoto(URL: url!)
        self.photosArray.addObject(photo)
      }

      customImageView.sd_setImageWithURL(NSURL(string: shopmod.photos[0]))
    } else {
      titleAndImageConstraint.constant = 0
      imageHeightConstraint.constant = 0
    }
    
    if let body:String = shopmod.body {
      introduceLabel.text = body
    }
    
  }
  
  func photoViewer() {
    let browser = MWPhotoBrowser(delegate: self)
    browser.displayActionButton = false
    browser.displayNavArrows = false
    browser.displaySelectionButtons = false
    browser.alwaysShowControls = false
    browser.zoomPhotosToFill = true
    browser.enableGrid = true
    browser.startOnGrid = true
    browser.enableSwipeToDismiss = false
    browser.setCurrentPhotoIndex(0)
    self.delegate?.gotoPhotoViewerDelegate(browser)
  }
  
  func numberOfPhotosInPhotoBrowser(photoBrowser: MWPhotoBrowser!) -> UInt {
    return UInt(photosArray.count)
  }
  
  func photoBrowser(photoBrowser: MWPhotoBrowser!, photoAtIndex index: UInt) -> MWPhotoProtocol! {
    if index < UInt(self.photosArray.count) {
      return self.photosArray.objectAtIndex(Int(index)) as! MWPhotoProtocol
    }
    return nil
  }
    
}
