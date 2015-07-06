//
//  JSHChatVC.m
//  HotelVIP
//
//  Created by Hanton on 6/3/15.
//  Copyright (c) 2015 ZKJS. All rights reserved.
//

#import "SVIP-Swift.h"
#import "JSHChatVC.h"
#import "XHDisplayMediaViewController.h"
#import "XHAudioPlayerHelper.h"
#import "ZKJSTCPSessionManager.h"
#import "UIImage+Resize.h"
#import "ZKJSTool.h"
//#import "JSHAccountManager.h"
//#import "JSHBookOrder.h"
@import AVFoundation;
//#import "JSHStorage.h"


@interface JSHChatVC () <XHMessageTableViewControllerDelegate, XHMessageTableViewCellDelegate, XHAudioPlayerHelperDelegate, AVAudioPlayerDelegate>
@property (nonatomic, strong) XHMessageTableViewCell *currentSelectedCell;
@property (nonatomic, strong) NSString *messageReceiver;
@property (nonatomic, strong) NSString *receiverName;
@property (nonatomic, strong) NSString *senderID;
@property (nonatomic, strong) NSString *senderName;
@property (nonatomic) ChatType chatType;
@property (nonatomic, strong) NSString *sessionID;
@end

@implementation JSHChatVC

//- (instancetype)initWithBookOrder:(JSHBookOrder *)bookOrder {
//  self = [super init];
//  if (self) {
//    self.bookOrder = bookOrder;
//  }
//  return self;
//}

- (instancetype)initWithChatType:(ChatType)chatType {
  self = [super init];
  if (self) {
    self.chatType = chatType;
  }
  return self;
}


- (void)viewDidLoad {
  self.allowsSendFace = NO;
  
  [super viewDidLoad];
  
  UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:@"关闭" style:UIBarButtonItemStylePlain target:self action:@selector(dismissSelf)];
  self.navigationItem.rightBarButtonItem = rightItem;

  self.title = @"聊天";
    
  self.navigationController.interactivePopGestureRecognizer.delaysTouchesBegan=NO;
  
  self.messageSender = @"我";
  self.messageReceiver = self.receiverName;
  self.senderID = @"557cff54a9a97";//[JSHAccountManager sharedJSHAccountManager].userid;
  self.senderName = @"金石";
  self.shopID = @"120";
  
  NSMutableArray *shareMenuItems = [NSMutableArray array];
  NSArray *plugIcons = @[@"sharemore_pic", @"sharemore_video"];
  NSArray *plugTitle = @[@"照片", @"拍摄"];
  for (NSString *plugIcon in plugIcons) {
    XHShareMenuItem *shareMenuItem = [[XHShareMenuItem alloc] initWithNormalIconImage:[UIImage imageNamed:plugIcon] title:[plugTitle objectAtIndex:[plugIcons indexOfObject:plugIcon]]];
    [shareMenuItems addObject:shareMenuItem];
  }
  
  self.shareMenuItems = shareMenuItems;
  [self.shareMenuView reloadData];
  
  [self loadDataSource];
  
  [self setupNotification];
  
  switch (self.chatType) {
    case ChatNewSession: {
      //  NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
      //  [formatter setDateFormat:@"yyyy-MM-dd"];
      NSString *orderInfo = @"";//[NSString stringWithFormat:@"系统消息\n订单号:%@\n客户姓名:%@\n客户电话:%@\n房间数量:%@\n到达时间:%@\n离店时间:%@\n入住天数:%ld天\n房型:%@\n房间价格:%@\n备注:%@", self.bookOrder.orderNO, self.bookOrder.guest, self.bookOrder.guestPhone, self.bookOrder.roomNum, [formatter stringFromDate:self.bookOrder.arrivalDate], [formatter stringFromDate:self.bookOrder.departureDate], (long)self.bookOrder.duration, self.bookOrder.roomType, self.bookOrder.roomRate, self.bookOrder.remark];
      [self requestWaiter:orderInfo];
      break;
    }
    case ChatOldSession: {
      self.sessionID = [[StorageManager sharedInstance] chatSession:self.shopID];
      break;
    }
    case ChatService: {
      self.messageInputView.hidden = YES;
      // setup view
      // [self requestWaiter];
      break;
    }
    default:
      break;
  }
}

- (void)requestWaiter:(NSString *)desc {
  NSNumber *timestamp = [NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970] * 1000];
  self.sessionID = [NSString stringWithFormat:@"%@_%@_%@", timestamp, self.shopID, self.senderID];
  [[StorageManager sharedInstance] saveChatSession:self.sessionID shopID:self.shopID];
  NSDictionary *dictionary = @{
                               @"type": [NSNumber numberWithInteger:MessageServiceChatRequestWaiter_C2S],
                               @"timestamp": timestamp,
                               @"ruletype": @"0",  // 预订部
                               @"clientid": self.senderID,
                               @"clientname": self.senderName,
                               @"shopid": self.shopID,
                               @"desc": desc,
                               @"sessionid": self.sessionID
                               };
  [[ZKJSTCPSessionManager sharedInstance] sendPacketFromDictionary:dictionary];
}

- (void)viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];
  
  [self saveDataSource];
}

- (void)dealloc {
  [[XHAudioPlayerHelper shareInstance] setDelegate:nil];
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - XHMessageTableViewControllerDelegate

- (void)didSendText:(NSString *)text fromSender:(NSString *)sender onDate:(NSDate *)date {
  [self sendTextMessage:text];
  XHMessage *message = [[XHMessage alloc] initWithText:text sender:sender timestamp:date];
  message.avatar = [UIImage imageNamed:@"ic_home_nor"];
  
  [self addMessage:message];
  [self finishSendMessageWithBubbleMessageType:XHBubbleMessageMediaTypeText];
}

- (void)didSendPhoto:(UIImage *)photo fromSender:(NSString *)sender onDate:(NSDate *)date {
  [self sendImageMessage:photo];
  XHMessage *message = [[XHMessage alloc] initWithPhoto:photo thumbnailUrl:nil originPhotoUrl:nil sender:sender timestamp:date];
  message.avatar = [UIImage imageNamed:@"ic_home_nor"];
  
  [self addMessage:message];
  [self finishSendMessageWithBubbleMessageType:XHBubbleMessageMediaTypePhoto];
}

- (void)didSendVoice:(NSString *)voicePath voiceDuration:(NSString *)voiceDuration fromSender:(NSString *)sender onDate:(NSDate *)date {
  [self sendVoiceMessage:voicePath];
  XHMessage *message = [[XHMessage alloc] initWithVoicePath:voicePath voiceUrl:voicePath voiceDuration:voiceDuration sender:sender timestamp:date];
  message.avatar = [UIImage imageNamed:@"ic_home_nor"];
  
  [self addMessage:message];
  [self finishSendMessageWithBubbleMessageType:XHBubbleMessageMediaTypeVoice];
}

#pragma mark - XHMessageTableViewCell delegate

- (void)multiMediaMessageDidSelectedOnMessage:(id<XHMessageModel>)message atIndexPath:(NSIndexPath *)indexPath onMessageTableViewCell:(XHMessageTableViewCell *)messageTableViewCell {
  UIViewController *disPlayViewController;
  switch (message.messageMediaType) {
    case XHBubbleMessageMediaTypeVideo:
    case XHBubbleMessageMediaTypePhoto: {
      DLog(@"message : %@", message.photo);
      DLog(@"message : %@", message.videoConverPhoto);
      XHDisplayMediaViewController *messageDisplayTextView = [[XHDisplayMediaViewController alloc] init];
      messageDisplayTextView.message = message;
      disPlayViewController = messageDisplayTextView;
      break;
    }
      break;
    case XHBubbleMessageMediaTypeVoice: {
      DLog(@"message : %@", message.voicePath);
      
      message.isRead = YES;
      messageTableViewCell.messageBubbleView.voiceUnreadDotImageView.hidden = YES;
      
      [[XHAudioPlayerHelper shareInstance] setDelegate:(id<NSFileManagerDelegate>)self];
      if (self.currentSelectedCell) {
        [self.currentSelectedCell.messageBubbleView.animationVoiceImageView stopAnimating];
      }
      if (self.currentSelectedCell == messageTableViewCell) {
        [messageTableViewCell.messageBubbleView.animationVoiceImageView stopAnimating];
        [[XHAudioPlayerHelper shareInstance] stopAudio];
        self.currentSelectedCell = nil;
      } else {
        self.currentSelectedCell = messageTableViewCell;
        [messageTableViewCell.messageBubbleView.animationVoiceImageView startAnimating];
        [[XHAudioPlayerHelper shareInstance] managerAudioWithFileName:message.voicePath toPlay:YES];
      }
      break;
    }
    case XHBubbleMessageMediaTypeEmotion:
      DLog(@"facePath : %@", message.emotionPath);
      break;
    case XHBubbleMessageMediaTypeLocalPosition: {
      DLog(@"facePath : %@", message.localPositionPhoto);
      break;
    }
    default:
      break;
  }
  if (disPlayViewController) {
    [self.navigationController pushViewController:disPlayViewController animated:YES];
  }
}

#pragma mark - XHAudioPlayerHelper Delegate

- (void)didAudioPlayerStopPlay:(AVAudioPlayer *)audioPlayer {
  if (!self.currentSelectedCell) {
    return;
  }
  [self.currentSelectedCell.messageBubbleView.animationVoiceImageView stopAnimating];
  self.currentSelectedCell = nil;
}

#pragma mark - RecorderPath Helper Method

- (NSString *)getRecorderPath {
  NSString *recorderPath = nil;
  recorderPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex: 0];
  NSDate *now = [NSDate date];
  NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
  [dateFormatter setDateFormat:@"yyyyMMddHHmmssSSS"];
  recorderPath = [recorderPath stringByAppendingFormat:@"%@.aac", [dateFormatter stringFromDate:now]];
  return recorderPath;
}

- (NSString *)getPlayPath {
  NSString *recorderPath = nil;
  recorderPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex: 0];
  NSDate *now = [NSDate date];
  NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
  [dateFormatter setDateFormat:@"yyyyMMddHHmmssSSS"];
  recorderPath = [recorderPath stringByAppendingFormat:@"%@", [dateFormatter stringFromDate:now]];
  return recorderPath;
}

#pragma mark - Private Methods

- (void)loadDataSource {
  WEAKSELF
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *fileName = [NSString stringWithFormat:@"%@.chatlog", self.shopID];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:fileName];
//    NSMutableArray *messages = [NSMutableArray arrayWithContentsOfFile:filePath];
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    NSMutableArray *messages = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    NSLog(@"Loading Path: %@", filePath);
    dispatch_async(dispatch_get_main_queue(), ^{
      weakSelf.messages = messages;
      [weakSelf.messageTableView reloadData];

      [weakSelf scrollToBottomAnimated:NO];
    });
  });
}

- (void)saveDataSource {
  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
  NSString *documentsDirectory = [paths objectAtIndex:0];
  NSString *fileName = [NSString stringWithFormat:@"%@.chatlog", self.shopID];
  NSString *filePath = [documentsDirectory stringByAppendingPathComponent:fileName];
  NSLog(@"Saving Path: %@", filePath);
//  [self.messages writeToFile:filePath atomically:YES];
  NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.messages];
  [data writeToFile:filePath atomically:YES];
}

- (void)sendTextMessage:(NSString *)text {
  NSNumber *timestamp = [NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970] * 1000];
  NSDictionary *dictionary = @{
                               @"type": [NSNumber numberWithInteger:MessageServiceChatCustomerServiceTextChat],
                               @"timestamp": timestamp,
                               @"fromid": self.senderID,
                               @"clientid": self.senderID,
                               @"clientname": @"SVIP",//[JSHStorage baseInfo].name,
                               @"shopid": self.shopID,
                               @"sessionid": self.sessionID,
                               @"textmsg": text
                               };
  [[ZKJSTCPSessionManager sharedInstance] sendPacketFromDictionary:dictionary];
}

- (void)sendVoiceMessage:(NSString *)voicePath {
  NSData *audioData = [[NSData alloc] initWithContentsOfFile:voicePath];
  NSString *body = [audioData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
  NSNumber *timestamp = [NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970] * 1000];
  NSDictionary *dictionary = @{
                               @"type": [NSNumber numberWithInteger:MessageServiceChatCustomerServiceMediaChat],
                               @"timestamp": timestamp,
                               @"fromid": self.senderID,
                               @"clientid": self.senderID,
                               @"clientname": @"SVIP",//[JSHStorage baseInfo].name,
                               @"shopid": self.shopID,
                               @"sessionid": self.sessionID,
                               @"body": body
                               };
  [[ZKJSTCPSessionManager sharedInstance] sendPacketFromDictionary:dictionary];
}

- (void)sendImageMessage:(UIImage *)image {
  UIImage *compressedImage = [image resizedImage:CGSizeMake(100.0, 100.0) interpolationQuality:kCGInterpolationDefault];
  NSData *imageData = UIImageJPEGRepresentation(compressedImage, 1.0);
  NSString *body = [imageData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
  NSNumber *timestamp = [NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970] * 1000];
  NSDictionary *dictionary = @{
                               @"type": [NSNumber numberWithInteger:MessageServiceChatCustomerServiceImgChat],
                               @"timestamp": timestamp,
                               @"fromid": self.senderID,
                               @"clientid": self.senderID,
                               @"clientname": @"SVIP",//[JSHStorage baseInfo].name,
                               @"shopid": self.shopID,
                               @"sessionid": self.sessionID,
                               @"body": body
                               };
  [[ZKJSTCPSessionManager sharedInstance] sendPacketFromDictionary:dictionary];
}

- (void)dismissSelf {
  [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Notifications

- (void)setupNotification {
  NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
  [center addObserver:self selector:@selector(showTextMessage:) name:@"MessageServiceChatCustomerServiceTextChatNotification" object:nil];
  [center addObserver:self selector:@selector(showImageMessage:) name:@"MessageServiceChatCustomerServiceImgChatNotification" object:nil];
  [center addObserver:self selector:@selector(showVoiceMessage:) name:@"MessageServiceChatCustomerServiceMediaChatNotification" object:nil];
}

- (void)showTextMessage:(NSNotification *)notification {
  NSString *sender = notification.userInfo[@"fromid"];
  NSString *text = notification.userInfo[@"textmsg"];
  
  XHMessage *message;
  NSDate *timestamp = [NSDate date];
  message = [[XHMessage alloc] initWithText:text sender:sender timestamp:timestamp];
  message.bubbleMessageType = XHBubbleMessageTypeReceiving;
  message.avatar = [UIImage imageNamed:@"ic_home_nor"];
  
  [self.messages addObject:message];
  [self.messageTableView reloadData];
  [self scrollToBottomAnimated:NO];
}

- (void)showVoiceMessage:(NSNotification *)notification {
  NSString *sender = notification.userInfo[@"fromid"];
  NSString *body = notification.userInfo[@"body"];
  NSData *voiceData = [[NSData alloc] initWithBase64EncodedString:body options:NSDataBase64DecodingIgnoreUnknownCharacters];
  NSString *voicePath = [self getPlayPath];
  
  [voiceData writeToFile:voicePath atomically:NO];
  NSString *voiceDuration = [self getVoiceDuration:voicePath];
  
  XHMessage *message;
  NSDate *timestamp = [NSDate date];
  message = [[XHMessage alloc] initWithVoicePath:voicePath voiceUrl:nil voiceDuration:voiceDuration sender:sender timestamp:timestamp isRead:NO];
  message.bubbleMessageType = XHBubbleMessageTypeReceiving;
  message.avatar = [UIImage imageNamed:@"ic_home_nor"];
  
  [self.messages addObject:message];
  [self.messageTableView reloadData];
  [self scrollToBottomAnimated:NO];
}

- (void)showImageMessage:(NSNotification *)notification {
  NSString *sender = notification.userInfo[@"fromid"];
  NSString *body = notification.userInfo[@"body"];
  NSData *imageData = [[NSData alloc] initWithBase64EncodedString:body options:NSDataBase64DecodingIgnoreUnknownCharacters];
  UIImage *image = [UIImage imageWithData:imageData];
  
  XHMessage *message;
  NSDate *timestamp = [NSDate date];
  message = [[XHMessage alloc] initWithPhoto:image thumbnailUrl:nil originPhotoUrl:nil sender:sender timestamp:timestamp];
  message.bubbleMessageType = XHBubbleMessageTypeReceiving;
  message.avatar = [UIImage imageNamed:@"ic_home_nor"];
  
  [self.messages addObject:message];
  [self.messageTableView reloadData];
  [self scrollToBottomAnimated:NO];
}

- (NSString *)getVoiceDuration:(NSString *)recordPath {
  NSError *error = nil;
  NSString *recordDuration = nil;
  AVAudioPlayer *play = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:recordPath] error:&error];
  if (error) {
    DLog(@"recordPath：%@ error：%@", recordPath, error);
    recordDuration = @"";
  } else {
    DLog(@"时长:%f", play.duration);
    recordDuration = [NSString stringWithFormat:@"%.1f", play.duration];
  }
  return recordDuration;
}

@end
