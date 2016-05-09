//
//  PopOverVC.swift
//  SVIP
//
//  Created by AlexBang on 16/5/7.
//  Copyright © 2016年 zkjinshi. All rights reserved.
//

import UIKit
let items = ["消息","视频直播","室内导航","小费"]

protocol MenuDelegate {
  func selectItem(item:MenuItemType)
}
enum  MenuItemType:String {
  case Message
  case Video
  case Navigation
  case Switch
}

class PopOverVC: UIViewController {
  var delegate:MenuDelegate?
  @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
      

      tableView.tableFooterView = UIView()

      tableView.scrollEnabled = false

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
      
        // Dispose of any resources that can be recreated.
    }
  
  func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return items.count
  }
  
  func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return 50
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! PopOverCell
    cell.textLabel?.text = items[indexPath.row]
    return cell
  }
  
   func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    self.dismissViewControllerAnimated(true, completion: nil)
    switch indexPath.row {
    case 0://"消息"
      self.delegate?.selectItem(.Message)
    case 1://"视频直播"
      self.delegate?.selectItem(.Video)
    case 2://"室内导航"
      self.delegate?.selectItem(.Navigation)
    case 3://"门锁开关"
      self.delegate?.selectItem(.Switch)
    default:
      break
    }
   
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
