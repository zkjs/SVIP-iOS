//
//  ConversationListController.m
//  ChatDemo-UI3.0
//
//  Created by dhc on 15/6/25.
//  Copyright (c) 2015年 easemob.com. All rights reserved.
//

#import "ConversationListController.h"

#import "ChatViewController.h"
#import "ZKJSHTTPSessionManager.h"
#import "SVIP-Swift.h"
#import "EaseUI.h"
#import "ContactSelectionViewController.h"
#import "EMSearchBar.h"
#import "EMSearchDisplayController.h"
#import "RealtimeSearchUtil.h"

@interface ConversationListController ()<EaseConversationListViewControllerDelegate, EaseConversationListViewControllerDataSource,UISearchDisplayDelegate, UISearchBarDelegate, EMChooseViewDelegate, XLPagerTabStripChildItem>

@property (nonatomic, strong) UIView *networkStateView;
@property (nonatomic, strong) EMSearchBar *searchBar;
@property (strong, nonatomic) EMSearchDisplayController *searchController;
@property (nonatomic, strong) UILabel *emptyLabel;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton *find;

@end

@implementation ConversationListController

- (void)viewDidLoad {
  [super viewDidLoad];
  
//  [self setupRightBarButton];
    
  [[EaseMob sharedInstance].chatManager loadAllConversationsFromDatabaseWithAppend2Chat:NO];
  
  self.showRefreshHeader = YES;
  self.delegate = self;
  self.dataSource = self;
  
  [self tableViewDidTriggerHeaderRefresh];
  
  [self.view addSubview:self.searchBar];
  self.tableView.frame = CGRectMake(0, self.searchBar.frame.size.height, self.view.frame.size.width, self.view.frame.size.height - self.searchBar.frame.size.height);
  
  [self networkStateView];
  
  [self searchController];
  
  [self removeEmptyConversationsFromDB];
  
  // 空数据提示
  CGRect screenSize = [UIScreen mainScreen].bounds;
  self.emptyLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 150.0, 30.0)];
  self.emptyLabel.textAlignment = NSTextAlignmentCenter;
  self.emptyLabel.font = [UIFont systemFontOfSize:20];
  self.emptyLabel.text = @"暂无消息";
  self.emptyLabel.textColor = [UIColor ZKJS_promptColor];
  self.emptyLabel.center = CGPointMake(screenSize.size.width / 2.0, 17);
  self.emptyLabel.hidden = NO;
  [self.tableView addSubview:self.emptyLabel];
  
    
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 300.0, 45.0)];
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.font = [UIFont systemFontOfSize:16];
    _titleLabel.text = @"在这里，您可以与专属客服进行沟通";
    _titleLabel.textColor = [UIColor ZKJS_promptColor];
    _titleLabel.center = CGPointMake(screenSize.size.width / 2.0, 200);
    _titleLabel.hidden = NO;
    [self.tableView addSubview:_titleLabel];
  
  _find = [UIButton buttonWithType:UIButtonTypeCustom];
  _find.frame = CGRectMake(0.0, 30, 160, 40.0);
  [_find
   setTitle:@"发现服务" forState:UIControlStateNormal];
//  [find addTarget:self action:@selector(findFriend) forControlEvents:UIControlEventTouchUpInside];
  _find.titleLabel.textAlignment = NSTextAlignmentCenter;
  _find.titleLabel.font = [UIFont systemFontOfSize:14];
  _find.backgroundColor = [UIColor ZKJS_mainColor];
  _find.center = CGPointMake(screenSize.size.width / 2.0, 250);
  _find.hidden = NO;
  [self.tableView addSubview:_find];
  

}



- (void)removeEmptyConversationsFromDB
{
  NSArray *conversations = [[EaseMob sharedInstance].chatManager conversations];
  NSMutableArray *needRemoveConversations;
  for (EMConversation *conversation in conversations) {
    if (!conversation.latestMessage || (conversation.conversationType == eConversationTypeChatRoom)) {
      if (!needRemoveConversations) {
        needRemoveConversations = [[NSMutableArray alloc] initWithCapacity:0];
      }
      
      [needRemoveConversations addObject:conversation.chatter];
    }
  }
  
  if (needRemoveConversations && needRemoveConversations.count > 0) {
    [[EaseMob sharedInstance].chatManager removeConversationsByChatters:needRemoveConversations
                                                         deleteMessages:YES
                                                            append2Chat:NO];
  }
}

#pragma mark - getter

- (UIView *)networkStateView
{
  if (_networkStateView == nil) {
    _networkStateView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 44)];
    _networkStateView.backgroundColor = [UIColor colorWithRed:255 / 255.0 green:199 / 255.0 blue:199 / 255.0 alpha:0.5];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, (_networkStateView.frame.size.height - 20) / 2, 20, 20)];
    imageView.image = [UIImage imageNamed:@"messageSendFail"];
    [_networkStateView addSubview:imageView];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(imageView.frame) + 5, 0, _networkStateView.frame.size.width - (CGRectGetMaxX(imageView.frame) + 15), _networkStateView.frame.size.height)];
    label.font = [UIFont systemFontOfSize:15.0];
    label.textColor = [UIColor grayColor];
    label.backgroundColor = [UIColor clearColor];
    label.text = NSLocalizedString(@"network.disconnection", @"Network disconnection");
    [_networkStateView addSubview:label];
  }
  
  return _networkStateView;
}

- (UISearchBar *)searchBar
{
  if (!_searchBar) {
    _searchBar = [[EMSearchBar alloc] initWithFrame: CGRectMake(0, 0, self.view.frame.size.width, 44)];
    _searchBar.delegate = self;
    _searchBar.placeholder = NSLocalizedString(@"search", @"Search");
    _searchBar.backgroundColor = [UIColor colorWithRed:0.747 green:0.756 blue:0.751 alpha:1.000];
  }
  
  return _searchBar;
}

- (EMSearchDisplayController *)searchController
{
  if (_searchController == nil) {
    _searchController = [[EMSearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self];
    _searchController.delegate = self;
    _searchController.searchResultsTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    _searchController.searchResultsTableView.tableFooterView = [[UIView alloc] init];
    
    __weak ConversationListController *weakSelf = self;
    [_searchController setCellForRowAtIndexPathCompletion:^UITableViewCell *(UITableView *tableView, NSIndexPath *indexPath) {
      NSString *CellIdentifier = [EaseConversationCell cellIdentifierWithModel:nil];
      EaseConversationCell *cell = (EaseConversationCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
      
      // Configure the cell...
      if (cell == nil) {
        cell = [[EaseConversationCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
      }
            
      id<IConversationModel> model = [weakSelf.searchController.resultsSource objectAtIndex:indexPath.row];
      cell.model = model;
      
      cell.detailLabel.text = [weakSelf conversationListViewController:weakSelf latestMessageTitleForConversationModel:model];
      cell.detailLabel.attributedText = [EaseEmotionEscape attStringFromTextForChatting:cell.detailLabel.text];
      cell.timeLabel.text = [weakSelf conversationListViewController:weakSelf latestMessageTimeForConversationModel:model];
      return cell;
    }];
    
    [_searchController setHeightForRowAtIndexPathCompletion:^CGFloat(UITableView *tableView, NSIndexPath *indexPath) {
      return [EaseConversationCell cellHeightWithModel:nil];
    }];
    
    [_searchController setDidSelectRowAtIndexPathCompletion:^(UITableView *tableView, NSIndexPath *indexPath) {
      [tableView deselectRowAtIndexPath:indexPath animated:YES];
      [weakSelf.searchController.searchBar endEditing:YES];
      id<IConversationModel> model = [weakSelf.searchController.resultsSource objectAtIndex:indexPath.row];
      EMConversation *conversation = model.conversation;
      ChatViewController *chatController;
      chatController = [[ChatViewController alloc] initWithConversationChatter:conversation.chatter conversationType:conversation.conversationType];
      chatController.hidesBottomBarWhenPushed = YES;
      [weakSelf.searchController setActive:NO];
      [weakSelf.navigationController pushViewController:chatController animated:YES];
    }];
  }
  
  return _searchController;
}

#pragma mark - EaseConversationListViewControllerDelegate

- (void)conversationListViewController:(EaseConversationListViewController *)conversationListViewController
            didSelectConversationModel:(id<IConversationModel>)conversationModel
{
  if (conversationModel) {
    EMConversation *conversation = conversationModel.conversation;
    if (conversation) {
      ChatViewController *chatController = [[ChatViewController alloc] initWithConversationChatter:conversation.chatter conversationType:conversation.conversationType];
      chatController.title = conversation.ext[@"shopName"];
      chatController.hidesBottomBarWhenPushed = YES;
      chatController.conversation.ext = conversation.ext;
      [self.navigationController pushViewController:chatController animated:YES];
    }
  }
}

#pragma mark - EaseConversationListViewControllerDataSource

- (id<IConversationModel>)conversationListViewController:(EaseConversationListViewController *)conversationListViewController
                                    modelForConversation:(EMConversation *)conversation
{
  EaseConversationModel *model = [[EaseConversationModel alloc] initWithConversation:conversation];
  if (model.conversation.conversationType == eConversationTypeChat) {
    EMMessage *latestMessage = conversation.latestMessage;
    NSString *userName = [AccountManager sharedInstance].userName;
    if ([userName isEqualToString:latestMessage.ext[@"fromName"]]) {
      // 最后一条消息的发送者为自己
      NSString *shopName = latestMessage.ext[@"shopName"];
      NSString *toName = latestMessage.ext[@"toName"];
      if ([shopName isEqualToString:@""]) {
        model.title = toName;
      } else {
        model.title = [NSString stringWithFormat:@"%@-%@", shopName, toName];
      }
    } else {
      // 最后一条消息的发送者为对方
      NSString *shopName = latestMessage.ext[@"shopName"];
      NSString *fromName = latestMessage.ext[@"fromName"];
      if ([shopName isEqualToString:@""]) {
        model.title = fromName;
      } else {
        model.title = [NSString stringWithFormat:@"%@-%@", shopName, fromName];
      }
    }
    if ([conversation.chatter isEqualToString:@"app_customer_service"]) {
      model.avatarImage = [UIImage imageNamed:@"ic_home_nor"];
    } else {
      NSString *url = [NSString stringWithFormat:@"/uploads/users/%@.jpg", conversation.chatter];
      model.avatarURLPath = [kImageURL stringByAppendingString:url];
    }
  } else if (model.conversation.conversationType == eConversationTypeGroupChat) {
    if (![conversation.ext objectForKey:@"groupSubject"] || ![conversation.ext objectForKey:@"isPublic"]) {
      NSArray *groupArray = [[EaseMob sharedInstance].chatManager groupList];
      for (EMGroup *group in groupArray) {
        if ([group.groupId isEqualToString:conversation.chatter]) {
          model.title = group.groupSubject;
          model.avatarImage = [UIImage imageNamed:@"img_hotel_zhanwei"];
          
          NSMutableDictionary *ext = [NSMutableDictionary dictionaryWithDictionary:conversation.ext];
          [ext setObject:group.groupSubject forKey:@"groupSubject"];
          [ext setObject:[NSNumber numberWithBool:group.isPublic] forKey:@"isPublic"];
          conversation.ext = ext;
          break;
        }
      }
    } else {
      NSArray *groupArray = [[EaseMob sharedInstance].chatManager groupList];
      for (EMGroup *group in groupArray) {
        if ([group.groupId isEqualToString:conversation.chatter]) {
          NSMutableDictionary *ext = [NSMutableDictionary dictionaryWithDictionary:conversation.ext];
          [ext setObject:group.groupSubject forKey:@"groupSubject"];
          [ext setObject:[NSNumber numberWithBool:group.isPublic] forKey:@"isPublic"];
          NSString *groupSubject = [ext objectForKey:@"groupSubject"];
          NSString *conversationSubject = [conversation.ext objectForKey:@"groupSubject"];
          if (groupSubject && conversationSubject && ![groupSubject isEqualToString:conversationSubject]) {
            conversation.ext = ext;
          }
          break;
        }
      }
      model.title = [conversation.ext objectForKey:@"groupSubject"];
      model.avatarImage = [UIImage imageNamed:@"img_hotel_zhanwei"];
    }
  }
  return model;
}

- (NSString *)conversationListViewController:(EaseConversationListViewController *)conversationListViewController
      latestMessageTitleForConversationModel:(id<IConversationModel>)conversationModel
{
  NSString *latestMessageTitle = @"";
  EMMessage *lastMessage = [conversationModel.conversation latestMessage];
  if (lastMessage) {
    id<IEMMessageBody> messageBody = lastMessage.messageBodies.lastObject;
    switch (messageBody.messageBodyType) {
      case eMessageBodyType_Image:{
        latestMessageTitle = NSLocalizedString(@"message.image1", @"[image]");
      } break;
      case eMessageBodyType_Text:{
        if ([[messageBody.message.ext objectForKey:@"extType"] integerValue] == eTextTxtCard) {
          // 订单卡片。
          latestMessageTitle = NSLocalizedString(@"message.card1", @"[card]");
        } else {
          NSString *didReceiveText = [EaseConvertToCommonEmoticonsHelper
                                      convertToSystemEmoticons:((EMTextMessageBody *)messageBody).text];
          latestMessageTitle = didReceiveText;
        }
      } break;
      case eMessageBodyType_Voice:{
        latestMessageTitle = NSLocalizedString(@"message.voice1", @"[voice]");
      } break;
      case eMessageBodyType_Location: {
        latestMessageTitle = NSLocalizedString(@"message.location1", @"[location]");
      } break;
      case eMessageBodyType_Video: {
        latestMessageTitle = NSLocalizedString(@"message.video1", @"[video]");
      } break;
      case eMessageBodyType_File: {
        latestMessageTitle = NSLocalizedString(@"message.file1", @"[file]");
      } break;
      default: {
      } break;
    }
  }
  
  return latestMessageTitle;
}

- (NSString *)conversationListViewController:(EaseConversationListViewController *)conversationListViewController
       latestMessageTimeForConversationModel:(id<IConversationModel>)conversationModel
{
  NSString *latestMessageTime = @"";
  EMMessage *lastMessage = [conversationModel.conversation latestMessage];;
  if (lastMessage) {
    latestMessageTime = [NSDate formattedTimeFromTimeInterval:lastMessage.timestamp];
  }
  
  return latestMessageTime;
}

- (void)tableViewDidFinishTriggerHeader:(BOOL)isHeader reload:(BOOL)reload
{
  __weak EaseRefreshTableViewController *weakSelf = self;
  dispatch_async(dispatch_get_main_queue(), ^{
    if (reload) {
      [weakSelf.tableView reloadData];
    }
    
    if (isHeader) {
      [weakSelf.tableView.mj_header endRefreshing];
    }
    else{
      [weakSelf.tableView.mj_footer endRefreshing];
    }
  });
  
  if (self.dataArray.count > 0) {
    self.emptyLabel.hidden = YES;
    self.titleLabel.hidden = YES;
    self.find.hidden = YES;
  } else {
    self.emptyLabel.hidden = NO;
    self.titleLabel.hidden = NO;
    self.find.hidden = NO;
  }
}

#pragma mark - UISearchBarDelegate

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
  [searchBar setShowsCancelButton:YES animated:YES];
  
  return YES;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
  __weak typeof(self) weakSelf = self;
  [[RealtimeSearchUtil currentUtil] realtimeSearchWithSource:self.dataArray searchText:(NSString *)searchText collationStringSelector:@selector(title) resultBlock:^(NSArray *results) {
    if (results) {
      dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf.searchController.resultsSource removeAllObjects];
        [weakSelf.searchController.resultsSource addObjectsFromArray:results];
        [weakSelf.searchController.searchResultsTableView reloadData];
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

#pragma mark - public

-(void)refreshDataSource
{
  [self tableViewDidTriggerHeaderRefresh];
  [self hideHUD];
}

- (void)isConnect:(BOOL)isConnect{
  if (!isConnect) {
    self.tableView.tableHeaderView = _networkStateView;
  } else {
    self.tableView.tableHeaderView = nil;
  }
}

- (void)networkChanged:(EMConnectionState)connectionState
{
  if (connectionState == eEMConnectionDisconnected) {
    self.tableView.tableHeaderView = _networkStateView;
  }
  else{
    self.tableView.tableHeaderView = nil;
  }
}

- (void)willReceiveOfflineMessages{
  NSLog(NSLocalizedString(@"message.beginReceiveOffine", @"Begin to receive offline messages"));
}

- (void)didReceiveOfflineMessages:(NSArray *)offlineMessages
{
  [self refreshDataSource];
}

- (void)didFinishedReceiveOfflineMessages{
  NSLog(NSLocalizedString(@"message.endReceiveOffine", @"End to receive offline messages"));
}

#pragma mark - XLPagerTabStripChildItem Delegate 

-(NSString *)titleForPagerTabStripViewController:(XLPagerTabStripViewController *)pagerTabStripViewController {
  return @"聊天";
}

-(UIColor *)colorForPagerTabStripViewController:(XLPagerTabStripViewController *)pagerTabStripViewController {
  return [UIColor ZKJS_mainColor];
}

@end
