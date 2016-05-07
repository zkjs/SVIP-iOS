//
//  RegionDetailTVC.swift
//  SVIP
//
//  Created by Qin Yejun on 5/7/16.
//  Copyright © 2016 zkjinshi. All rights reserved.
//

import UIKit

class RegionDetailTVC: UITableViewController {
  var region: Region!
  var comments: [RegionComment]!

  override func viewDidLoad() {
    super.viewDidLoad()

    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = false

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    
    title = "区域信息"
    
    // for test 新建一条评论
    let data = RegionComment.create() as! RegionComment
    data.userID = TokenPayload.sharedInstance.userID
    data.userName = AccountManager.sharedInstance().userName
    data.avatarUrl = AccountManager.sharedInstance().avatarURL
    data.locid = region.locid
    data.timestamp = NSDate()
    data.content = "测试评论 \(NSDate().timeIntervalSince1970)"
    data.save()
    
    let rightBtn = UIBarButtonItem(title: "评论", style: UIBarButtonItemStyle.Plain, target: self, action: "comment:")
    self.navigationItem.rightBarButtonItem = rightBtn
    
    // end of test
    
    
    
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(true)
    comments = RegionComment.commentsForRegion(region.locid)
    self.tableView.reloadData()
  }
  
  func comment(sender:UIBarButtonItem) {
    let storyBoard = UIStoryboard(name: "CommentVC", bundle: nil)
    let commentVC = storyBoard.instantiateViewControllerWithIdentifier("CommentVC") as! CommentVC
    self.navigationController?.pushViewController(commentVC, animated: true)
  }

  override func didReceiveMemoryWarning() {
      super.didReceiveMemoryWarning()
      // Dispose of any resources that can be recreated.
  }

  // MARK: - Table view data source

  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
      return 1
  }

  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       
      return comments.count + 1
   
  }

  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    if indexPath.row == 0 {
      let detailCell = tableView.dequeueReusableCellWithIdentifier("DetailCell", forIndexPath: indexPath) as! DetailCell
      detailCell.titleLabel.text = region.locdesc
      detailCell.selectionStyle = UITableViewCellSelectionStyle.None
      return detailCell
    } else {
      let commentCell = tableView.dequeueReusableCellWithIdentifier("CommentCell", forIndexPath: indexPath) as! CommentCell
      commentCell.configCell(comments[indexPath.row-1])
      commentCell.selectionStyle = UITableViewCellSelectionStyle.None
      return commentCell
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
