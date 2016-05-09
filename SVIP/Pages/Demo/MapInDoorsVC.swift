//
//  MapInDoorsVC.swift
//  SVIP
//
//  Created by Qin Yejun on 5/7/16.
//  Copyright © 2016 zkjinshi. All rights reserved.
//

import UIKit

class MapInDoorsVC: UIViewController {
  var currentRegion: Region?
  
  let regionData = RegionData.sharedInstance
  var currentMap = "floor_1"
  var currentMapSize = CGSizeMake(0, 0)
  var mapImageView: UIImageView!
  var scrollView: UIScrollView!
  var pin: UIImageView!
  
  override func viewDidLoad() {
    super.viewDidLoad()

    title = "室内地图"
    
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "beaconFound:", name: KNOTIFICATION_BEACON_FOUND, object: nil)
    
    scrollView = UIScrollView(frame: view.bounds)
    scrollView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
    scrollView.delegate = self
    view.addSubview(scrollView)
    
    pin = UIImageView(image: UIImage(named: "ic_map_pin"))
    //pin.frame.origin = CGPointMake(100, 100)
    pin.hidden = true
    view.addSubview(pin)
    
    setupMap()
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  deinit {
    NSNotificationCenter.defaultCenter().removeObserver(self)
  }
  
  func beaconFound(notification: NSNotification) {
    guard let userInfo = notification.userInfo, let beacon = userInfo["beacon"] as? CLBeacon else {
      return
    }
    //print(beacon)
    
    if let region = regionData.RegionWithBeacon(beacon) {
      //print("=========================[map] enter region")
      //print(region)
      regionData.latestRegion = region
      regionData.latestTime = NSDate()
      currentRegion = region
      updateMap(region)
      
      if let region = currentRegion {
        title = "\(region.floor)楼地图"
      }
    }
  }
  
  func setupMap() {
    for v in scrollView.subviews {
      v.removeFromSuperview()
    }
    
    mapImageView = UIImageView(image: UIImage(named: currentMap))
    
    scrollView.contentSize = mapImageView.bounds.size
    scrollView.addSubview(mapImageView)
    
    setZoomParametersForSize(scrollView.bounds.size)
    
    updatePinPosition()
  }
  
  func updateMap(region:Region) {
    if region.map != currentMap {
      currentMap = region.map
      setupMap()
    }
    updatePinPosition(true)
    
  }
  
  func setZoomParametersForSize(scrollViewSize: CGSize) {
    let imageSize = mapImageView.bounds.size
    
    let widthScale = scrollViewSize.width / imageSize.width
    let heightScale = (scrollViewSize.height - 64) / imageSize.height
    let minScale = min(widthScale, heightScale)
    
    scrollView.minimumZoomScale = minScale
    scrollView.maximumZoomScale = 2.0
    scrollView.zoomScale = max(widthScale, heightScale)
  }
  
  func updatePinPosition(recenter:Bool = false) {
    guard let region = currentRegion else { return }
    let pinWidth:CGFloat = 30
    let pinHeight:CGFloat = 47
    //region = regionData.allRegions!.first! //for test
    let x = region.coord.x
    let y = region.coord.y
    
    let scale = scrollView.zoomScale
    
    let scaleX = CGFloat(x) * scale
    let scaleY = CGFloat(y) * scale
    
    var finalX = scaleX - scrollView.contentOffset.x
    var finalY = scaleY - scrollView.contentOffset.y
    
    let pinScale = min(max(scale, 0.7), 1.0)
    
    finalY -= pinHeight * pinScale
    
    if recenter {
      var offsetX:CGFloat = 0
      var offsetY:CGFloat = 0
      let originOffset = scrollView.contentOffset
      let width = CGRectGetWidth(scrollView.bounds)
      let height = CGRectGetHeight(scrollView.bounds)
      
      if finalX > width || finalX < 0 {
        offsetX = finalX - width / 2
        finalX = width / 2
      }
      
      if finalY > height || finalY < 0 {
        offsetY = finalY - height / 2
        finalY = height / 2
      }

      scrollView.setContentOffset(CGPointMake(originOffset.x + offsetX, originOffset.y + offsetY), animated: true)
    }
    
    let pinFrame = CGRectMake(finalX, finalY, pinWidth * pinScale, pinHeight * pinScale)
    
    
    print("origin: [\(x),\(y)]")
    print("scale: [\(scaleX),\(scaleY)]")
    print("final: [\(finalX),\(finalY)]")
    //pin.frame.origin = CGPointMake(finalX, finalY)
    pin.frame = pinFrame
    pin.hidden = false
  }

}

extension MapInDoorsVC: UIScrollViewDelegate {
  func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
    return mapImageView
  }
  
  func scrollViewDidScroll(scrollView: UIScrollView) {
    print("offset: \(scrollView.contentOffset)")
    updatePinPosition()
  }
  
  func scrollViewDidZoom(scrollView: UIScrollView) {
    updatePinPosition()
  }
  
}
