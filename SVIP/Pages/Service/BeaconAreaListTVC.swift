//
//  DeptListTVC.swift
//  SVIP
//
//  Created by Qin Yejun on 6/22/16.
//  Copyright © 2016 zkjinshi. All rights reserved.
//

import UIKit

protocol BeaconAreaSelectDelegate {
  func selectArea(area:BeaconArea)
}

class BeaconAreaListTVC: UITableViewController {
  var shopid:String!
  var areasList:[String]!
  var delegate:BeaconAreaSelectDelegate?
  
  private var areas = [BeaconArea]()
  private var page = 0

  override func viewDidLoad() {
    super.viewDidLoad()

    title = "选择位置"
    
    if areasList != nil {
      convertAreas()
    } else if shopid != nil {
      loadData()
      //areasList = ["loc:0","loc:1"]
      //convertAreas()
    }
  }
  
  func convertAreas() {
    areas = areasList.map{ BeaconArea(locid: $0, area: $0) }
  }
  
  func getAreas(page:Int) {
    guard let shopid = shopid else { return }
    showHudInView(view, hint: "")
    HttpService.sharedInstance.getBeaconAreas(shopid) { (areas, error) in
      self.hideHUD()
      if let error = error {
        self.showErrorHint(error)
      } else {
        if areas.count == 0 {
          if page == 0 {
            self.showHint("没有区域数据")
          }
        } else {
          self.areas = areas
          self.tableView.reloadData()
        }
      }
    }
  }
  
  func loadData() {
    getAreas(0)
  }

  // MARK: - Table view data source

  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }

  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return areas.count
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("BeaconAreaCell", forIndexPath: indexPath)
    let area = areas[indexPath.row]
    cell.textLabel?.text = area.area
    
    return cell
  }
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    let area = areas[indexPath.row]
    if shopid != nil {
      goBackToServiceVC(area)
    } else {
      delegate?.selectArea(area)
      navigationController?.popViewControllerAnimated(true)
    }
  }
  
  func goBackToServiceVC(area:BeaconArea) {
    if let toVC = self.navigationController?.viewControllers[1] as? ServiceListTVC {
      toVC.locid = area.locid
      self.navigationController?.popToViewController(toVC, animated: true)
    } else {
      self.navigationController?.popViewControllerAnimated(true)
    }
    
  }

}
