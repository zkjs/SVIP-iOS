//
//  PhotosViewerVC.swift
//  SVIP
//
//  Created by AlexBang on 16/1/2.
//  Copyright © 2016年 zkjinshi. All rights reserved.
//

import UIKit

class PhotosViewerVC: UIViewController {

  @IBOutlet weak var scrollView: UIScrollView!{
    didSet {
      scrollView.bounces = false
      scrollView.pagingEnabled = true
//      scrollView.delegate = self
      scrollView.showsHorizontalScrollIndicator = false
    }
  }

  var imgUrl = NSArray()
    override func viewDidLoad() {
        super.viewDidLoad()
    scrollView.backgroundColor = UIColor.blackColor()
      
    }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    for var i = 0; i < imgUrl.count; i++ {
      let imgView = BrowserImageView()
      imgView.addTarget(self, action: "photoViewer")
      let url = NSURL(string:imgUrl[i] as! String)
      imgView.sd_setImageWithURL(url, placeholderImage: nil)
      imgView.frame = CGRectMake(CGFloat(i) * view.bounds.size.width, 0, view.frame.size.width, view.frame.size.height)
      imgView.contentMode = UIViewContentMode.ScaleAspectFit
      self.scrollView.addSubview(imgView)
    }
     scrollView.contentOffset = CGPointMake(0.0, 0.0)
     scrollView.contentSize = CGSizeMake(CGFloat(imgUrl.count) * view.bounds.size.width, 400)

  }
  
  func photoViewer() {
    self.dismissViewControllerAnimated(true, completion: nil)
  }
  
  
   func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
    
 }

  
 
  
  

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
