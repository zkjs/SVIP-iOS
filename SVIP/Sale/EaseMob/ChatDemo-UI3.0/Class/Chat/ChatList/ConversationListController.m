//
//  ConversationListController.m
//  ChatDemo-UI3.0
//
//  Created by dhc on 15/6/25.
//  Copyright (c) 2015年 easemob.com. All rights reserved.
//

#import "ConversationListController.h"
#import "ChatViewController.h"
#import "Networkcfg.h"
#import "JSHStorage.h"

#import "EaseUI.h"

@interface ConversationListController ()<EaseConversationListViewControllerDelegate, EaseConversationListViewControllerDataSource,UISearchDisplayDelegate, UISearchBarDelegate>

@property (nonatomic, strong) UIView *networkStateView;

@end

@implementation ConversationListController

- (void)viewDidLoad {
  [super viewDidLoad];
  
  self.title = @"服务中心";
  
  [[EaseMob sharedInstance].chatManager loadAllConversationsFromDatabaseWithAppend2Chat:NO];
  
  self.showRefreshHeader = YES;
  self.delegate = self;
  self.dataSource = self;
  
  [self tableViewDidTriggerHeaderRefresh];
  
  self.tableView.frame = self.view.bounds;
  
  [self networkStateView];
  
  [self removeEmptyConversationsFromDB];
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
    NSString *userName = [JSHStorage baseInfo].username;
    if ([userName isEqualToString:latestMessage.ext[@"fromName"]]) {
      // 最后一条消息的发送者为自己
      NSString *shopName = latestMessage.ext[@"shopName"];
      NSString *toName = latestMessage.ext[@"toName"];
      model.title = [NSString stringWithFormat:@"%@-%@", shopName, toName];
    } else {
      // 最后一条消息的发送者为对方
      NSString *shopName = latestMessage.ext[@"shopName"];
      NSString *fromName = latestMessage.ext[@"fromName"];
      model.title = [NSString stringWithFormat:@"%@-%@", shopName, fromName];
    }
    NSString *url = [NSString stringWithFormat:@"uploads/users/%@.jpg", conversation.chatter];
    model.avatarURLPath = [kBaseURL stringByAppendingString:url];
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

#pragma mark - public

-(void)refreshDataSource
{
  [self tableViewDidTriggerHeaderRefresh];
  [self hideHUD];
}

- (void)isConnect:(BOOL)isConnect{
  if (!isConnect) {
    self.tableView.tableHeaderView = _networkStateView;
  }
  else{
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

@end
