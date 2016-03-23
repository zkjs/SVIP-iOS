//
//  SearchTVC.swift
//  SVIP
//
//  Created by AlexBang on 15/11/18.
//  Copyright © 2015年 zkjinshi. All rights reserved.
//

import UIKit

class SearchTVC: UITableViewController {
        
    override func viewDidLoad() {
        super.viewDidLoad()
      let nibName = UINib(nibName: SearchCell.nibName(), bundle: nil)
      tableView.registerNib(nibName, forCellReuseIdentifier: SearchCell.reuseIdentifier())
      tableView.tableFooterView = UIView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 10
    }
  override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return SearchCell.height()
  }
  
  override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 44
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier(SearchCell.reuseIdentifier(), forIndexPath: indexPath) as! SearchCell
    cell.selectionStyle = UITableViewCellSelectionStyle.None
    cell.tag = indexPath.row
        return cell
    }
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    let vc = SearchResultVC(nibName:"SearchResultVC", bundle:nil)
    let cell = tableView.cellForRowAtIndexPath(indexPath) as! SearchCell
    vc.titleStr = cell.textLabel?.text
    navigationController?.pushViewController(vc, animated: true)
  }
  
  override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let searchHeadView = NSBundle.mainBundle().loadNibNamed("SearchHeaderView", owner: self, options: nil).first as! SearchHeaderView
    return searchHeadView
  }
  

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
}