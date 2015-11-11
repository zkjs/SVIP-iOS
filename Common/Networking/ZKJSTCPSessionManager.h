//
//  ZKJSTCPSessionManager.h
//  BeaconMall
//
//  Created by Hanton on 5/11/15.
//  Copyright (c) 2015 zkjinshi. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, MessageIMType) {
  //登录
  MessageIMClientLogin     = 1,
  MessageIMClientLogin_RSP = 2,
  
  //登出
  MessageIMClientLogout     = 3,
  MessageIMClientLogout_RSP = 4,
  
  //心跳
  MessageIMHeartbeat = 5,
  
  //转移至新服务器
  MessageIMTransferServer = 200,
  
  //user重复连接时,踢走前,给旧连接发条消息
  MessageIMServerRepeatLogin = 6,
  
  //自定义用户协议
  MessageIMUserDefine = 7,
  MessageIMUserDefine_RSP = 8
};

typedef NS_ENUM(NSInteger, MessagePushType) {
  //依标签发起推送消息
  MessagePushPushTag     = 100,
  MessagePushPushTag_RSP = 101,
  
  //依商家定义区域推送内容
  MessagePushPushLocContent     = 102,
  MessagePushPushLocContent_RSP = 103,
  
  //查询商家定义区域推送内容
  MessagePushPushLocContentSearch     = 104,
  MessagePushPushLocContentSearch_RSP = 105,
  
  //当客户进入商家区域时,app端发起推送请求。
  MessagePushPushLoc_A2M     = 106, //android
  MessagePushPushLoc_A2M_RSP = 107,
  MessagePushPushLoc_IOS_A2M = 108, //ios触发
  
  //客人离店推送
  MessagePushPushLeaveLoc     = 231,
  MessagePushPushLeaveLoc_RSP = 232,
  
  //当客户端触发推消息时,发回反馈信息给服务端
  MessagePushPushTrack     = 109,
  MessagePushPushTrack_RSP = 110,
  
  //移除指定推送消息
  MessagePushPushMsgRemove     = 111,
  MessagePushPushMsgRemove_RSP = 112
};

typedef NS_ENUM(NSInteger, MessageQueueType) {
  //客户排队取号
  MessageQueueQueGetNo_C2M     = 50,
  MessageQueueQueGetNo_C2M_RSP = 51,
  MessageQueueQueGetNo_M2S     = 52, //转发给商家，有人取号及相关信息
  
  //客户查询队列状况
  MessageQueueQueSearchNo     = 53,
  MessageQueueQueSearchNo_RSP = 54,
  
  //应号
  MessageQueueQueConfirmNo_S2M     = 55, //商家向客户发出应号
  MessageQueueQueConfirmNo_S2M_RSP = 56,
  MessageQueueQueConfirmNo_M2C     = 57, // 消息服务器转发至客户
  
  //应号确认
  MessageQueueQueConfirmNoResult_C2M     = 58, //客户向商家发回应号确认结果
  MessageQueueQueConfirmNoResult_C2M_RSP = 59,
  MessageQueueQueConfirmNoResult_M2S     = 60, // 将客户结果转发至商家
  
  //商家手工销号
  MessageQueueQueShopPinNo     = 61,
  MessageQueueQueShopPinNo_RSP = 62,
  
  //解散/重置队列
  MessageQueueQueDisband     = 63,
  MessageQueueQueDisband_RSP = 64,
  
  //队列明细
  MessageQueueQueDetail     = 65,
  MessageQueueQueDetail_RSP = 66,
  
  //队列是否可取号状态
  MessageQueueQueStatus     = 67,
  MessageQueueQueStatus_RSP = 68,
  
  //客户手工销号(可用于客户取消排队或重排之类)
  MessageQueueQueUserPinNo_C2M     = 75, //客户向发出应号
  MessageQueueQueUserPinNo_C2M_RSP = 76,
  MessageQueueQueUserPinNo_M2S     = 77, // 消息服务器转发至商家
  
  //商家手工指定默认的排队预估等待时间
  MessageQueueQueDefWaiTime      = 78,
  MessageQueueQueDefWaitTime_RSP = 79
};

typedef NS_ENUM(NSInteger, MessageServiceType) {
  //将进入区域的客人信息广播给员工
  MessageServiceShopBroadcast_guest = 113, //客户app userid 广播
  //用于商家给员工发广播
  MessageServiceShopBroadcast_loc = 114,
  MessageServiceShopBroadcast_emp = 115,
  MessageServiceShopBroadcast_RSP = 116,
  MessageServiceShopBroadcast_M2C = 117,
  
  //在线员工设置上下班状态
  MessageServiceEmpWorkStatus_set     = 118,
  MessageServiceEmpWorkStatus_set_RSP = 119,
  //员工上下班状态
  MessageServiceEmpWorkStatus_search     = 120,
  MessageServiceEmpWorkStatus_search_RSP = 121,
  //商家员工情况列表
  MessageServiceShopEmplist     = 122,
  MessageServiceShopEmplist_RSP = 123,
  
  //酒店预订
  MessageServiceShopRes_form     = 124,
  MessageServiceShopRes_form_RSP = 125,
  //酒店确认信
  MessageServiceShopConf_letter     = 126,
  MessageServiceShopConf_letter_RSP = 127,
  //客户会员卡信息
  MessageServiceShopSendUsercard_loc = 128,
  MessageServiceShopSendUsercard_emp = 129,
  MessageServiceShopSendUsercard_RSP = 130,
  
  //将客人userid转发给员工
  MessageServiceShopBroadcast_M2E = 131,
  
  //ios触发 客人离店消息推送
  MessageServicePushLocLeave_IOS_A2M = 134,
  
  // 员工通知商家当前所处最靠近的BeaconID
  MessageServiceEmpUpdateLocal_E2S     = 139,
  MessageServiceEmpUpdateLocal_E2S_RSP = 140
};

typedef NS_ENUM(NSInteger, MessageServiceChatType) {
  // 客人呼叫服务
  MessageServiceChatRequestWaiter_C2S     = 135,
  MessageServiceChatRequestWaiter_C2S_RSP = 136,
  
  // 商家给客人指派员工
  MessageServiceChatShopAssignment_S2C     = 132,
  MessageServiceChatShopAssignment_S2C_RSP = 133,
  
  //文本
  MessageServiceChatCustomerServiceTextChat     = 141,
  MessageServiceChatCustomerServiceTextChat_RSP = 142,
  
  //语音
  MessageServiceChatCustomerServiceMediaChat     = 143,
  MessageServiceChatCustomerServiceMediaChat_RSP = 144,
  
  //图片
  MessageServiceChatCustomerServiceImgChat     = 145,
  MessageServiceChatCustomerServiceImgChat_RSP = 146,
  
  //消息回执
  MessageServiceChatCustomerServiceSessionMsgReadAck     = 212,
  MessageServiceChatCustomerServiceSessionMsgReadAck_RSP = 213,
  
  //得到离线消息
  MessageServiceChatOfflineMssage     = 227,
  MessageServiceChatOfflineMssage_RSP = 228,
  
  //客人在线状态
  MessageServiceChatClientChatOnlineStatus     = 229,
  MessageServiceChatClientChatOnlineStatus_RSP = 230
};


typedef NS_ENUM(NSInteger, MessagePaymentType) {
  //商家推送帐单至客户,并转发给客户
  MessagePaymentUserAccount_S2MC     = 72,
  MessagePaymentUserAccount_S2MC_RSP = 73, //商家帐单推送回应
  
  //当客人预订时,发出单号及客人userid至管理端
  MessagePaymentShopResform_C2S     = 203,
  MessagePaymentShopResform_C2S_RSP = 204,
  
  //当订单状态发生改变时,推送
  MessagePaymentShopOrderStatus_IOS     = 225,
  MessagePaymentShopOrderStatus_IOS_RSP = 226
};

typedef NS_ENUM(NSInteger, MessageUserDefineType) {
  MessageUserDefinePayment = 1001,
  MessageUserDefineShopCancelOrder = 1002,
  MessageUserDefineShopConfirmOrder = 1003,
  MessageUserDefineOfflineMessage = 1004,
  MessageUserDefineClientArrivalPushAd = 1005,
  MessageUserDefineInvitationCode = 1007
};

typedef NS_ENUM(NSInteger, MessageCustomType) {
  MessageCustomUserDefine = 7
};

@protocol TCPSessionManagerDelegate;

@interface ZKJSTCPSessionManager : NSObject

@property (nonatomic, weak) id<TCPSessionManagerDelegate> delegate;

// 单例
+ (instancetype)sharedInstance;
// 初始化Socket
- (void)initNetworkCommunicationWithIP:(NSString *)ip Port:(NSString *)port;
- (void)initNetworkCommunication;
// 释放Socket
- (void)deinitNetworkCommunication;
// 客户登录的接口
- (void)clientLogin:(NSString *)clientID name:(NSString *)name deviceToken:(NSString *)deviceToken;
// 商家登录的接口
- (void)shopLogin:(NSString *)shopID;
// 发包的接口
- (void)sendPacketFromDictionary:(NSDictionary *)dictionary;

@end

@protocol TCPSessionManagerDelegate <NSObject>
@required
// 已建立连接的接口
- (void)didOpenTCPSocket;
// 收包的接口
- (void)didReceivePacket:(NSDictionary *)dictionary;

@end
