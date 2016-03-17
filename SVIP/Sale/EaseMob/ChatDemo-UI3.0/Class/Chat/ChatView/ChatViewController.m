//
//  ChatViewController.m
//  ChatDemo-UI3.0
//
//  Created by dhc on 15/6/26.
//  Copyright (c) 2015年 easemob.com. All rights reserved.
//

#import "ChatViewController.h"
#import "CustomMessageCell.h"
//#import "ContactListSelectViewController.h"
#import "ZKJSHTTPSessionManager.h"
#import "MJRefresh.h"
#import "SVIP-Swift.h"
#import "EaseUI.h"
#import "ContactSelectionViewController.h"
#import "ChatGroupDetailViewController.h"

@interface ChatViewController ()<UIAlertViewDelegate, EaseMessageViewControllerDelegate, EaseMessageViewControllerDataSource, HotelOrderDetailTVCDelegate>
{
  UIMenuItem *_copyMenuItem;
  UIMenuItem *_deleteMenuItem;
  UIMenuItem *_transpondMenuItem;
}

@property (nonatomic) BOOL isPlayingAudio;

@end

@implementation ChatViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  self.showRefreshHeader = YES;
  self.delegate = self;
  self.dataSource = self;
  
  [[EaseBaseMessageCell appearance] setSendBubbleBackgroundImage:[[UIImage imageNamed:@"chat_sender_bg"] stretchableImageWithLeftCapWidth:5 topCapHeight:35]];
  [[EaseBaseMessageCell appearance] setRecvBubbleBackgroundImage:[[UIImage imageNamed:@"chat_receiver_bg"] stretchableImageWithLeftCapWidth:35 topCapHeight:35]];
  
  [[EaseBaseMessageCell appearance] setSendMessageVoiceAnimationImages:@[
                                                                         [UIImage imageNamed:@"chat_sender_audio_playing_full"],
                                                                         [UIImage imageNamed:@"chat_sender_audio_playing_000"],
                                                                         [UIImage imageNamed:@"chat_sender_audio_playing_001"],
                                                                         [UIImage imageNamed:@"chat_sender_audio_playing_002"],
                                                                         [UIImage imageNamed:@"chat_sender_audio_playing_003"]]];
  [[EaseBaseMessageCell appearance] setRecvMessageVoiceAnimationImages:@[
                                                                         [UIImage imageNamed:@"chat_receiver_audio_playing_full"],
                                                                         [UIImage imageNamed:@"chat_receiver_audio_playing000"],
                                                                         [UIImage imageNamed:@"chat_receiver_audio_playing001"],
                                                                         [UIImage imageNamed:@"chat_receiver_audio_playing002"],
                                                                         [UIImage imageNamed:@"chat_receiver_audio_playing003"]]];
  
  [[EaseBaseMessageCell appearance] setAvatarSize:40.f];
  [[EaseBaseMessageCell appearance] setAvatarCornerRadius:20.f];
  
  [[EaseChatBarMoreView appearance] setMoreViewBackgroundColor:[UIColor colorWithRed:240 / 255.0 green:242 / 255.0 blue:247 / 255.0 alpha:1.0]];
  
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteAllMessages:) name:KNOTIFICATIONNAME_DELETEALLMESSAGE object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(exitGroup) name:@"ExitGroup" object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(insertCallMessage:) name:@"insertCallMessage" object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleCallNotification:) name:KNOTIFICATION_CALL object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleCallNotification:) name:KNOTIFICATION_CALL_CLOSE object:nil];
  
  //通过会话管理者获取已收发消息
  [self tableViewDidTriggerHeaderRefresh];
  
  EaseEmotionManager *manager= [[EaseEmotionManager alloc] initWithType:EMEmotionDefault emotionRow:3 emotionCol:7 emotions:[EaseEmoji allEmoji]];
  [self.faceView setEmotionManagers:@[manager]];
  
  UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
  [backButton setImage:[UIImage imageNamed:@"ic_fanhui_orange"] forState:UIControlStateNormal];
  [backButton addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
  UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
  [self.navigationItem setLeftBarButtonItem:backItem];
}

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  
  if (self.conversation.conversationType == eConversationTypeGroupChat) {
    self.title = @"群聊";
  } else {
    self.title = [self getChatterName];
  }
}

-(void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
  if (alertView.cancelButtonIndex != buttonIndex) {
    self.messageTimeIntervalTag = -1;
    [self.conversation removeAllMessages];
    [self.dataArray removeAllObjects];
    [self.messsagesSource removeAllObjects];
    
    [self.tableView reloadData];
  }
}

#pragma mark - EaseMessageViewControllerDelegate

- (BOOL)messageViewController:(EaseMessageViewController *)viewController
   canLongPressRowAtIndexPath:(NSIndexPath *)indexPath
{
  return YES;
}

- (BOOL)messageViewController:(EaseMessageViewController *)viewController
   didLongPressRowAtIndexPath:(NSIndexPath *)indexPath
{
  id object = [self.dataArray objectAtIndex:indexPath.row];
  if (![object isKindOfClass:[NSString class]]) {
    EaseMessageCell *cell = (EaseMessageCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    [cell becomeFirstResponder];
    self.menuIndexPath = indexPath;
    [self _showMenuViewController:cell.bubbleView andIndexPath:indexPath messageType:cell.model.bodyType];
  }
  return YES;
}

- (UITableViewCell *)messageViewController:(UITableView *)tableView cellForMessageModel:(id<IMessageModel>)model
{
  if (model.bodyType == eMessageBodyType_Text) {
    NSString *CellIdentifier = [CustomMessageCell cellIdentifierWithModel:model];
    //发送cell
    CustomMessageCell *sendCell = (CustomMessageCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    if (sendCell == nil) {
      sendCell = [[CustomMessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier model:model];
      sendCell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    sendCell.model = model;
    return sendCell;
  }
  return nil;
}

- (CGFloat)messageViewController:(EaseMessageViewController *)viewController
           heightForMessageModel:(id<IMessageModel>)messageModel
                   withCellWidth:(CGFloat)cellWidth
{
  if (messageModel.bodyType == eMessageBodyType_Text) {
    return [CustomMessageCell cellHeightWithModel:messageModel];
  }
  return 0.f;
}

- (BOOL)messageViewController:(EaseMessageViewController *)viewController didSelectMessageModel:(id<IMessageModel>)messageModel
{
  BOOL flag = NO;
  if ([[messageModel.message.ext objectForKey:@"extType"] integerValue] == eTextTxtCard) {
    OrderDetailModel *order = [[OrderDetailModel alloc] initWithJson: [messageModel text]];
    NSLog(@"%@", order);
    NSString *type = [[order.orderno substringToIndex:1] uppercaseString];
    if ([type isEqualToString:@"H"]) {
      UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"HotelOrderDetailTVC" bundle:nil];
      HotelOrderDetailTVC *vc = [storyboard instantiateViewControllerWithIdentifier:@"HotelOrderDetailTVC"];
      vc.reservation_no = order.orderno;
      vc.delegate = self;
      [self.navigationController pushViewController:vc animated:YES];
    } else if ([type isEqualToString:@"O"]) {
      UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"LeisureOrderDetailTVC" bundle:nil];
      LeisureOrderDetailTVC *vc = [storyboard instantiateViewControllerWithIdentifier:@"LeisureOrderDetailTVC"];
      vc.reservation_no = order.orderno;
      [self.navigationController pushViewController:vc animated:YES];
    } else if ([type isEqualToString:@"K"]) {
      UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"KTVOrderDetailTVC" bundle:nil];
      KTVOrderDetailTVC *vc = [storyboard instantiateViewControllerWithIdentifier:@"KTVOrderDetailTVC"];
      vc.reservation_no = order.orderno;
      [self.navigationController pushViewController:vc animated:YES];
    }
    flag = YES;
  }
  return flag;
}

- (void)messageViewController:(EaseMessageViewController *)viewController
  didSelectAvatarMessageModel:(id<IMessageModel>)messageModel
{
  //  if ([messageModel isSender] == NO) {
  //    SalesDetailVC *vc = [SalesDetailVC new];
  //    vc.salesid = salesid;
  //    [self.navigationController pushViewController:vc animated:YES];
  //  }
  
  //    UserProfileViewController *userprofile = [[UserProfileViewController alloc] initWithUsername:messageModel.nickname];
  //    [self.navigationController pushViewController:userprofile animated:YES];
}


- (void)messageViewController:(EaseMessageViewController *)viewController
            didSelectMoreView:(EaseChatBarMoreView *)moreView
                      AtIndex:(NSInteger)index
{
  // 隐藏键盘
  [self.chatToolbar endEditing:YES];
}

- (void)messageViewController:(EaseMessageViewController *)viewController
          didSelectRecordView:(UIView *)recordView
                 withEvenType:(EaseRecordViewType)type
{
  switch (type) {
    case EaseRecordViewTypeTouchDown:
    {
    if ([self.recordView isKindOfClass:[EaseRecordView class]]) {
      [(EaseRecordView *)self.recordView  recordButtonTouchDown];
    }
    }
      break;
    case EaseRecordViewTypeTouchUpInside:
    {
    if ([self.recordView isKindOfClass:[EaseRecordView class]]) {
      [(EaseRecordView *)self.recordView recordButtonTouchUpInside];
    }
    [self.recordView removeFromSuperview];
    }
      break;
    case EaseRecordViewTypeTouchUpOutside:
    {
    if ([self.recordView isKindOfClass:[EaseRecordView class]]) {
      [(EaseRecordView *)self.recordView recordButtonTouchUpOutside];
    }
    [self.recordView removeFromSuperview];
    }
      break;
    case EaseRecordViewTypeDragInside:
    {
    if ([self.recordView isKindOfClass:[EaseRecordView class]]) {
      [(EaseRecordView *)self.recordView recordButtonDragInside];
    }
    }
      break;
    case EaseRecordViewTypeDragOutside:
    {
    if ([self.recordView isKindOfClass:[EaseRecordView class]]) {
      [(EaseRecordView *)self.recordView recordButtonDragOutside];
    }
    }
      break;
    default:
      break;
  }
}

#pragma mark - EaseMessageViewControllerDataSource

- (id<IMessageModel>)messageViewController:(EaseMessageViewController *)viewController
                           modelForMessage:(EMMessage *)message
{
    id<IMessageModel> model = nil;
    model = [[EaseMessageModel alloc] initWithMessage:message];
    model.avatarImage = [UIImage imageNamed:@"ic_home_nor"];
    NSString *url = [NSString stringWithFormat:@"/uploads/users/%@.jpg", model.nickname];
    model.avatarURLPath = [kImageURL stringByAppendingString:url];
    model.nickname = message.ext[@"fromName"];
    model.failImageName = @"imageDownloadFail";
    return model;
}

#pragma mark - send message

- (void)sendTextMessage:(NSString *)text
{
  NSMutableDictionary *ext = [NSMutableDictionary dictionaryWithDictionary:self.conversation.ext];
  ext[@"extType"] = @(0);
  [self sendTextMessage:text withExt:[ext copy]];
}

- (void)sendLocationMessageLatitude:(double)latitude
                          longitude:(double)longitude
                         andAddress:(NSString *)address
{
  EMMessage *message = [EaseSDKHelper sendLocationMessageWithLatitude:latitude
                                                            longitude:longitude
                                                              address:address
                                                                   to:self.conversation.chatter
                                                          messageType:eMessageTypeChat
                                                    requireEncryption:NO
                                                           messageExt:self.conversation.ext];
  [self addMessageToDataSource:message
                      progress:nil];
}

- (void)sendImageMessage:(UIImage *)image
{
  id<IEMChatProgressDelegate> progress = nil;
  if (self.dataSource && [self.dataSource respondsToSelector:@selector(messageViewController:progressDelegateForMessageBodyType:)]) {
    progress = [self.dataSource messageViewController:self progressDelegateForMessageBodyType:eMessageBodyType_Image];
  }
  else{
    progress = self;
  }
  
  EMMessage *message = [EaseSDKHelper sendImageMessageWithImage:image
                                                             to:self.conversation.chatter
                                                    messageType:eMessageTypeChat
                                              requireEncryption:NO
                                                     messageExt:self.conversation.ext
                                                       progress:progress];
  [self addMessageToDataSource:message
                      progress:progress];
}

- (void)sendVoiceMessageWithLocalPath:(NSString *)localPath
                             duration:(NSInteger)duration
{
  id<IEMChatProgressDelegate> progress = nil;
  if (self.dataSource && [self.dataSource respondsToSelector:@selector(messageViewController:progressDelegateForMessageBodyType:)]) {
    progress = [self.dataSource messageViewController:self progressDelegateForMessageBodyType:eMessageBodyType_Voice];
  }
  else{
    progress = self;
  }
  
  EMMessage *message = [EaseSDKHelper sendVoiceMessageWithLocalPath:localPath
                                                           duration:duration
                                                                 to:self.conversation.chatter
                                                        messageType:eMessageTypeChat
                                                  requireEncryption:NO
                                                         messageExt:self.conversation.ext
                                                           progress:progress];
  [self addMessageToDataSource:message
                      progress:progress];
}

- (void)sendVideoMessageWithURL:(NSURL *)url
{
  id<IEMChatProgressDelegate> progress = nil;
  if (self.dataSource && [self.dataSource respondsToSelector:@selector(messageViewController:progressDelegateForMessageBodyType:)]) {
    progress = [self.dataSource messageViewController:self progressDelegateForMessageBodyType:eMessageBodyType_Video];
  }
  else{
    progress = self;
  }
  
  EMMessage *message = [EaseSDKHelper sendVideoMessageWithURL:url
                                                           to:self.conversation.chatter
                                                  messageType:eMessageTypeChat
                                            requireEncryption:NO
                                                   messageExt:self.conversation.ext
                                                     progress:progress];
  [self addMessageToDataSource:message
                      progress:progress];
}

#pragma mark - EaseMob

#pragma mark - EMChatManagerLoginDelegate

- (void)didLoginFromOtherDevice
{
  if ([self.imagePicker.mediaTypes count] > 0 && [[self.imagePicker.mediaTypes objectAtIndex:0] isEqualToString:(NSString *)kUTTypeMovie]) {
    [self.imagePicker stopVideoCapture];
  }
}

- (void)didRemovedFromServer
{
  if ([self.imagePicker.mediaTypes count] > 0 && [[self.imagePicker.mediaTypes objectAtIndex:0] isEqualToString:(NSString *)kUTTypeMovie]) {
    [self.imagePicker stopVideoCapture];
  }
}

#pragma mark - action

- (void)backAction
{
  if (self.deleteConversationIfNull) {
    //判断当前会话是否为空，若符合则删除该会话
    EMMessage *message = [self.conversation latestMessage];
    if (message == nil) {
      [[EaseMob sharedInstance].chatManager removeConversationByChatter:self.conversation.chatter deleteMessages:NO append2Chat:YES];
    }
  }
  [self.navigationController popToRootViewControllerAnimated:YES];
//  [self.navigationController popViewControllerAnimated:YES];
}

- (void)showGroupDetailAction
{
  [self.view endEditing:YES];
  if (self.conversation.conversationType == eConversationTypeGroupChat) {
//    ChatGroupDetailViewController *detailController = [[ChatGroupDetailViewController alloc] initWithGroupId:self.conversation.chatter];
//    [self.navigationController pushViewController:detailController animated:YES];
  }
}

- (void)deleteAllMessages:(id)sender
{
  if (self.dataArray.count == 0) {
    [self showHint:NSLocalizedString(@"message.noMessage", @"no messages")];
    return;
  }
  
  if ([sender isKindOfClass:[NSNotification class]]) {
    NSString *groupId = (NSString *)[(NSNotification *)sender object];
    BOOL isDelete = [groupId isEqualToString:self.conversation.chatter];
    if (self.conversation.conversationType != eConversationTypeChat && isDelete) {
      self.messageTimeIntervalTag = -1;
      [self.conversation removeAllMessages];
      [self.messsagesSource removeAllObjects];
      [self.dataArray removeAllObjects];
      
      [self.tableView reloadData];
      [self showHint:NSLocalizedString(@"message.noMessage", @"no messages")];
    }
  }
  else if ([sender isKindOfClass:[UIButton class]]){
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"prompt", @"Prompt") message:NSLocalizedString(@"sureToDelete", @"please make sure to delete") delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", @"Cancel") otherButtonTitles:NSLocalizedString(@"ok", @"OK"), nil];
    [alertView show];
  }
}

- (void)transpondMenuAction:(id)sender
{
    if (self.menuIndexPath && self.menuIndexPath.row > 0) {
//        id<IMessageModel> model = [self.dataArray objectAtIndex:self.menuIndexPath.row];
//        ContactListSelectViewController *listViewController = [[ContactListSelectViewController alloc] initWithNibName:nil bundle:nil];
//        listViewController.messageModel = model;
//        [listViewController tableViewDidTriggerHeaderRefresh];
//        [self.navigationController pushViewController:listViewController animated:YES];
    }
    self.menuIndexPath = nil;
}

- (void)copyMenuAction:(id)sender
{
  UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
  if (self.menuIndexPath && self.menuIndexPath.row > 0) {
    id<IMessageModel> model = [self.dataArray objectAtIndex:self.menuIndexPath.row];
    pasteboard.string = model.text;
  }
  
  self.menuIndexPath = nil;
}

- (void)deleteMenuAction:(id)sender
{
  if (self.menuIndexPath && self.menuIndexPath.row > 0) {
    id<IMessageModel> model = [self.dataArray objectAtIndex:self.menuIndexPath.row];
    NSMutableIndexSet *indexs = [NSMutableIndexSet indexSetWithIndex:self.menuIndexPath.row];
    NSMutableArray *indexPaths = [NSMutableArray arrayWithObjects:self.menuIndexPath, nil];
    
    [self.conversation removeMessage:model.message];
    [self.messsagesSource removeObject:model.message];
    
    if (self.menuIndexPath.row - 1 >= 0) {
      id nextMessage = nil;
      id prevMessage = [self.dataArray objectAtIndex:(self.menuIndexPath.row - 1)];
      if (self.menuIndexPath.row + 1 < [self.dataArray count]) {
        nextMessage = [self.dataArray objectAtIndex:(self.menuIndexPath.row + 1)];
      }
      if ((!nextMessage || [nextMessage isKindOfClass:[NSString class]]) && [prevMessage isKindOfClass:[NSString class]]) {
        [indexs addIndex:self.menuIndexPath.row - 1];
        [indexPaths addObject:[NSIndexPath indexPathForRow:(self.menuIndexPath.row - 1) inSection:0]];
      }
    }
    
    [self.dataArray removeObjectsAtIndexes:indexs];
    [self.tableView beginUpdates];
    [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView endUpdates];
  }
  
  self.menuIndexPath = nil;
}

#pragma mark - notification

- (void)exitGroup
{
  [self.navigationController popToViewController:self animated:NO];
  [self.navigationController popViewControllerAnimated:YES];
}

- (void)insertCallMessage:(NSNotification *)notification
{
  id object = notification.object;
  if (object) {
    EMMessage *message = (EMMessage *)object;
    [self addMessageToDataSource:message progress:nil];
    [[EaseMob sharedInstance].chatManager insertMessageToDB:message append2Chat:YES];
  }
}

- (void)handleCallNotification:(NSNotification *)notification
{
  id object = notification.object;
  if ([object isKindOfClass:[NSDictionary class]]) {
    //开始call
    self.isViewDidAppear = NO;
  } else {
    //结束call
    self.isViewDidAppear = YES;
  }
}

#pragma mark - private

- (NSString *)getChatterName {
  return self.conversation.ext[@"toName"];
}

- (void)_showMenuViewController:(UIView *)showInView
                   andIndexPath:(NSIndexPath *)indexPath
                    messageType:(MessageBodyType)messageType
{
  if (self.menuController == nil) {
    self.menuController = [UIMenuController sharedMenuController];
  }
  
  if (_deleteMenuItem == nil) {
    _deleteMenuItem = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"delete", @"Delete") action:@selector(deleteMenuAction:)];
  }
  
  if (_copyMenuItem == nil) {
    _copyMenuItem = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"copy", @"Copy") action:@selector(copyMenuAction:)];
  }
  
  if (_transpondMenuItem == nil) {
    _transpondMenuItem = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"transpond", @"Transpond") action:@selector(transpondMenuAction:)];
  }
  
  if (messageType == eMessageBodyType_Text) {
    [self.menuController setMenuItems:@[_copyMenuItem, _deleteMenuItem,_transpondMenuItem]];
  } else if (messageType == eMessageBodyType_Image){
    [self.menuController setMenuItems:@[_deleteMenuItem,_transpondMenuItem]];
  } else {
    [self.menuController setMenuItems:@[_deleteMenuItem]];
  }
  [self.menuController setTargetRect:showInView.frame inView:showInView.superview];
  [self.menuController setMenuVisible:YES animated:YES];
}

- (void)_sendFirstMessage {
  if ([self.firstMessage length] != 0) {
    if ([self.firstMessage isEqualToString:@"Card"] ) {
      NSMutableDictionary *content = [NSMutableDictionary dictionary];
      content[@"roomtype"] = self.order.roomtype;
      content[@"arrivaldate"] = self.order.arrivaldate;
      content[@"leavedate"] = self.order.leavedate;
      content[@"content"] = NSLocalizedString(@"BOOKING_CARD_TITLE", nil);
      content[@"imgurl"] = self.order.imgurl;
      content[@"orderno"] = self.order.orderno;
      content[@"orderstatus"] = self.order.orderstatus;
      NSError *error;
      NSData *jsonData = [NSJSONSerialization dataWithJSONObject:content
                                                         options:0
                                                           error:&error];
      if (!jsonData) {
        NSLog(@"Got an error: %@", error);
      } else {
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        NSMutableDictionary *ext = [NSMutableDictionary dictionaryWithDictionary:self.conversation.ext];
        ext[@"extType"] = @(1);
        [self sendTextMessage:jsonString withExt:ext];
        [self sendTextMessage:@"你好，帮我预定这间房"];
      }
    } else {
      [self sendTextMessage:self.firstMessage];
  }
  }
  
  if ([self.cancleMessage length] != 0) {
    if ([self.cancleMessage isEqualToString:@"card"] ) {
      NSMutableDictionary *content = [NSMutableDictionary dictionary];
      content[@"roomtype"] = self.order.roomtype;
      content[@"arrivaldate"] = self.order.arrivaldate;
      content[@"leavedate"] = self.order.leavedate;
      content[@"content"] = @"您好，我已取消订单，请跟进";
      content[@"imgurl"] = self.order.imgurl;
      content[@"orderno"] = self.order.orderno;
      content[@"orderstatus"] = self.order.orderstatus;
      NSError *error;
      NSData *jsonData = [NSJSONSerialization dataWithJSONObject:content
                                                         options:0
                                                           error:&error];
      if (!jsonData) {
        NSLog(@"Got an error: %@", error);
      } else {
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        NSMutableDictionary *ext = [NSMutableDictionary dictionaryWithDictionary:self.conversation.ext];
        ext[@"extType"] = @(1);
        [self sendTextMessage:jsonString withExt:ext];
        [self sendTextMessage:@"您好，我已取消订单，请跟进"];
      }
    } else {
      [self sendTextMessage:self.cancleMessage];
    }
  }
  

}

#pragma mark - HotelOrderDetailTVCDelegate

-(void)shouldSendTextMessage:(NSString *)message {
      [self sendTextMessage: message];
      NSLog(@"send: %@", message);
}

#pragma mark - public refresh

- (void)tableViewDidFinishTriggerHeader:(BOOL)isHeader reload:(BOOL)reload
{
  __weak ChatViewController *weakSelf = self;
  dispatch_async(dispatch_get_main_queue(), ^{
    if (reload) {
      [weakSelf _sendFirstMessage];
      [weakSelf.tableView reloadData];
    }
    
    if (isHeader) {
      [weakSelf.tableView.mj_header endRefreshing];
    }
    else{
      [weakSelf.tableView.mj_footer endRefreshing];
    }
  });
}

@end
