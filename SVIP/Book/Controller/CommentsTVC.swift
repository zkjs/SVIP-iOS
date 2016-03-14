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
  var viewModel : CommentViewModel?
  
  override func viewDidLoad() {
      super.viewDidLoad()
    
    viewModel = CommentViewModel(shopid: String(shopid))
    viewModel?.load(0, completionHandler: {[weak self] (hasMore, error) -> Void in
      if let strongSelf = self {
        strongSelf.handlerResult(hasMore, error: error)
      }
    })
    
    title = "评论"
    let image = UIImage(named: "ic_fanhui_orange")
    let item1 = UIBarButtonItem(image: image, style:.Done, target: self, action: "pop:")
    navigationController?.navigationBar.translucent = true
    self.navigationItem.leftBarButtonItem = item1
    
    let cellNib = UINib(nibName: CommentsCell.nibName(), bundle: nil)
    tableView.registerNib(cellNib, forCellReuseIdentifier: CommentsCell.reuseIdentifier())
    tableView.mj_footer = MJRefreshAutoNormalFooter(refreshingTarget: self, refreshingAction: "loadMoreData")
     tableView.tableFooterView = UIView()
    
    
    if tableView.respondsToSelector(Selector("setSeparatorInset:")) {
      tableView.separatorInset = UIEdgeInsetsZero
    }
    if tableView.respondsToSelector(Selector("setLayoutMargins:")) {
      tableView.layoutMargins = UIEdgeInsetsZero
    }
    
  }
  
  override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
    
    if cell.respondsToSelector(Selector("setSeparatorInset:")) {
      cell.separatorInset = UIEdgeInsetsZero
    }
    if cell.respondsToSelector(Selector("setLayoutMargins:")) {
      cell.layoutMargins = UIEdgeInsetsZero
    }
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
  }
  
  override func viewWillDisappear(animated: Bool) {
    super.viewWillDisappear(animated)
    navigationController?.navigationBar.translucent = true
    
  }
  
  func loadMoreData() {
    viewModel?.next({[weak self] (hasMore, error) -> Void in
      if let strongSelf = self {
        strongSelf.handlerResult(hasMore, error: error)
      }
    })
  }
  
  func handlerResult(hasMore:Bool, error:NSError?) {
    if let _ = error {
      self.showHint("访问服务器失败")
    } else {
      if !hasMore {
        self.tableView.mj_footer.hidden = true
      }
      self.tableView.mj_footer.endRefreshing()
      self.tableView.reloadData()
    }
  }


  
  // MARK: - Table view data source

  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
      return 1
  }

  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      return viewModel?.data.count ?? 0
  }
  
  override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return CommentsCell.height()
  }

  
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
      let cell = tableView.dequeueReusableCellWithIdentifier(CommentsCell.reuseIdentifier()) as! CommentsCell
      if let comment = viewModel?.data[indexPath.row] {
        cell.configCell(comment)
      }
      return cell

    }
  
    
}
