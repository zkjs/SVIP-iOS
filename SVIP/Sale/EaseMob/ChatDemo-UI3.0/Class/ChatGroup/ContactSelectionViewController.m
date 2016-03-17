/************************************************************
 *  * EaseMob CONFIDENTIAL
 * __________________
 * Copyright (C) 2013-2014 EaseMob Technologies. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of EaseMob Technologies.
 * Dissemination of this information or reproduction of this material
 * is strictly forbidden unless prior written permission is obtained
 * from EaseMob Technologies.
 */

#import "ContactSelectionViewController.h"

#import "EMSearchBar.h"
#import "EMRemarkImageView.h"
#import "EMSearchDisplayController.h"
#import "RealtimeSearchUtil.h"
#import "EaseUI.h"
//#import "SuperService-Swift.h"

@interface ContactSelectionViewController ()<UISearchBarDelegate, UISearchDisplayDelegate>

@property (strong, nonatomic) NSMutableArray *contactsSource;
@property (strong, nonatomic) NSMutableArray *selectedContacts;
@property (strong, nonatomic) NSMutableArray *blockSelectedUsernames;

@property (strong, nonatomic) EMSearchBar *searchBar;
@property (strong, nonatomic) EMSearchDisplayController *searchController;

@property (strong, nonatomic) UIView *footerView;
@property (strong, nonatomic) UIScrollView *footerScrollView;
@property (strong, nonatomic) UIButton *doneButton;

@end

@implementation ContactSelectionViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    // Custom initialization
    _contactsSource = [NSMutableArray array];
    _selectedContacts = [NSMutableArray array];
    
    [self setObjectComparisonStringBlock:^NSString *(id object) {
//      EMBuddy *buddy = (EMBuddy *)object;
//      return buddy.username;
      EaseUserModel *model = (EaseUserModel *)object;
      return model.nickname;
    }];
    
    [self setComparisonObjectSelector:^NSComparisonResult(id object1, id object2) {
//      EMBuddy *buddy1 = (EMBuddy *)object1;
//      EMBuddy *buddy2 = (EMBuddy *)object2;
//      
//      return [buddy1.username caseInsensitiveCompare: buddy2.username];
      EaseUserModel *model1 = (EaseUserModel *)object1;
      EaseUserModel *model2 = (EaseUserModel *)object2;
      
      return [model1.nickname caseInsensitiveCompare:model2.nickname];
    }];
  }
  return self;
}

- (instancetype)initWithBlockSelectedUsernames:(NSArray *)blockUsernames
{
  self = [self initWithNibName:nil bundle:nil];
  if (self) {
    _blockSelectedUsernames = [NSMutableArray array];
    [_blockSelectedUsernames addObjectsFromArray:blockUsernames];
  }
  
  return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];

  self.title = NSLocalizedString(@"title.chooseContact", @"select the contact");
  self.navigationItem.rightBarButtonItem = nil;
  
  [self.view addSubview:self.searchBar];
  [self.view addSubview:self.footerView];
  self.tableView.editing = YES;
  self.tableView.frame = CGRectMake(0, self.searchBar.frame.size.height, self.view.frame.size.width, self.view.frame.size.height - self.searchBar.frame.size.height - self.footerView.frame.size.height);
  [self searchController];
}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

#pragma mark - getter

- (UISearchBar *)searchBar
{
  if (_searchBar == nil) {
    _searchBar = [[EMSearchBar alloc] initWithFrame: CGRectMake(0, 0, self.view.frame.size.width, 44)];
    _searchBar.delegate = self;
    _searchBar.placeholder = NSLocalizedString(@"search", @"Search");
    _searchBar.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin;
    _searchBar.backgroundColor = [UIColor colorWithRed:0.747 green:0.756 blue:0.751 alpha:1.000];
  }
  
  return _searchBar;
}

- (EMSearchDisplayController *)searchController
{
  if (_searchController == nil) {
    _searchController = [[EMSearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self];
    _searchController.editingStyle = UITableViewCellEditingStyleInsert | UITableViewCellEditingStyleDelete;
    _searchController.delegate = self;
    _searchController.searchResultsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    __weak ContactSelectionViewController *weakSelf = self;
    [_searchController setCellForRowAtIndexPathCompletion:^UITableViewCell *(UITableView *tableView, NSIndexPath *indexPath) {
      static NSString *CellIdentifier = @"ContactListCell";
      BaseTableViewCell *cell = (BaseTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
      
      // Configure the cell...
      if (cell == nil) {
        cell = [[BaseTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
      }
      
      EaseUserModel *model = [weakSelf.searchController.resultsSource objectAtIndex:indexPath.row];
      cell.imageView.image = [UIImage imageNamed:@"chatListCellHead.png"];
      cell.textLabel.text = model.nickname;
      cell.username = model.buddy.username;
      
      return cell;
    }];
    
    [_searchController setCanEditRowAtIndexPath:^BOOL(UITableView *tableView, NSIndexPath *indexPath) {
      if ([weakSelf.blockSelectedUsernames count] > 0) {
        EaseUserModel *model = [weakSelf.searchController.resultsSource objectAtIndex:indexPath.row];
        return ![weakSelf isBlockUsername:model.buddy.username];
      }
      
      return YES;
    }];
    
    [_searchController setHeightForRowAtIndexPathCompletion:^CGFloat(UITableView *tableView, NSIndexPath *indexPath) {
      return 50;
    }];
    
    [_searchController setDidSelectRowAtIndexPathCompletion:^(UITableView *tableView, NSIndexPath *indexPath) {
      EaseUserModel *model = [weakSelf.searchController.resultsSource objectAtIndex:indexPath.row];
      if (![weakSelf.selectedContacts containsObject:model])
        {
        NSInteger section = [weakSelf sectionForString:model.nickname];
        if (section >= 0) {
          NSMutableArray *tmpArray = [weakSelf.dataSource objectAtIndex:section];
          NSInteger row = [tmpArray indexOfObject:model];
          [weakSelf.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:section] animated:NO scrollPosition:UITableViewScrollPositionNone];
        }
        
        [weakSelf.selectedContacts addObject:model];
        [weakSelf reloadFooterView];
        }
    }];
    
    [_searchController setDidDeselectRowAtIndexPathCompletion:^(UITableView *tableView, NSIndexPath *indexPath) {
      [tableView deselectRowAtIndexPath:indexPath animated:YES];
      
      EaseUserModel *model = [weakSelf.searchController.resultsSource objectAtIndex:indexPath.row];
      if ([weakSelf.selectedContacts containsObject:model]) {
        NSInteger section = [weakSelf sectionForString:model.nickname];
        if (section >= 0) {
          NSMutableArray *tmpArray = [weakSelf.dataSource objectAtIndex:section];
          NSInteger row = [tmpArray indexOfObject:model];
          [weakSelf.tableView deselectRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:section] animated:NO];
        }
        
        [weakSelf.selectedContacts removeObject:model];
        [weakSelf reloadFooterView];
      }
    }];
  }
  
  return _searchController;
}

- (UIView *)footerView
{
  if (_footerView == nil) {
    _footerView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 50, self.view.frame.size.width, 50)];
    _footerView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin;
    _footerView.backgroundColor = [UIColor colorWithRed:207 / 255.0 green:210 /255.0 blue:213 / 255.0 alpha:1.0];
    
    _footerScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(10, 0, _footerView.frame.size.width - 30 - 70, _footerView.frame.size.height - 5)];
    _footerScrollView.backgroundColor = [UIColor clearColor];
    [_footerView addSubview:_footerScrollView];
    
    _doneButton = [[UIButton alloc] initWithFrame:CGRectMake(_footerView.frame.size.width - 80, 8, 70, _footerView.frame.size.height - 16)];
    _doneButton.layer.masksToBounds = YES;
    _doneButton.layer.cornerRadius = 3;
    [_doneButton setBackgroundColor:[UIColor blackColor]];
    [_doneButton setTitle:NSLocalizedString(@"accept", @"Accept") forState:UIControlStateNormal];
    [_doneButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _doneButton.titleLabel.font = [UIFont systemFontOfSize:14.0];
    [_doneButton setTitle:NSLocalizedString(@"ok", @"OK") forState:UIControlStateNormal];
    [_doneButton addTarget:self action:@selector(doneAction:) forControlEvents:UIControlEventTouchUpInside];
    [_footerView addSubview:_doneButton];
  }
  
  return _footerView;
}

#pragma mark - Table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  static NSString *CellIdentifier = @"ContactListCell";
  BaseTableViewCell *cell = (BaseTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
  
  // Configure the cell...
  if (cell == nil) {
    cell = [[BaseTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
  }
  
//  EMBuddy *buddy = [[_dataSource objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
//  cell.imageView.image = [UIImage imageNamed:@"chatListCellHead.png"];
//  cell.textLabel.text = buddy.username;
//  cell.username = buddy.username;
  
  EaseUserModel *model = [[_dataSource objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
//  NSURL *url = [[NSURL alloc] initWithString:model.avatarURLPath];
//  [cell.imageView sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"ic_home_nor"]];
//  cell.textLabel.text = model.nickname;
  cell.username = model.buddy.username;
  cell.nickname = model.nickname;
  
  return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
  // Return NO if you do not want the specified item to be editable.
  if ([_blockSelectedUsernames count] > 0) {
//    EaseUser *buddy = [[_dataSource objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
//    return ![self isBlockUsername:buddy.username];
    EaseUserModel *model = [[_dataSource objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    return ![self isBlockUsername:model.buddy.username];
  }
  
  return YES;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  id object = [[_dataSource objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
  if (![self.selectedContacts containsObject:object])
    {
    [self.selectedContacts addObject:object];
    
    [self reloadFooterView];
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
//  EMBuddy *buddy = [[_dataSource objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
//  if ([self.selectedContacts containsObject:buddy]) {
//    [self.selectedContacts removeObject:buddy];
//    
//    [self reloadFooterView];
//  }
  
  EaseUserModel *model = [[_dataSource objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
  if ([self.selectedContacts containsObject:model]) {
    [self.selectedContacts removeObject:model];
    
    [self reloadFooterView];
  }
}

#pragma mark - UISearchBarDelegate

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
  [searchBar setShowsCancelButton:YES animated:YES];
//  [self.searchBar setCancelButtonTitle:NSLocalizedString(@"ok", @"OK")];
  
  return YES;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
  __weak typeof(self) weakSelf = self;
  [[RealtimeSearchUtil currentUtil] realtimeSearchWithSource:self.contactsSource searchText:searchText collationStringSelector:@selector(nickname) resultBlock:^(NSArray *results) {
    if (results) {
      dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf.searchController.resultsSource removeAllObjects];
        [weakSelf.searchController.resultsSource addObjectsFromArray:results];
        [weakSelf.searchController.searchResultsTableView reloadData];
        
        for (EaseUserModel *model in results) {
          if ([weakSelf.selectedContacts containsObject:model])
            {
            NSInteger row = [results indexOfObject:model];
            [weakSelf.searchController.searchResultsTableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
            }
        }
      });
    }
  }];
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar
{
  return YES;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
  [searchBar resignFirstResponder];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
  searchBar.text = @"";
  [[RealtimeSearchUtil currentUtil] realtimeSearchStop];
  [searchBar resignFirstResponder];
  [searchBar setShowsCancelButton:NO animated:YES];
}

#pragma mark - UISearchDisplayDelegate

- (void)searchDisplayController:(UISearchDisplayController *)controller willShowSearchResultsTableView:(UITableView *)tableView
{
  tableView.editing = YES;
}

#pragma mark - private

- (BOOL)isBlockUsername:(NSString *)username
{
  if (username && [username length] > 0) {
    if ([_blockSelectedUsernames count] > 0) {
      for (NSString *tmpName in _blockSelectedUsernames) {
        if ([username isEqualToString:tmpName]) {
          return YES;
        }
      }
    }
  }
  
  return NO;
}

- (void)reloadFooterView
{
  [self.footerScrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
  
  CGFloat imageSize = self.footerScrollView.frame.size.height;
  NSInteger count = [self.selectedContacts count];
  self.footerScrollView.contentSize = CGSizeMake(imageSize * count, imageSize);
  for (int i = 0; i < count; i++) {
//    EMBuddy *buddy = [self.selectedContacts objectAtIndex:i];
//    EMRemarkImageView *remarkView = [[EMRemarkImageView alloc] initWithFrame:CGRectMake(i * imageSize, 0, imageSize, imageSize)];
//    remarkView.image = [UIImage imageNamed:@"chatListCellHead.png"];
//    remarkView.remark = buddy.username;
    EaseUserModel *model = [self.selectedContacts objectAtIndex:i];
    EMRemarkImageView *remarkView = [[EMRemarkImageView alloc] initWithFrame:CGRectMake(i * imageSize, 0, imageSize, imageSize)];
    NSURL *url = [[NSURL alloc] initWithString:model.avatarURLPath];
    [remarkView.imageView sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"ic_home_nor"]];
    remarkView.remark = model.nickname;
    [self.footerScrollView addSubview:remarkView];
  }
  
  if ([self.selectedContacts count] == 0) {
    [_doneButton setTitle:NSLocalizedString(@"ok", @"OK") forState:UIControlStateNormal];
  }
  else{
    [_doneButton setTitle:[NSString stringWithFormat:NSLocalizedString(@"doneWithCount", @"Done(%i)"), [self.selectedContacts count]] forState:UIControlStateNormal];
  }
}

#pragma mark - public

- (void)setupBlockSelectedUserNames {
  if ([_blockSelectedUsernames count] > 0) {
    for (NSString *username in _blockSelectedUsernames) {
      NSInteger section = [self sectionForString:username];
      NSMutableArray *tmpArray = [_dataSource objectAtIndex:section];
      if (tmpArray && [tmpArray count] > 0) {
        for (int i = 0; i < [tmpArray count]; i++) {
          EMBuddy *buddy = [tmpArray objectAtIndex:i];
          if ([buddy.username isEqualToString:username]) {
            [self.selectedContacts addObject:buddy];
            [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:section] animated:NO scrollPosition:UITableViewScrollPositionNone];
            
            break;
          }
        }
      }
    }
    
    if ([_selectedContacts count] > 0) {
      [self reloadFooterView];
    }
  }
}

- (void)loadDataSource
{
  [self showHudInView:self.view hint:NSLocalizedString(@"loadData", @"Load data...")];
  [_dataSource removeAllObjects];
  [_contactsSource removeAllObjects];
  
//  __weak typeof(self) weakSelf = self;
//  [[ZKJSHTTPSessionManager sharedInstance] getTeamListWithSuccess:^(NSURLSessionDataTask *task, id responseObject) {
//    for (NSDictionary *sales in responseObject) {
//      NSMutableString *userName = [NSMutableString string];
//      // 如果salesid是全数字时，服务器返回的是number类型的值
//      if ([sales[@"salesid"] isKindOfClass:[NSNumber class]]) {
//        userName = [[sales[@"salesid"] stringValue] mutableCopy];
//      } else {
//        userName = sales[@"salesid"];
//      }
//      EMBuddy *buddy = [EMBuddy buddyWithUsername:[userName copy]];
//      id<IUserModel> model = nil;
//      model = [[EaseUserModel alloc] initWithBuddy:buddy];
//      model.nickname = sales[@"name"];
//      NSString *url = [NSString stringWithFormat:@"uploads/users/%@.jpg", model.buddy.username];
//      NSString *domain = [ZKJSHTTPSessionManager sharedInstance].domain;
//      model.avatarURLPath = [domain stringByAppendingString:url];
//      [weakSelf.contactsSource addObject:model];
//    }
//    
//    [_dataSource addObjectsFromArray:[weakSelf sortRecords:weakSelf.contactsSource]];
//    
//    [weakSelf hideHud];
//    [weakSelf.tableView reloadData];
//    
//    [weakSelf blockSelectedUsernames];
//  } failure:^(NSURLSessionDataTask *task, NSError *error) {
//    
//  }];
}

- (void)doneAction:(id)sender
{
  BOOL isPop = YES;
  if (_delegate && [_delegate respondsToSelector:@selector(viewController:didFinishSelectedSources:)]) {
    if ([_blockSelectedUsernames count] == 0) {
      isPop = [_delegate viewController:self didFinishSelectedSources:self.selectedContacts];
    }
    else{
      NSMutableArray *resultArray = [NSMutableArray array];
      for (EaseUserModel *model in self.selectedContacts) {
        if(![self isBlockUsername:model.buddy.username])
          {
          [resultArray addObject:model];
          }
      }
      isPop = [_delegate viewController:self didFinishSelectedSources:resultArray];
    }
  }
  
  if (isPop) {
    [self.navigationController popViewControllerAnimated:NO];
  }
}

@end
