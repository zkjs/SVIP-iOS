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
#import "JTSImageViewController.h"
#import "ZKJSHTTPChatSessionManager.h"

@import AVFoundation;

const CGFloat switchWidth = 45.0;
const CGFloat shortcutViewHeight = 45.0;

@interface JSHChatVC () <XHMessageTableViewControllerDelegate, XHMessageTableViewCellDelegate, XHAudioPlayerHelperDelegate, AVAudioPlayerDelegate>
@property (nonatomic, strong) NSDictionary *data;
@property (nonatomic, strong) XHMessageTableViewCell *currentSelectedCell;
@property (nonatomic, strong) NSString *messageReceiver;
@property (nonatomic, strong) NSString *receiverName;
@property (nonatomic, strong) NSString *senderID;
@property (nonatomic, strong) NSString *senderName;
@property (nonatomic) ChatType chatType;
@property (nonatomic, strong) NSString *sessionID;
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) NSMutableSet *actionButtons;
@property (nonatomic, strong) UIView *shortcutView;
@property (nonatomic, strong) NSMutableArray *subButtonViews;
@property (nonatomic) NSInteger currentSubButtonViewIndex;
@property (nonatomic, strong) NSArray *emotionManagers;
@end

@implementation JSHChatVC

#pragma mark - View Lifecycle

- (instancetype)initWithChatType:(ChatType)chatType {
  self = [super init];
  if (self) {
    self.chatType = chatType;
    self.shopName = @"";
  }
  return self;
}

- (void)viewDidLoad {
  self.allowsSendFace = NO;
  if (self.chatType == ChatService) {
    self.allowsShortcutView = YES;
  }
  
  [super viewDidLoad];
  
  [self setupNotification];
  [self setupNavigationBar];
  [self setupShortcutViewDataSource];
  [self setupMessageTableView];
  [self setupMessageInputView];
  [self setupSessionID];
  [self customizeChatType];
  [self loadDataSource];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
  [self requestOfflineMessages];
  [self updateShopMessageBadge];
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  
  NSNumber *timestamp = [NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970] * 1000];
  NSDictionary *dictionary = @{
                               @"type": [NSNumber numberWithInteger:MessageServiceChatClientChatOnlineStatus],
                               @"timestamp": timestamp,
                               @"userid": self.senderID,
                               @"status": @0  // 在线
                               };
  [[ZKJSTCPSessionManager sharedInstance] sendPacketFromDictionary:dictionary];
}

- (void)viewDidDisappear:(BOOL)animated {
  [super viewDidDisappear:animated];
  
  NSNumber *timestamp = [NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970] * 1000];
  NSDictionary *dictionary = @{
                               @"type": [NSNumber numberWithInteger:MessageServiceChatClientChatOnlineStatus],
                               @"timestamp": timestamp,
                               @"userid": self.senderID,
                               @"status": @1  // 不在线
                               };
  [[ZKJSTCPSessionManager sharedInstance] sendPacketFromDictionary:dictionary];
}

- (void)dealloc {
  [[XHAudioPlayerHelper shareInstance] setDelegate:nil];
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - XHMessageTableViewController Delegate

- (BOOL)shouldLoadMoreMessagesScrollToTop {
  return YES;
}

- (void)loadMoreMessagesScrollTotop {
  NSLog(@"Load More Messages");
  if (self.messages.count == 0) {
    return;
  } else {
    if (!self.loadingMoreMessage) {
      self.loadingMoreMessage = YES;
      XHMessage *message = self.messages[0];
      WEAKSELF
      dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableArray *messages = [NSMutableArray array];
        messages = [Persistence.sharedInstance fetchMessagesWithShopID:self.shopID userID:self.senderID beforeTimeStamp:message.timestamp];
        dispatch_async(dispatch_get_main_queue(), ^{
          [weakSelf insertOldMessages:messages completion:^{
            weakSelf.loadingMoreMessage = NO;
          }];
        });
      });
    }
  }
}

- (void)didSendText:(NSString *)text fromSender:(NSString *)sender onDate:(NSDate *)date {
  [self sendTextMessage:text];
  XHMessage *message = [[XHMessage alloc] initWithText:text sender:sender timestamp:date];
  message.bubbleMessageType = XHBubbleMessageTypeSending;
  message.messageMediaType = XHBubbleMessageMediaTypeText;
  if ([JSHStorage baseInfo].avatarImage) {
    message.avatar = [JSHStorage baseInfo].avatarImage;
  } else {
    message.avatar = [UIImage imageNamed:@"ic_home_nor"];
  }

  [Persistence.sharedInstance saveMessage:message shopID:self.shopID];
  
  [self addMessage:message];
  [self finishSendMessageWithBubbleMessageType:XHBubbleMessageMediaTypeText];
}

- (void)didSendPhoto:(UIImage *)photo fromSender:(NSString *)sender onDate:(NSDate *)date {
  [self sendImageMessage:photo];
  XHMessage *message = [[XHMessage alloc] initWithPhoto:photo thumbnailUrl:nil originPhotoUrl:nil sender:sender timestamp:date];
  message.bubbleMessageType = XHBubbleMessageTypeSending;
  message.messageMediaType = XHBubbleMessageMediaTypePhoto;
  if ([JSHStorage baseInfo].avatarImage) {
    message.avatar = [JSHStorage baseInfo].avatarImage;
  } else {
    message.avatar = [UIImage imageNamed:@"ic_home_nor"];
  }
  
  [Persistence.sharedInstance saveMessage:message shopID:self.shopID];
  
  [self addMessage:message];
  [self finishSendMessageWithBubbleMessageType:XHBubbleMessageMediaTypePhoto];
}

- (void)didSendVoice:(NSString *)voicePath voiceDuration:(NSString *)voiceDuration fromSender:(NSString *)sender onDate:(NSDate *)date {
  [self sendVoiceMessage:voicePath];
  XHMessage *message = [[XHMessage alloc] initWithVoicePath:voicePath voiceUrl:voicePath voiceDuration:voiceDuration sender:sender timestamp:date];
  message.bubbleMessageType = XHBubbleMessageTypeSending;
  message.messageMediaType = XHBubbleMessageMediaTypeVoice;
  if ([JSHStorage baseInfo].avatarImage) {
    message.avatar = [JSHStorage baseInfo].avatarImage;
  } else {
    message.avatar = [UIImage imageNamed:@"ic_home_nor"];
  }
  
  [Persistence.sharedInstance saveMessage:message shopID:self.shopID];
  
  [self addMessage:message];
  [self finishSendMessageWithBubbleMessageType:XHBubbleMessageMediaTypeVoice];
}

- (void)didSendEmotion:(NSString *)emotionPath fromSender:(NSString *)sender onDate:(NSDate *)date {
//  [self sendVoiceMessage:voicePath];
  XHMessage *message = [[XHMessage alloc] initWithEmotionPath:emotionPath sender:sender timestamp:date];
  message.bubbleMessageType = XHBubbleMessageTypeSending;
  message.messageMediaType = XHBubbleMessageMediaTypeEmotion;
  if ([JSHStorage baseInfo].avatarImage) {
    message.avatar = [JSHStorage baseInfo].avatarImage;
  } else {
    message.avatar = [UIImage imageNamed:@"ic_home_nor"];
  }
  
//  [Persistence.sharedInstance saveMessage:message shopID:self.shopID];
  
  [self addMessage:message];
  [self finishSendMessageWithBubbleMessageType:XHBubbleMessageMediaTypeEmotion];
}

#pragma mark - XHMessageTableViewCell delegate

- (void)multiMediaMessageDidSelectedOnMessage:(id<XHMessageModel>)message atIndexPath:(NSIndexPath *)indexPath onMessageTableViewCell:(XHMessageTableViewCell *)messageTableViewCell {
  UIViewController *disPlayViewController;
  switch (message.messageMediaType) {
    case XHBubbleMessageMediaTypeVideo:
    case XHBubbleMessageMediaTypePhoto: {
      DLog(@"message : %@", message.photo);
      DLog(@"message : %@", message.videoConverPhoto);
      
      JTSImageInfo *imageInfo = [[JTSImageInfo alloc] init];
      imageInfo.image = message.photo;
      imageInfo.referenceRect = messageTableViewCell.frame;
      imageInfo.referenceView = messageTableViewCell.superview;
      JTSImageViewController *imageViewer = [[JTSImageViewController alloc]
                                             initWithImageInfo:imageInfo
                                             mode:JTSImageViewControllerMode_Image
                                             backgroundStyle:JTSImageViewControllerBackgroundOption_Blurred];
      [imageViewer showFromViewController:self transition:JTSImageViewControllerTransition_FromOffscreen];
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
    case XHBubbleMessageMediaTypeCard: {
      disPlayViewController = [UIViewController new];
      disPlayViewController.view.backgroundColor = [UIColor whiteColor];
      UILabel *label = [[UILabel alloc] initWithFrame:disPlayViewController.view.bounds];
      label.textAlignment = NSTextAlignmentCenter;
      label.textColor = [UIColor blackColor];
      label.text = @"呵呵";
      [disPlayViewController.view addSubview:label];
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

#pragma mark - XHEmotionManagerView DataSource

- (NSInteger)numberOfEmotionManagers {
  return self.emotionManagers.count;
}

- (XHEmotionManager *)emotionManagerForColumn:(NSInteger)column {
  return [self.emotionManagers objectAtIndex:column];
}

- (NSArray *)emotionManagersAtManager {
  return self.emotionManagers;
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

- (void)setupNavigationBackButton {
  UIBarButtonItem *newBackButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ic_fanhui"] style:UIBarButtonItemStylePlain target:self action:@selector(popToRootVC:)];
  newBackButton.tintColor = [UIColor blackColor];
  self.navigationItem.leftBarButtonItem = newBackButton;
}

- (void)popToRootVC:(UIBarButtonItem *)sender {
  [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)setupNavigationBar {
  // 把Navigation Bar设置为不透明的
  self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
  self.navigationController.navigationBar.translucent = NO;
}

- (void)setupMessageTableView {
  self.messageTableView.backgroundColor = [UIColor colorWithHexString:@"#CBCCCA"];
  self.messageSender = @"我";
  self.messageReceiver = self.receiverName;
  self.senderID = [JSHAccountManager sharedJSHAccountManager].userid;
  if ([JSHStorage baseInfo].username) {
    self.senderName = [JSHStorage baseInfo].username;
  } else {
    self.senderName = @"";
  }
}

- (void)setupMessageInputView {
  NSMutableArray *shareMenuItems = [NSMutableArray array];
  NSArray *plugIcons = @[@"sharemore_pic", @"sharemore_video"];
  NSArray *plugTitle = @[@"照片", @"拍摄"];
  for (NSString *plugIcon in plugIcons) {
    XHShareMenuItem *shareMenuItem = [[XHShareMenuItem alloc] initWithNormalIconImage:[UIImage imageNamed:plugIcon] title:[plugTitle objectAtIndex:[plugIcons indexOfObject:plugIcon]]];
    [shareMenuItems addObject:shareMenuItem];
  }
  self.shareMenuItems = shareMenuItems;
  [self.shareMenuView reloadData];
  
  self.messageInputView.inputTextView.placeHolder = @"";
  self.messageInputView.delegate = self;
  
  NSMutableArray *emotionManagers = [NSMutableArray array];
  for (NSInteger i = 0; i < 1; i ++) {
    XHEmotionManager *emotionManager = [[XHEmotionManager alloc] init];
    emotionManager.emotionName = @"";//[NSString stringWithFormat:@"表情%ld", (long)i];
    NSMutableArray *emotions = [NSMutableArray array];
    for (NSInteger j = 0; j < 18; j ++) {
      XHEmotion *emotion = [[XHEmotion alloc] init];
      NSString *imageName = [NSString stringWithFormat:@"section%ld_emotion%ld", (long)i , (long)j % 16];
      emotion.emotionPath = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"emotion%ld.gif", (long)j] ofType:@""];
      emotion.emotionConverPhoto = [UIImage imageNamed:imageName];
      [emotions addObject:emotion];
    }
    emotionManager.emotions = emotions;
    
    [emotionManagers addObject:emotionManager];
  }
  
//  self.emotionManagerView.isShowEmotionStoreButton = NO;
  self.emotionManagers = emotionManagers;
  [self.emotionManagerView reloadData];
}

- (void)customizeChatType {
  switch (self.chatType) {
    case ChatNewSession: {
      self.title = @"联系客服";
      
//      NSString *orderInfo = [NSString stringWithFormat:@"系统消息\n订单号: %@\n姓名: %@\n电话: %@\n到达时间: %@\n离店时间: %@\n房型: %@\n房间价格: %@\n备注: %@", self.order.reservation_no, self.order.guest, self.order.guesttel, self.order.arrival_date, self.order.departure_date, self.order.room_type, self.order.room_rate, self.order.remark];
//      [self requestWaiterWithRuleType:@"Booking" andDescription:orderInfo];  // 预订部
//      // Delay
//      __weak __typeof(self) weakSelf = self;
//      dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [weakSelf showSystemFeedbackWithText:@"请问您还有其它需求吗 :)"];
//      });
      
      [self requestWaiterWithRuleType:@"DefaultChatRuleType" andDescription:@""];
      [self setupNavigationBackButton];
//      __weak __typeof(self) weakSelf = self;
//      dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        NSString *content = [NSString stringWithFormat:@"%@ | %@入住 | %@晚", weakSelf.order.room_type, weakSelf.order.departure_date, weakSelf.order.dayInt];
//        [weakSelf sendCardWithTitle:@"你好，帮我预定这间房" image:weakSelf.order.room_image content:content];
//      });

      break;
    }
    case ChatOldSession: {
      self.title = [NSString stringWithFormat:@"%@", self.shopName];
      [self setupNavigationBackButton];
      break;
    }
    case ChatCallingWaiter: {
      self.title = [NSString stringWithFormat:@"%@", self.shopName];
      NSString *orderStatus = @"";
      if ([self.order.status isEqualToString:@"0"]) {
        orderStatus = @"未确认可取消订单";
      } else if ([self.order.status isEqualToString:@"1"]) {
        orderStatus = @"取消订单";
      } else if ([self.order.status isEqualToString:@"2"]) {
        orderStatus = @"已确认订单";
      } else if ([self.order.status isEqualToString:@"3"]) {
        orderStatus = @"已经完成的订单";
      } else if ([self.order.status isEqualToString:@"5"]) {
        orderStatus = @"删除订单";
      }
      
      NSString *userInfo = [NSString stringWithFormat:@"客人所在区域: %@\n订单号: %@\n订单状态: %@\n客人名称: %@\n客人手机: %@\n入住时间: %@\n离店时间: %@\n房型: %@\n房价: %@\n", self.location, self.order.reservation_no, orderStatus, self.order.guest, self.order.guesttel, self.order.arrival_date, self.order.departure_date, self.order.room_type, self.order.room_rate];
      [self requestWaiterWithRuleType:@"CallCenter" andDescription:userInfo];  // 总机
      __weak __typeof(self) weakSelf = self;
      dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weakSelf showSystemFeedbackWithText:@"已在为您分配服务员,请稍候 :)"];
      });
      break;
    }
    case ChatService: {
      self.title = [NSString stringWithFormat:@"%@", self.shopName];
      [self setupShortcutView];
      [self setupNavigationBackButton];
      break;
    }
    case ChatOrder: {
      self.title = [NSString stringWithFormat:@"%@", self.shopName];
      [self setupNavigationBackButton];
      break;
    }
    default:
      break;
  }
//  [self setupShortcutView];
}

- (void)setupSessionID {
  self.sessionID = [[StorageManager sharedInstance] chatSession:self.shopID];
  if (!self.sessionID) {
    self.sessionID = [self newSessionID];
  }
}

- (void)updateShopMessageBadge {
  NSDictionary *shopMessageBadge = [StorageManager sharedInstance].shopMessageBadge;
  if (shopMessageBadge) {
    NSMutableDictionary *newShopMessageBadge = [NSMutableDictionary dictionaryWithDictionary:shopMessageBadge];
    if (newShopMessageBadge[self.shopID]) {
      newShopMessageBadge[self.shopID] = @0;
      [[StorageManager sharedInstance] updateShopMessageBadge:newShopMessageBadge];
    }
  }
}

- (void)showSystemFeedbackWithText:(NSString *)text {
  XHMessage *message;
  NSDate *timestamp = [NSDate date];
  message = [[XHMessage alloc] initWithText:text sender:@"系统" timestamp:timestamp];
  message.bubbleMessageType = XHBubbleMessageTypeReceiving;
  message.avatar = [UIImage imageNamed:@"ic_home_nor"];
  
  [Persistence.sharedInstance saveMessage:message shopID:self.shopID];
  
  [self.messages addObject:message];
  [self.messageTableView reloadData];
  [self scrollToBottomAnimated:NO];
}

- (void)sendCardWithTitle:(NSString *)title image:(UIImage *)image content:(NSString *)content {
  [self sendCardMessage];
  XHMessage *message = [[XHMessage alloc] initWithCardTitle:title image:image content:content sender:self.messageSender timestamp:[NSDate date]];
  message.bubbleMessageType = XHBubbleMessageTypeSending;
  message.messageMediaType = XHBubbleMessageMediaTypeCard;
  if ([JSHStorage baseInfo].avatarImage) {
    message.avatar = [JSHStorage baseInfo].avatarImage;
  } else {
    message.avatar = [UIImage imageNamed:@"ic_home_nor"];
  }
  
  [Persistence.sharedInstance saveMessage:message shopID:self.shopID];
  
  [self addMessage:message];
  [self finishSendMessageWithBubbleMessageType:XHBubbleMessageMediaTypeCard];
}

- (void)setupShortcutViewDataSource {
//0 OutOfRegion_NoOrder
//1 OutOfRegion_HasOrder_UnCheckin
//2 OutOfRegion_HasOrder_Checkin
//3 InRegion_NoOrder
//4 InRegion_HasOrder_UnCheckin
//5 InRegion_HasOrder_Checkin
   self.data = @{
   @"0": @{
         @"status": @"店外-无订单",
         @"actions": @[@{
                         @"name": @"订房",
                         @"ruletype": @"DefaultChatRuleType",
                         @"tags": @[@"大床房", @"双床房", @"高层房", @"无烟房", @"角落房", @"我要加床"]
                         },
                       @{
                         @"name": @"订餐",
                         @"ruletype": @"DefaultChatRuleType",
                         @"tags": @[@"中餐厅", @"西餐厅"]
                         },
                       @{
                         @"name": @"我的特权",
                         @"ruletype": @"DefaultChatRuleType",
                         @"tags": @[@"免前台", @"接送", @"客房定制"]
                         }
                       ]
         },
   @"1": @{
       @"status": @"店外-已发送/已确认",
       @"actions": @[@{
                       @"name": @"我的预订",
                       @"ruletype": @"DefaultChatRuleType",
                       @"tags": @[@"订单状态", @"修改订单", @"发票要求"]
                       },
                     @{
                       @"name": @"我的特权",
                       @"ruletype": @"DefaultChatRuleType",
                       @"tags": @[@"免前台", @"接送", @"客房定制"]
                      },
                     @{
                       @"name": @"我的推荐",
                       @"ruletype": @"DefaultChatRuleType",
                       @"tags": @[@"出行信息", @"旅游信息", @"娱乐信息"]
                      }
                     ]
       },
   @"2": @{
       @"status": @"店外-已入住",
       @"actions": @[@{
                       @"name": @"我的预订",
                       @"ruletype": @"DefaultChatRuleType",
                       @"tags": @[@"订单状态", @"修改订单", @"发票要求"]
                       },
                     @{
                       @"name": @"我的客房",
                       @"ruletype": @"DefaultChatRuleType",
                       @"tags": @[@"打扫", @"洗衣", @"订餐", @"加床", @"更换床品", @"添加物品"]
                       },
                     @{
                       @"name": @"我的推荐",
                       @"ruletype": @"DefaultChatRuleType",
                       @"tags": @[@"出行信息", @"旅游信息", @"娱乐信息"]
                       }
                     ]
       },
   @"3": @{
       @"status": @"店外-无订单",
         @"actions": @[@{
                         @"name": @"订房",
                         @"ruletype": @"DefaultChatRuleType",
                         @"tags": @[@"大床房", @"双床房", @"高层房", @"无烟房", @"角落房", @"我要加床"]
                         },
                       @{
                         @"name": @"订餐",
                         @"ruletype": @"DefaultChatRuleType",
                         @"tags": @[@"中餐厅", @"西餐厅"]
                         },
                       @{
                         @"name": @"我的特权",
                         @"ruletype": @"DefaultChatRuleType",
                         @"tags": @[@"免前台", @"接送", @"客房定制"]
                         }
                       ]
         },
   @"4": @{
       @"status": @"店外-已发送/已确认",
       @"actions": @[@{
                       @"name": @"我的预订",
                       @"ruletype": @"DefaultChatRuleType",
                       @"tags": @[@"订单状态", @"修改订单", @"发票要求"]
                       },
                     @{
                       @"name": @"我的特权",
                       @"ruletype": @"DefaultChatRuleType",
                       @"tags": @[@"免前台", @"接送", @"客房定制"]
                      },
                     @{
                       @"name": @"我的推荐",
                       @"ruletype": @"DefaultChatRuleType",
                       @"tags": @[@"出行信息", @"旅游信息", @"娱乐信息"]
                      }
                     ]
       },
   @"5": @{
       @"status": @"大堂-已入住",
       @"actions": @[@{
                       @"name": @"我的客房",
                       @"ruletype": @"DefaultChatRuleType",
                       @"tags": @[@"打扫", @"洗衣", @"订餐", @"加床", @"更换床品", @"添加物品"]
                       },
                     @{
                       @"name": @"我的消费",
                       @"ruletype": @"DefaultChatRuleType",
                       @"tags": @[@"我的账单", @"发票要求", @"预约退房"]
                       },
                     @{
                       @"name": @"我的推荐",
                       @"ruletype": @"DefaultChatRuleType",
                       @"tags": @[@"出行信息", @"旅游信息", @"娱乐信息"]
                       }
                     ]
       }
   };
}

- (void)setupSwitchButton {
  UIButton *switchButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0, 0.0, switchWidth, shortcutViewHeight)];
  [switchButton setImage:[UIImage imageNamed:@"ic_jianpan"] forState:UIControlStateNormal];
  [switchButton addTarget:self action:@selector(hideShortcutView) forControlEvents:UIControlEventTouchUpInside];
  switchButton.layer.borderWidth = 0.3;
  switchButton.layer.borderColor = [UIColor colorWithWhite:0.0 alpha:0.3].CGColor;
  [self.shortcutView addSubview:switchButton];
}

- (void)setupShortcutViewButtonAtIndex:(NSInteger)actionIndex buttonWidth:(CGFloat)buttonWidth buttonTitle:(NSString *)buttonTitle {
  UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(switchWidth + buttonWidth * actionIndex, 0.0, buttonWidth, shortcutViewHeight)];
  button.tag = actionIndex;
  [button setTitle:buttonTitle forState:UIControlStateNormal];
  [button setImage:[UIImage imageNamed:@"ic_liaotianmore"] forState:UIControlStateNormal];
  button.titleLabel.font = [UIFont systemFontOfSize:15.0];
  [button setTitleColor:[UIColor colorWithWhite:0.3 alpha:1.0] forState:UIControlStateNormal];
  [button setTitleColor:[UIColor colorWithWhite:0.3 alpha:0.6] forState:UIControlStateHighlighted];
  [button addTarget:self action:@selector(switchSubButtonView:) forControlEvents:UIControlEventTouchUpInside];
  button.layer.borderWidth = 0.3;
  button.layer.borderColor = [UIColor colorWithWhite:0.0 alpha:0.3].CGColor;
  button.titleEdgeInsets = UIEdgeInsetsMake(0.0, 8.0, 0.0, 0.0);
  [self.shortcutView addSubview:button];
}

- (void)setupSubButtons:(UIImageView *)subButtonView tags:(NSArray *)tags buttonWidth:(CGFloat)buttonWidth {
  NSInteger tagIndex = 0;
  for (NSString *tag in tags) {
    UIButton *subButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0, shortcutViewHeight * tagIndex, buttonWidth, shortcutViewHeight)];
    subButton.tag = tagIndex;
    [subButton setTitle:tag forState:UIControlStateNormal];
    if (tagIndex != (tags.count - 1)) {
      [subButton setBackgroundImage:[UIImage imageNamed:@"ic_liaotianline"] forState:UIControlStateNormal];
      [subButton setBackgroundImage:[UIImage imageNamed:@"ic_liaotianline"] forState:UIControlStateHighlighted];
    }
    subButton.titleLabel.font = [UIFont systemFontOfSize:15.0];
    [subButton setTitleColor:[UIColor colorWithWhite:0.3 alpha:1.0] forState:UIControlStateNormal];
    [subButton setTitleColor:[UIColor colorWithWhite:0.3 alpha:0.6] forState:UIControlStateHighlighted];
    [subButton addTarget:self action:@selector(didSelectedSubButton:) forControlEvents:UIControlEventTouchUpInside];
    [subButtonView addSubview:subButton];
    tagIndex++;
  }
}

- (void)setupSubButtonViewAtIndex:(NSInteger)actionIndex buttonWidth:(CGFloat)buttonWidth tags:(NSArray *)tags {
  UIImageView *subButtonView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ic_liaotiantankuang"]];
  subButtonView.userInteractionEnabled = YES;
  subButtonView.contentMode = UIViewContentModeScaleToFill;
  subButtonView.tag = actionIndex;
  CGFloat navigationBarHeight = self.navigationController.navigationBar.frame.size.height;
  CGFloat statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
  CGFloat viewWidth = buttonWidth;
  CGFloat viewHeight = shortcutViewHeight * tags.count + 25.0;
  CGFloat viewX = switchWidth + buttonWidth * actionIndex;
  CGFloat viewY = self.view.frame.size.height - viewHeight - navigationBarHeight - statusBarHeight - shortcutViewHeight;
  CGRect frame = subButtonView.frame;
  frame.origin = CGPointMake(viewX, viewY);
  frame.size = CGSizeMake(viewWidth, viewHeight);
  subButtonView.frame = frame;
  subButtonView.transform = CGAffineTransformTranslate(subButtonView.transform, 0.0, subButtonView.frame.size.height);
  subButtonView.hidden = YES;
  [self.view insertSubview:subButtonView aboveSubview:self.messageTableView];
  [self.subButtonViews addObject:subButtonView];
  
  [self setupSubButtons:subButtonView tags:tags buttonWidth:buttonWidth];
}

- (void)setupShortcutViewButtons {
  NSArray *actions = self.data[self.condition][@"actions"];
  NSInteger buttonNumber = actions.count;
  CGFloat buttonWidth = (self.view.frame.size.width - switchWidth) / buttonNumber;
  NSInteger actionIndex = 0;
  for (NSDictionary *action in actions) {
    NSString *buttonTitle = action[@"name"];
    [self setupShortcutViewButtonAtIndex:actionIndex buttonWidth:buttonWidth buttonTitle:buttonTitle];
    NSArray *tags = action[@"tags"];
    [self setupSubButtonViewAtIndex:actionIndex buttonWidth:buttonWidth tags:tags];
    actionIndex++;
  }
}

- (void)setupShortcutView {
  self.messageInputView.transform = CGAffineTransformTranslate(self.messageInputView.transform, 0.0, CGRectGetHeight(self.messageInputView.frame));
  self.messageInputView.hidden = YES;
  self.subButtonViews = [NSMutableArray array];
  
  self.shortcutView = [UIView new];
  self.shortcutView.backgroundColor = [UIColor whiteColor];
  [self.view addSubview:self.shortcutView];
  [self.shortcutView mas_makeConstraints:^(MASConstraintMaker *make) {
    UIView *superView = self.view;
    make.bottom.equalTo(superView.mas_bottom);
    make.leading.equalTo(superView.mas_leading);
    make.trailing.equalTo(superView.mas_trailing);
    make.height.equalTo([NSNumber numberWithFloat:shortcutViewHeight]);
  }];
  
  [self setupSwitchButton];
  [self setupShortcutViewButtons];
}

- (void)hideSubButtonViewAtIndex:(NSInteger)subButtonViewIndex {
  UIView *subButtonView = self.subButtonViews[subButtonViewIndex];
  if (!subButtonView.hidden) {
    [UIView animateWithDuration:0.1 animations:^{
      subButtonView.transform = CGAffineTransformTranslate(subButtonView.transform, 0.0, subButtonView.frame.size.height);
    } completion:^(BOOL finished) {
      if (finished) {
        subButtonView.hidden = YES;
      }
    }];
  }
}

- (void)hideAllSubButtonView {
  for (NSInteger index = 0; index < self.subButtonViews.count; index++) {
    [self hideSubButtonViewAtIndex:index];
  }
}

- (void)didSelectedSubButton:(UIButton *)sender {
  NSString *ruleType = self.data[self.condition][@"actions"][self.currentSubButtonViewIndex][@"ruletype"];
  NSLog(@"ruleType: %@ text: %@", ruleType, sender.titleLabel.text);
  [self requestWaiterWithRuleType:ruleType andDescription:sender.titleLabel.text];
  XHMessage *message = [[XHMessage alloc] initWithText:sender.titleLabel.text sender:self.messageSender timestamp:[NSDate date]];
  message.bubbleMessageType = XHBubbleMessageTypeSending;
  message.messageMediaType = XHBubbleMessageMediaTypeText;
  if ([JSHStorage baseInfo].avatarImage) {
    message.avatar = [JSHStorage baseInfo].avatarImage;
  } else {
    message.avatar = [UIImage imageNamed:@"ic_home_nor"];
  }
  [self addMessage:message];
  [self finishSendMessageWithBubbleMessageType:XHBubbleMessageMediaTypeText];
  
  [Persistence.sharedInstance saveMessage:message shopID:self.shopID];
  
  NSInteger subButtonViewIndex = self.currentSubButtonViewIndex;
  [self hideSubButtonViewAtIndex:subButtonViewIndex];
}

- (void)showShortcutView {
  [UIView animateWithDuration:0.3 animations:^{
    self.shortcutView.hidden = NO;
    self.shortcutView.transform = CGAffineTransformTranslate(self.shortcutView.transform, 0.0, -CGRectGetHeight(self.shortcutView.frame));
    
    self.messageInputView.transform = CGAffineTransformTranslate(self.messageInputView.transform, 0.0, CGRectGetHeight(self.messageInputView.frame));
  } completion:^(BOOL finished) {
    if (finished) {
      self.messageInputView.hidden = YES;
    }
  }];
}

- (void)hideShortcutView {
  [self hideAllSubButtonView];
  
  [UIView animateWithDuration:0.3 animations:^{
    self.messageInputView.hidden = NO;
    self.messageInputView.transform = CGAffineTransformTranslate(self.messageInputView.transform, 0.0, -CGRectGetHeight(self.messageInputView.frame));
    
    self.shortcutView.transform = CGAffineTransformTranslate(self.shortcutView.transform, 0.0, CGRectGetHeight(self.shortcutView.frame));
  } completion:^(BOOL finished) {
    if (finished) {
      self.shortcutView.hidden = YES;
    }
  }];
}

- (void)switchSubButtonView:(UIButton *)sender {
  self.currentSubButtonViewIndex = sender.tag;
  UIView *subButtonView = self.subButtonViews[sender.tag];
  if (subButtonView.hidden) {
    subButtonView.hidden = NO;
    [UIView animateWithDuration:0.1 animations:^{
      subButtonView.transform = CGAffineTransformTranslate(subButtonView.transform, 0.0, -subButtonView.frame.size.height);
    }];
  } else {
    [UIView animateWithDuration:0.1 animations:^{
      subButtonView.transform = CGAffineTransformTranslate(subButtonView.transform, 0.0, subButtonView.frame.size.height);
    } completion:^(BOOL finished) {
      if (finished) {
        subButtonView.hidden = YES;
      }
    }];
  }
  
  for (UIView *view in self.subButtonViews) {
    [UIView animateWithDuration:0.1 animations:^{
      if (view.tag != sender.tag && !view.hidden) {
        view.transform = CGAffineTransformTranslate(view.transform, 0.0, view.frame.size.height);
      }
    } completion:^(BOOL finished) {
      if (finished) {
        if (view.tag != sender.tag && !view.hidden) {
          view.hidden = YES;
        }
      }
    }];
  }
}

- (void)requestWaiterWithRuleType:(NSString *)ruleType andDescription:(NSString *)desc {
  NSNumber *timestamp = [NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970] * 1000];
  self.sessionID = [NSString stringWithFormat:@"%@_%@_%@", self.senderID, self.shopID, ruleType];
  NSLog(@"lastBeacon: %@", [StorageManager sharedInstance].lastBeacon);
  NSString *locid = @"";
  NSDictionary *beacon = [StorageManager sharedInstance].lastBeacon;
  if (beacon) {
    locid = beacon[@"locid"];
  }
  [[StorageManager sharedInstance] saveChatSession:self.sessionID shopID:self.shopID];
  NSDictionary *dictionary = @{
                               @"type": [NSNumber numberWithInteger:MessageServiceChatRequestWaiter_C2S],
                               @"timestamp": timestamp,
                               @"ruletype": ruleType,
                               @"clientid": self.senderID,
                               @"clientname": self.senderName,
                               @"shopid": self.shopID,
                               @"locid": locid,
                               @"desc": desc,
                               @"sessionid": self.sessionID
                               };
  [[ZKJSTCPSessionManager sharedInstance] sendPacketFromDictionary:dictionary];
}

- (void)loadDataSource {
  [ZKJSTool showLoading:@"正在加载聊天记录"];
  
  WEAKSELF
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    self.messages = [Persistence.sharedInstance fetchMessagesWithShopID:self.shopID userID:self.senderID beforeTimeStamp:[NSDate date]];
    dispatch_async(dispatch_get_main_queue(), ^{
      [weakSelf.messageTableView reloadData];
      [weakSelf scrollToBottomAnimated:NO];
      [ZKJSTool hideHUD];
      
      if (self.chatType == ChatNewSession) {
        NSString *content = [NSString stringWithFormat:@"%@ | %@入住 | %@晚", weakSelf.order.room_type, weakSelf.order.departure_date, weakSelf.order.dayInt];
        [weakSelf sendCardWithTitle:@"你好，帮我预定这间房" image:weakSelf.order.room_image content:content];
      }
    });
  });
}

//let timestamp = Int64(NSDate().timeIntervalSince1970 * 1000)
//    let dictionary: [String: AnyObject] = [
//      "type": MessageIMType.UserDefine.rawValue,
//      "timestamp": NSNumber(longLong: timestamp),
//      "fromid": JSHAccountManager.sharedJSHAccountManager().userid,
//      "toid": shopID,
//      "pushofflinemsg": 1,  // 用户不在线的处理 0:不处理离线 1:ios发送apns推送,android保存为离线消息
//      "pushalert": "请查看新的预定单",
//      "childtype": 1004,
//      "content": ""
//    ]
//ZKJSTCPSessionManager.sharedInstance().sendPacketFromDictionary(dictionary)

//// 用户发送预定单给商家
//int childtype = 1004
//String room_typeid;//房型ID
//String room_type;//房型
//String rooms;//房数
//String arrival_date;//入住日期
//String departure_date;//离店日期
//String manInStay;//预定人，多个预定人以‘，’隔开
- (void)sendCardMessage {
  NSMutableDictionary *content = [NSMutableDictionary dictionary];
  content[@"room_typeid"] = self.order.room_typeid;
  content[@"room_type"] = self.order.room_type;
  content[@"rooms"] = self.order.rooms;
  content[@"arrival_date"] = self.order.arrival_date;
  content[@"departure_date"] = self.order.departure_date;
  content[@"manInStay"] = self.order.guest;
  content[@"company"] = self.order.fullname;
  content[@"content"] = @"您好，帮我预定这间房";
  content[@"userid"] = self.senderID;
  content[@"image"] = self.order.room_image_URL;
  content[@"shopid"] = self.shopID;
  content[@"dayNum"] = self.order.dayInt;
  NSError *error;
  NSData *jsonData = [NSJSONSerialization dataWithJSONObject:content
                                                     options:0
                                                       error:&error];
  if (!jsonData) {
    NSLog(@"Got an error: %@", error);
  } else {
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSNumber *timestamp = [NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970] * 1000];
    NSDictionary *dictionary = @{
                                 @"type": [NSNumber numberWithInteger:MessageServiceChatCustomerServiceTextChat],
                                 @"timestamp": timestamp,
                                 @"fromid": self.senderID,
                                 @"fromname": self.senderName,
                                 @"clientid": self.senderID,
                                 @"clientname": self.senderName,
                                 @"shopid": self.shopID,
                                 @"sessionid": self.sessionID,
                                 @"childtype": @1,
                                 @"textmsg": jsonString
                                 };
    [[ZKJSTCPSessionManager sharedInstance] sendPacketFromDictionary:dictionary];
    NSLog(@"Send Card Message: %@", jsonString);
  }
}

- (void)sendTextMessage:(NSString *)text {
  NSNumber *timestamp = [NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970] * 1000];
  NSDictionary *dictionary = @{
                               @"type": [NSNumber numberWithInteger:MessageServiceChatCustomerServiceTextChat],
                               @"timestamp": timestamp,
                               @"fromid": self.senderID,
                               @"fromname": self.senderName,
                               @"clientid": self.senderID,
                               @"clientname": self.senderName,
                               @"shopid": self.shopID,
                               @"sessionid": self.sessionID,
                               @"childtype": @0,
                               @"textmsg": text
                               };
  [[ZKJSTCPSessionManager sharedInstance] sendPacketFromDictionary:dictionary];
}

- (void)sendVoiceMessage:(NSString *)voicePath {
  NSData *audioData = [[NSData alloc] initWithContentsOfFile:voicePath];
  NSString *body = [audioData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
  NSNumber *timestamp = [NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970] * 1000];
  NSString *format = @".aac";
  
  [[ZKJSHTTPChatSessionManager sharedInstance] uploadAudioWithFromID:self.senderID sessionID:self.sessionID shopID:self.shopID format:@"aac" body:body success:^(NSURLSessionDataTask *task, id responseObject) {
    NSDictionary *dictionary = @{
                                 @"type": [NSNumber numberWithInteger:MessageServiceChatCustomerServiceMediaChat],
                                 @"timestamp": timestamp,
                                 @"fromid": self.senderID,
                                 @"fromname": self.senderName,
                                 @"clientid": self.senderID,
                                 @"clientname": self.senderName,
                                 @"shopid": self.shopID,
                                 @"sessionid": self.sessionID,
                                 @"format": format,
                                 @"url": body
                                 };
    [[ZKJSTCPSessionManager sharedInstance] sendPacketFromDictionary:dictionary];
  } failure:^(NSURLSessionDataTask *task, NSError *error) {
    NSDictionary *dictionary = @{
                                 @"type": [NSNumber numberWithInteger:MessageServiceChatCustomerServiceMediaChat],
                                 @"timestamp": timestamp,
                                 @"fromid": self.senderID,
                                 @"fromname": self.senderName,
                                 @"clientid": self.senderID,
                                 @"clientname": self.senderName,
                                 @"shopid": self.shopID,
                                 @"sessionid": self.sessionID,
                                 @"format": format,
                                 @"body": body
                                 };
    [[ZKJSTCPSessionManager sharedInstance] sendPacketFromDictionary:dictionary];
  }];
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
                               @"fromname": self.senderName,
                               @"clientid": self.senderID,
                               @"clientname": self.senderName,
                               @"shopid": self.shopID,
                               @"sessionid": self.sessionID,
                               @"body": body
                               };
  [[ZKJSTCPSessionManager sharedInstance] sendPacketFromDictionary:dictionary];
}

- (void)dismissSelf {
  [self dismissViewControllerAnimated:YES completion:nil];
}

- (NSString *)newSessionID {
  return [NSString stringWithFormat:@"%@_%@_%@", self.senderID, self.shopID, @"DefaultChatRuleType"];
}

- (void)requestOfflineMessages {
  NSNumber *timestamp = [NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970] * 1000];
  NSDictionary *dictionary = @{
                               @"type": [NSNumber numberWithInteger:MessageServiceChatOfflineMssage],
                               @"timestamp": timestamp,
                               @"userid": self.senderID
                               };
  [[ZKJSTCPSessionManager sharedInstance] sendPacketFromDictionary:dictionary];
}

#pragma mark - Notifications

- (void)setupNotification {
  NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
  [center addObserver:self selector:@selector(showTextMessage:) name:@"MessageServiceChatCustomerServiceTextChatNotification" object:nil];
  [center addObserver:self selector:@selector(showImageMessage:) name:@"MessageServiceChatCustomerServiceImgChatNotification" object:nil];
  [center addObserver:self selector:@selector(showVoiceMessage:) name:@"MessageServiceChatCustomerServiceMediaChatNotification" object:nil];
}

- (void)sendReadAcknowledge:(NSDictionary *)userInfo {
  NSNumber *timestamp = [NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970] * 1000];
  NSDictionary *dictionary = @{
                               @"type": [NSNumber numberWithInteger:MessageServiceChatCustomerServiceSessionMsgReadAck],
                               @"timestamp": timestamp,
                               @"shopid": userInfo[@"shopid"],
                               @"seqid": userInfo[@"seqid"],
                               @"fromid": self.senderID,
                               @"toid": userInfo[@"fromid"]
                               };
  [[ZKJSTCPSessionManager sharedInstance] sendPacketFromDictionary:dictionary];
}

- (void)showTextMessage:(NSNotification *)notification {
  NSString *sender = notification.userInfo[@"fromname"];
  NSString *text = notification.userInfo[@"textmsg"];
  
  XHMessage *message;
  message = [[XHMessage alloc] initWithText:text sender:sender timestamp:[NSDate date]];
  message.bubbleMessageType = XHBubbleMessageTypeReceiving;
  message.messageMediaType = XHBubbleMessageMediaTypeText;
  message.avatar = [UIImage imageNamed:@"ic_home_nor"];
  
  [Persistence.sharedInstance saveMessage:message shopID:self.shopID];
  
  [self.messages addObject:message];
  [self.messageTableView reloadData];
  [self scrollToBottomAnimated:NO];
  
  if ([notification.userInfo[@"isreadack"] isEqual: @1]) {
    // 发送回执
    [self sendReadAcknowledge:notification.userInfo];
  }
}

- (void)showVoiceMessage:(NSNotification *)notification {
  NSString *sender = notification.userInfo[@"fromname"];
  NSString *body = notification.userInfo[@"body"];
  NSData *voiceData = [[NSData alloc] initWithBase64EncodedString:body options:NSDataBase64DecodingIgnoreUnknownCharacters];
  NSString *voicePath = [self getPlayPath];
  
  [voiceData writeToFile:voicePath atomically:NO];
  NSString *voiceDuration = [self getVoiceDuration:voicePath];
  
  XHMessage *message;
  NSDate *timestamp = [NSDate date];
  message = [[XHMessage alloc] initWithVoicePath:voicePath voiceUrl:nil voiceDuration:voiceDuration sender:sender timestamp:timestamp isRead:NO];
  message.bubbleMessageType = XHBubbleMessageTypeReceiving;
  message.messageMediaType = XHBubbleMessageMediaTypeVoice;
  message.avatar = [UIImage imageNamed:@"ic_home_nor"];
  
  [Persistence.sharedInstance saveMessage:message shopID:self.shopID];
  
  [self.messages addObject:message];
  [self.messageTableView reloadData];
  [self scrollToBottomAnimated:NO];
  
  if ([notification.userInfo[@"isreadack"] isEqual: @1]) {
    // 发送回执
    [self sendReadAcknowledge:notification.userInfo];
  }
}

- (void)showImageMessage:(NSNotification *)notification {
  NSString *sender = notification.userInfo[@"fromname"];
  NSString *body = notification.userInfo[@"body"];
  NSData *imageData = [[NSData alloc] initWithBase64EncodedString:body options:NSDataBase64DecodingIgnoreUnknownCharacters];
  UIImage *image = [UIImage imageWithData:imageData];
  
  XHMessage *message;
  NSDate *timestamp = [NSDate date];
  message = [[XHMessage alloc] initWithPhoto:image thumbnailUrl:nil originPhotoUrl:nil sender:sender timestamp:timestamp];
  message.bubbleMessageType = XHBubbleMessageTypeReceiving;
  message.messageMediaType = XHBubbleMessageMediaTypePhoto;
  message.avatar = [UIImage imageNamed:@"ic_home_nor"];
  
  [Persistence.sharedInstance saveMessage:message shopID:self.shopID];
  
  [self.messages addObject:message];
  [self.messageTableView reloadData];
  [self scrollToBottomAnimated:NO];
  
  if ([notification.userInfo[@"isreadack"] isEqual: @1]) {
    // 发送回执
    [self sendReadAcknowledge:notification.userInfo];
  }
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

#pragma mark - XHMessageInputViewDelegate

- (void)didSelectedSwitchAction {
  [super didSelectedSwitchAction];
  [self showShortcutView];
}

@end
