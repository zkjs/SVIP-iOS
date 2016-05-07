//
//  MapInDoorsVC.swift
//  SVIP
//
//  Created by Qin Yejun on 5/7/16.
//  Copyright © 2016 zkjinshi. All rights reserved.
//

import UIKit

class MapInDoorsVC: UIViewController {
  var region: Region?
  
  let regionData = RegionData.sharedInstance
  var currentMap = "floor_1"
  var currentMapSize = CGSizeMake(0, 0)
  var mapImageView: UIImageView!

  @IBOutlet weak var scrollView: UIScrollView!
  
  override func viewDidLoad() {
    super.viewDidLoad()

    title = "室内地图"
    
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "beaconFound:", name: KNOTIFICATION_BEACON_FOUND, object: nil)
    
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
    print(beacon)
    
    if let region = regionData.RegionWithBeacon(beacon) {
      print("========================= enter region")
      print(region)
      regionData.latestRegion = region
      regionData.latestTime = NSDate()
      updateMap(region)
    }
  }
  
  func setupMap() {
    mapImageView = UIImageView(frame: view.bounds)
    view.addSubview(mapImageView)
    let map = UIImage(named: currentMap)!
    currentMapSize = map.size
    print(currentMapSize)
    let width = map.size.width
    let height = map.size.height
    //mapImageView.frame = CGRectMake(0, 0, width, height)
    mapImageView.image = map
    mapImageView.contentMode = .ScaleAspectFill
    scrollView.contentSize = currentMapSize
  }
  
  func updateMap(region:Region) {
    if region.map != currentMap {
      currentMap = region.map
      setupMap()
    }
  }

}

extension MapInDoorsVC: UIScrollViewDelegate {
  
}
