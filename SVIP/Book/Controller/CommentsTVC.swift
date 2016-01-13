//
//  CommentsTVC.swift
//  SVIP
//
//  Created by AlexBang on 16/1/3.
//  Copyright © 2016年 zkjinshi. All rights reserved.
//

import UIKit

class CommentsTVC: UITableViewController {
  var shopid:NSNumber!
  var orderPage = 1
  var commentArray : NSMutableArray = []
    override func viewDidLoad() {
        super.viewDidLoad()
      title = "评论"
      let image = UIImage(named: "ic_fanhui_orange")
      let item1 = UIBarButtonItem(image: image, style:.Done, target: self, action: "pop:")
      navigationController?.navigationBar.translucent = true
      self.navigationItem.leftBarButtonItem = item1
      
      let cellNib = UINib(nibName: CommentsCell.nibName(), bundle: nil)
      tableView.registerNib(cellNib, forCellReuseIdentifier: CommentsCell.reuseIdentifier())
      tableView.mj_footer = MJRefreshAutoNormalFooter(refreshingTarget: self, refreshingAction: "loadMoreData")
       tableView.tableFooterView = UIView()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
  
  func pop(sender:UIBarButtonItem) {
    navigationController?.popViewControllerAnimated(true)
  }
  
  override func loadView() {
    NSBundle.mainBundle().loadNibNamed("CommentsTVC", owner:self, options:nil)
  }
  
  override func viewWillAppear(animated: Bool) {
    
    super.viewWillAppear(animated)
    navigationController?.navigationBar.translucent = false
    orderPage = 1
    loadMoreData()
  }
  
  override func viewWillDisappear(animated: Bool) {
    super.viewWillDisappear(animated)
    navigationController?.navigationBar.translucent = true
    
  }
  
  func loadMoreData() {
    showHUDInView(view, withLoading: "")
    let page = String(orderPage)
    ZKJSJavaHTTPSessionManager.sharedInstance().getevaluationWithshopid(String(shopid), page: page, success: { (task: NSURLSessionDataTask!, responseObject: AnyObject!) -> Void in
      print(responseObject)
      let orderArray = responseObject as! NSArray
      if page == "1" {
        self.commentArray.removeAllObjects()
      }
      if orderArray.count != 0 {
        for orderInfo in orderArray {
          let order = CommentsModel(dic: orderInfo as! NSDictionary)
          self.commentArray.addObject(order)
        }
        self.hideHUD()
        self.tableView.reloadData()
        self.tableView.mj_footer.endRefreshing()
        self.orderPage++
      } else {
        self.hideHUD()
        self.tableView.mj_footer.endRefreshingWithNoMoreData()
      }
     
      }) { (task: NSURLSessionDataTask!, error: NSError!)-> Void in
        self.hideHUD()
        ZKJSTool.showMsg("数据异常")
    }
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
        return commentArray.count
    }
  
  override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return CommentsCell.height()
  }

  
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
      let cell = tableView.dequeueReusableCellWithIdentifier(CommentsCell.reuseIdentifier()) as! CommentsCell
      cell.selectionStyle = UITableViewCellSelectionStyle.None
      let comments = commentArray[indexPath.row] as! CommentsModel
      cell.setDate(comments)
      return cell

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
