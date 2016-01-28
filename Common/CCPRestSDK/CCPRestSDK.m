/*
 *  Copyright (c) 2014 The CCP project authors. All Rights Reserved.
 *
 *  Use of this source code is governed by a Beijing Speedtong Information Technology Co.,Ltd license
 *  that can be found in the LICENSE file in the root of the web site.
 *
 *                    http://www.yuntongxun.com
 *
 *  An additional intellectual property rights grant can be found
 *  in the file PATENTS.  All contributing project authors may
 *  be found in the AUTHORS file in the root of the source tree.
 */
#define kServerVersion  @"2013-12-26"

#import "CCPRestSDK.h"
#import <CommonCrypto/CommonDigest.h>
#import "ASIHTTPRequest.h"
#import "XMLReader.h"

@interface CCPRestSDK ()
{
    NSInteger LogFlag;
}
@end

@implementation CCPRestSDK


@synthesize server_IP;
@synthesize server_Port;
@synthesize bodyType;//EType_XML 0 xml,EType_JSON 1 json
@synthesize app_ID;
@synthesize main_Account;
@synthesize main_Token;
@synthesize sub_AccountSid;
@synthesize sub_AccountToken;
@synthesize voip_Account;
@synthesize voip_Password;

/*
 注意事项：
 使用我们的Rest SDK及Demo需要先获得帐号及应用信息，并使用这些信息完成SDK初始化
 操作，主帐号可以从开发者控制台获取，应用ID和子帐号可以使用Demo默认配置的也可以自己
 创建应用及子帐号（Demo帐号对电话号码有限制，只能对开发者控制台号码管理页面配置的号
 码发起业务请求）。
 */

/**
 * 初始化SDK
 * @param	serverIP        必选参数 : Rest服务器IP
 * @param	serverPort      必选参数 : Rest服务器端口
 * @return  返回Rest SDK对象
 */
-(id)initWithServerIP:(NSString*) serverIP andserverPort:(NSInteger) serverPort
{
    if (self = [super init])
    {
        self.bodyType = EType_XML;
        self.server_IP = serverIP;
        self.server_Port = serverPort;
    }
    return self;
}

/**
 * 设置主帐号
 * @param   accountSid      必选参数 : 主帐号
 * @param   accountToken    必选参数 : 主帐号令牌
 */
-(void)setAccountWithAccountSid:(NSString*) accountSid andAccountToken:(NSString*)accountToken
{
    self.main_Account = accountSid;
    self.main_Token = accountToken;
}
/**
 * 设置应用ID
 * @param   appId           必选参数 : 应用ID
 */
-(void)setAppId:(NSString*) appId
{
    self.app_ID = appId;
}

/**
 * 设置子帐号
 * @param   subAccountSid   必选参数 : 子帐号
 * @param   subAccountToken 必选参数 : 子帐号令牌
 * @param   voIPAccount     必选参数 : VoIP帐号
 * @param   voIPPassword    必选参数 : VoIP密码
 */
-(void)setSubAccountWithSubAccountSid:(NSString*) subAccountSid andSubAccountToken:(NSString*) subAccountToken andVoipAccount:(NSString*) voIPAccount andVoIPPassword:(NSString*)voIPPassword
{
    self.sub_AccountSid = subAccountSid;
    self.sub_AccountToken = subAccountToken;
    self.voip_Account = voIPAccount;
    self.voip_Password = voIPPassword;
}

#pragma mark - 帐号信息查询请求
/**
 * 帐号信息查询请求
 * @return  NSMutableDictionary对象
 */
- (NSMutableDictionary*)queryAccountInfo
{
    NSString *timestamp = [self getTimestamp];
    NSString *requestUrl = [NSString stringWithFormat:@"https://%@:%d/%@/Accounts/%@/AccountInfo?sig=%@",self.server_IP,(int)self.server_Port,kServerVersion,self.main_Account,[self getMainSig:timestamp]];
    NSMutableDictionary* ret = [self goRestUrlWithType:@"GET" andUrlStr:requestUrl andBodyData:nil andTimestamp:[self getMainAuthorization:timestamp]andRequestType:ERequestType_QueryAccountInfo];//注意最后一个参数是主帐号鉴权
    [self printLogWithName:@"queryAccountInfo" andUrl:requestUrl andRequest:nil andResponse:ret];
    return ret;
}

#pragma mark - 创建子帐号
/**
 * 创建子帐号
 * @param   friendlyName      必选参数 : 子帐号名称。可由英文字母和阿拉伯数字组成子帐号唯一名称，推荐使用电子邮箱地址
 * @return  NSMutableDictionary对象
 */
- (NSMutableDictionary*)createSubAccountWithFriendlyName:(NSString*)friendlyName
{
    NSString *timestamp = [self getTimestamp];
    NSString *requestUrl = [NSString stringWithFormat:@"https://%@:%d/%@/Accounts/%@/SubAccounts?sig=%@",self.server_IP,(int)self.server_Port,kServerVersion,self.main_Account,[self getMainSig:timestamp]];
    NSString *xmlBody = nil;
    if (self.bodyType == EType_XML)
        xmlBody = [NSString stringWithFormat:@"<SubAccount><appId>%@</appId><friendlyName>%@</friendlyName></SubAccount>",self.app_ID, friendlyName];
    else
        xmlBody = [NSString stringWithFormat:@"{'appId':'%@','friendlyName':'%@'}",self.app_ID, friendlyName];
    NSMutableDictionary* ret = [self goRestUrlWithType:@"POST" andUrlStr:requestUrl andBodyData:[xmlBody dataUsingEncoding:NSUTF8StringEncoding] andTimestamp:[self getMainAuthorization:timestamp]andRequestType:ERequestType_CreateSubAccount];//注意最后一个参数是主帐号鉴权
    [self printLogWithName:@"createSubAccount" andUrl:requestUrl andRequest:xmlBody andResponse:ret];//打印日志
    return ret;
}

#pragma mark - 获取子帐号
/**
 * 获取子帐号
 * @param   startNo      可选参数 : 开始的序号，默认从0开始
 * @param   offset       可选参数 : 一次查询的最大条数，最小是1条，最大是100条
 * @return  NSMutableDictionary对象
 */
- (NSMutableDictionary*)getSubAccountsWithStartNo:(NSInteger) startNo andOffset:(NSInteger)offset
{
    NSString *timestamp = [self getTimestamp];
    NSString *requestUrl = [NSString stringWithFormat:@"https://%@:%d/%@/Accounts/%@/GetSubAccounts?sig=%@",self.server_IP,(int)self.server_Port,kServerVersion,self.main_Account,[self getMainSig:timestamp]];
    NSString *xmlBody = nil;
    if (self.bodyType == EType_XML)
        xmlBody = [NSString stringWithFormat:@"<SubAccount><appId>%@</appId><startNo>%d</startNo><offset>%d</offset></SubAccount>",self.app_ID, (int)startNo,(int)offset];
    else
        xmlBody = [NSString stringWithFormat:@"{'appId':'%@','startNo':'%d','offset':'%d'}",self.app_ID, (int)startNo,(int)offset];
    NSMutableDictionary* ret = [self goRestUrlWithType:@"POST" andUrlStr:requestUrl andBodyData:[xmlBody dataUsingEncoding:NSUTF8StringEncoding] andTimestamp:[self getMainAuthorization:timestamp]andRequestType:ERequestType_GetSubAccounts];//注意最后一个参数是主帐号鉴权
    [self printLogWithName:@"getSubAccounts" andUrl:requestUrl andRequest:xmlBody andResponse:ret];//打印日志
    return ret;
}

#pragma mark - 子帐号信息查询
/**
 * 子帐号信息查询
 * @param   friendlyName      必选参数 : 子帐号名称
 * @return  NSMutableDictionary对象
 */

- (NSMutableDictionary*)querySubAccountWithFriendlyName:(NSString*) friendlyName
{
    NSString *timestamp = [self getTimestamp];
    NSString *requestUrl = [NSString stringWithFormat:@"https://%@:%d/%@/Accounts/%@/QuerySubAccountByName?sig=%@",self.server_IP,(int)self.server_Port,kServerVersion,self.main_Account,[self getMainSig:timestamp]];
    NSString *xmlBody = nil;
    if (self.bodyType == EType_XML)
        xmlBody = [NSString stringWithFormat:@"<SubAccount><appId>%@</appId><friendlyName>%@</friendlyName></SubAccount>",self.app_ID, friendlyName];
    else
        xmlBody = [NSString stringWithFormat:@"{'appId':'%@','friendlyName':'%@'}",self.app_ID, friendlyName];
    NSMutableDictionary* ret = [self goRestUrlWithType:@"POST" andUrlStr:requestUrl andBodyData:[xmlBody dataUsingEncoding:NSUTF8StringEncoding] andTimestamp:[self getMainAuthorization:timestamp]andRequestType:ERequestType_CreateSubAccount];//注意最后一个参数是主帐号鉴权
    [self printLogWithName:@"querySubAccount" andUrl:requestUrl andRequest:xmlBody andResponse:ret];//打印日志
    return ret;
}


#pragma mark - 发送短信
/**
 * 发送短信
 * @param   to      必选参数 : 短信接收端手机号码集合，用英文逗号分开，每批发送的手机号数量不得超过100个
 * @param   body    必选参数 : 短信正文
 * @return  NSMutableDictionary对象
 */
- (NSMutableDictionary*)sendSMSWithTo:(NSString*)to andBody:(NSString*)body
{
    NSString *timestamp = [self getTimestamp];
    NSString *requestUrl = [NSString stringWithFormat:@"https://%@:%d/%@/Accounts/%@/SMS/Messages?sig=%@",self.server_IP,(int)self.server_Port,kServerVersion,self.main_Account,[self getMainSig:timestamp]];
    NSString *xmlBody = nil;
    if (self.bodyType == EType_XML)
        xmlBody = [NSString stringWithFormat:@"<SubAccount><to>%@</to><body>%@</body><appId>%@</appId></SubAccount>",to,body,self.app_ID];
    else
        xmlBody = [NSString stringWithFormat:@"{\"to\":\"%@\",\"body\":\"%@\",\"appId\":\"%@\"}",to,body,self.app_ID];
    NSMutableDictionary* ret = [self goRestUrlWithType:@"POST" andUrlStr:requestUrl andBodyData:[xmlBody dataUsingEncoding:NSUTF8StringEncoding] andTimestamp:[self getMainAuthorization:timestamp]andRequestType:ERequestType_SendSMS];//注意最后一个参数是主帐号鉴权
    [self printLogWithName:@"sendSMS" andUrl:requestUrl andRequest:xmlBody andResponse:ret];//打印日志
    return ret;
}

#pragma mark - 发送模板短信
/**
 * 发送模板短信
 * @param   to              必选参数 : 短信接收端手机号码集合，用英文逗号分开，每批发送的手机号数量不得超过100个
 * @param   templateId      必选参数 : 模板Id
 * @param   datas           可选参数 : 数组类型，内部数组元素内含消息内容数据，用于替换模板中{序号}
 * @return  xml或json包体字符串
 */
- (NSMutableDictionary*)sendTemplateSMSWithTo:(NSString*)to andTemplateId:(NSString*)templateId andDatas:(NSArray*)datas
{
    NSMutableString *strTemp  = [[NSMutableString alloc] init];
    int index = 0;
    for (NSString* strData in datas)
    {
        if (self.bodyType == EType_XML)
            [strTemp appendString:[NSString stringWithFormat:@"<data>%@</data>",strData]];
        else
        {
            if (index ==0)
                [strTemp appendString:[NSString stringWithFormat:@"\"%@\"",strData]];
            else
                [strTemp appendString:[NSString stringWithFormat:@",\"%@\"",strData]];
            index++;
        }
    }
    NSString* strDatas = @"";
    if ([strTemp length]>0)
    {
        strDatas =  [NSString stringWithFormat:@"%@",strTemp];
    }
    NSString *timestamp = [self getTimestamp];
    NSString *requestUrl = [NSString stringWithFormat:@"https://%@:%d/%@/Accounts/%@/SMS/TemplateSMS?sig=%@",self.server_IP,(int)self.server_Port,kServerVersion,self.main_Account,[self getMainSig:timestamp]];
    NSString *xmlBody = nil;
    if (self.bodyType == EType_XML)
        xmlBody = [NSString stringWithFormat:@"<TemplateSMS><to>%@</to><templateId>%@</templateId><datas>%@</datas><appId>%@</appId></TemplateSMS>",to,templateId,strDatas,self.app_ID];
    else
        xmlBody = [NSString stringWithFormat:@"{\"to\":\"%@\",\"appId\":\"%@\",\"templateId\":\"%@\",\"datas\":[%@]}",to,self.app_ID,templateId,strDatas];
    NSMutableDictionary* ret = [self goRestUrlWithType:@"POST" andUrlStr:requestUrl andBodyData:[xmlBody dataUsingEncoding:NSUTF8StringEncoding] andTimestamp:[self getMainAuthorization:timestamp]andRequestType:ERequestType_SendTemplateSMS];//注意最后一个参数是主帐号鉴权
    [self printLogWithName:@"sendTemplateSMS" andUrl:requestUrl andRequest:xmlBody andResponse:ret];//打印日志
    return ret;
}

#pragma mark - 双向回拨
/**
 * 双向回拨 (显号设置需要云平台开放相关权限)
 * @param   from                必选参数 : 主叫电话号码
 * @param   to                  必选参数 : 被叫电话号码
 * @param   customerSerNum      可选参数 : 被叫侧显示的客服号码，根据平台侧显号规则控制。
 * @param   fromSerNum          可选参数 : 主叫侧显示的号码，根据平台侧显号规则控制
 * @param   promptTone          可选参数 : 第三方自定义回拨提示音
 * @return  NSMutableDictionary对象
 */
- (NSMutableDictionary*)callBackWithFrom:(NSString*)from andTo:(NSString*)to andCustomerSerNum:(NSString*)customerSerNum andFromSerNum:(NSString*)fromSerNum andPromptTone:(NSString*)promptTone
{
    NSMutableDictionary* ret = [self checkSubAccount];
    NSString *timestamp = [self getTimestamp];
    NSString *requestUrl =[NSString stringWithFormat:@"https://%@:%d/%@/SubAccounts/%@/Calls/Callback?sig=%@",self.server_IP,(int)self.server_Port,kServerVersion,self.sub_AccountSid,[self getSubSig:timestamp]];;
    NSString* srcStr  = @"";
    NSString* destStr = @"";
    NSString* promptToneStr = @"";
    if ([customerSerNum length] > 0)
    {
        if (self.bodyType == EType_XML)
            destStr = [NSString stringWithFormat:@"<customerSerNum>%@</customerSerNum>" ,customerSerNum];
        else
            destStr = [NSString stringWithFormat:@",\"customerSerNum\":\"%@\"" ,customerSerNum];
    }
    
    if ([fromSerNum length] > 0)
    {
        if (self.bodyType == EType_XML)
            srcStr = [NSString stringWithFormat:@"<fromSerNum>%@</fromSerNum>" ,fromSerNum];
        else
            srcStr = [NSString stringWithFormat:@",\"fromSerNum\":\"%@\"" ,fromSerNum];
    }
    
    if ([promptTone length] > 0)
    {
        if (self.bodyType == EType_XML)
            promptToneStr = [NSString stringWithFormat:@"<promptTone>%@</promptTone>" ,fromSerNum];
        else
            promptToneStr = [NSString stringWithFormat:@",\"promptTone\":\"%@\"" ,promptTone];
    }
    NSString *xmlBody = nil;
    if (self.bodyType == EType_XML)
        xmlBody = [NSString stringWithFormat:@"<CallBack><from>%@</from><to>%@</to>%@%@%@</CallBack>",from,to,srcStr,destStr,promptToneStr];
    else
        xmlBody = [NSString stringWithFormat:@"{\"from\":\"%@\",\"to\":\"%@\"%@%@%@}",from,to,srcStr,destStr,promptToneStr];
    ret = [self goRestUrlWithType:@"POST" andUrlStr:requestUrl andBodyData:[xmlBody dataUsingEncoding:NSUTF8StringEncoding] andTimestamp:[self getSubAuthorization:timestamp]andRequestType:ERequestType_CallBack];//注意最后一个参数是子帐号鉴权
    [self printLogWithName:@"callBack" andUrl:requestUrl andRequest:xmlBody andResponse:ret];//打印日志
    return ret;
}

#pragma mark - 发起外呼通知
/**
 * 发起外呼通知
 * @param     to            必选参数 : 被叫号码
 * @param	  mediaName     可选参数 : 语音文件名称，格式 wav。与mediaTxt不能同时为空，不为空时mediaTxt属性失效。
 * @param     mediaTxt      可选参数 : 文本内容，默认值为空。
 * @param     displayNum	可选参数 : 显示的主叫号码，显示权限由服务侧控制。
 * @param     playTimes	 	必选参数 : 循环播放次数，1－3次
 * @param     type          可选参数 : 如果传入type等于1，则播放默认语音文件
 * @param     respUrl	 	可选参数 : 外呼通知状态通知回调地址，云通讯平台将向该Url地址发送呼叫结果通知。
 * @return    NSMutableDictionary对象
 */
- (NSMutableDictionary*)landingCallWithTo:(NSString*)to andMediaName:(NSString*)mediaName andMediaTxt:(NSString*)mediaTxt andDisplayNum:(NSString*)displayNum andPlayTimes:(NSInteger)playTimes andType:(NSInteger) type andRespUrl:(NSString*)respUrl
{
    NSString *timestamp = [self getTimestamp];
    NSString *requestUrl = [NSString stringWithFormat:@"https://%@:%d/%@/Accounts/%@/Calls/LandingCalls?sig=%@",self.server_IP,(int)self.server_Port,kServerVersion,self.main_Account,[self getMainSig:timestamp]];
    NSString *xmlBody = nil;
    NSString* strRespUrl = @"";
    if ([respUrl length]>0)
    {
        strRespUrl = respUrl;
    }
    NSString* strMediaName = @"";
    if (self.bodyType == EType_XML)
    {
        if (type==1)
        {
            strMediaName = [NSString stringWithFormat:@"<mediaName type=\"1\">%@</mediaName>",@"ccp_marketingcall.wav"];
        }
        else
            strMediaName = [NSString stringWithFormat:@"<mediaName type=\"0\">%@</mediaName>",mediaName];
            
        xmlBody = [NSString stringWithFormat:@"<LandingCall><appId>%@</appId><to>0086%@</to>%@<mediaTxt>%@</mediaTxt><displayNum>%@</displayNum><playTimes>%d</playTimes><respUrl>%@</respUrl></LandingCall>",self.app_ID,to,strMediaName,mediaTxt,displayNum,(int)playTimes,strRespUrl];
    }
    else
    {
        if (type==1)
        {
            strMediaName = @"\"mediaName\":\"ccp_marketingcall.wav\",\"mediaNameType\":\"1\"";
        }
        else
            strMediaName = [NSString stringWithFormat:@"\"mediaName\":\"%@\",\"mediaNameType\":\"0\"",mediaName];
        
        xmlBody = [NSString stringWithFormat:@"{\"to\":\"%@\",\"appId\":\"%@\",%@,\"mediaTxt\":\"%@\",\"displayNum\":\"%@\",\"playTimes\":\"%d\",\"respUrl\":\"%@\"}", to,self.app_ID,strMediaName,mediaTxt,displayNum,(int)playTimes,strRespUrl];
    }
    NSMutableDictionary* ret = [self goRestUrlWithType:@"POST" andUrlStr:requestUrl andBodyData:[xmlBody dataUsingEncoding:NSUTF8StringEncoding] andTimestamp:[self getMainAuthorization:timestamp]andRequestType:ERequestType_LandingCall];//注意最后一个参数是主帐号鉴权
    [self printLogWithName:@"landingCall" andUrl:requestUrl andRequest:xmlBody andResponse:ret];//打印日志
    return ret;
}

#pragma mark - 发起语音验证码请求
/**
 * 发起语音验证码请求
 * @param   verifyCode      必选参数 : 验证码内容，为数字和英文字母，不区分大小写，长度4-20位
 * @param   to              必选参数 : 接收验证码的手机、座机号码
 * @param   displayNum      可选参数 : 显示主叫号码，显示权限由服务侧控制
 * @param   playTimes       必选参数 : 播放次数，1－3次
 * @param   respUrl         可选参数 : 用户发起语音验证码请求后，云通讯平台将向该url地址发送呼叫结果通知
 * @return  NSMutableDictionary对象
 */
- (NSMutableDictionary*)voiceVerifyWithVerifyCode:(NSString*)verifyCode andTo:(NSString*)to andDisplayNum:(NSString*)displayNum andPlayTimes:(int) playTimes andRespUrl:(NSString*)respUrl
{
    NSString *timestamp = [self getTimestamp];
    NSString *requestUrl = [NSString stringWithFormat:@"https://%@:%d/%@/Accounts/%@/Calls/VoiceVerify?sig=%@",self.server_IP,(int)self.server_Port,kServerVersion,self.main_Account,[self getMainSig:timestamp]];
    NSString *xmlBody = nil;
    NSString* strDisplayNum = @"";
    if ([displayNum length]>0)
    {
        strDisplayNum = displayNum;
    }
    NSString* strRespUrl = @"";
    if ([respUrl length]>0)
    {
        strRespUrl = respUrl;
    }
    
    if (self.bodyType == EType_XML)
        xmlBody = [NSString stringWithFormat:@"<VoiceVerify><appId>%@</appId><verifyCode>%@</verifyCode><playTimes>%d</playTimes><to>%@</to><displayNum>%@</displayNum><respUrl>%@</respUrl></VoiceVerify>",self.app_ID,verifyCode,playTimes,to,strDisplayNum,strRespUrl];
    else
        xmlBody = [NSString stringWithFormat:@"{\"appId\":\"%@\",\"verifyCode\":\"%@\",\"playTimes\":\"%d\",\"to\":\"%@\",\"displayNum\":\"%@\",\"respUrl\":\"%@\"}",self.app_ID,verifyCode,playTimes,to,strDisplayNum,strRespUrl];
    NSMutableDictionary* ret = [self goRestUrlWithType:@"POST" andUrlStr:requestUrl andBodyData:[xmlBody dataUsingEncoding:NSUTF8StringEncoding] andTimestamp:[self getMainAuthorization:timestamp]andRequestType:ERequestType_VoiceVerify];//注意最后一个参数是主帐号鉴权
    [self printLogWithName:@"voiceVerify" andUrl:requestUrl andRequest:xmlBody andResponse:ret];//打印日志
    return ret;
}

#pragma mark - IVR外呼
/**
 * IVR外呼
 * @param   number          必选参数 : 待呼叫号码，为Dial节点的属性
 * @param   userdata        可选参数 : 用户数据，在<startservice>通知中返回，只允许填写数字字符，为Dial节点的属性
 * @param   record          必选参数 : 是否录音，可填项为YES和NO，默认值为NO不录音，为Dial节点的属性
 * @return  NSMutableDictionary对象
 */
- (NSMutableDictionary*)ivrDialWithNumber:(NSString*)number andUserdata:(NSString*)userdata andRecord:(BOOL)record
{
    NSString *timestamp = [self getTimestamp];
    NSString *requestUrl =[NSString stringWithFormat:@"https://%@:%d/%@/Accounts/%@/ivr/dial?sig=%@",self.server_IP,(int)self.server_Port,kServerVersion,self.main_Account,[self getMainSig:timestamp]];;
    NSString* strRecord    = @"false";
    if (record)
    {
        strRecord = @"ture";
    }
    if(self.bodyType == EType_JSON)
    {
        self.bodyType = EType_XML;
        if (LogFlag == 1)
            NSLog(@"该接口不支持JSON方式！已经转换为XML方式");
    }
    NSString *xmlBody = [NSString stringWithFormat:@"<Request><Appid>%@</Appid><Dial number=\"%@\" userdata=\"%@\" record=\"%@\"></Dial></Request>",self.app_ID, number,userdata,strRecord];
    NSMutableDictionary* ret = [self goRestUrlWithType:@"POST" andUrlStr:requestUrl andBodyData:[xmlBody dataUsingEncoding:NSUTF8StringEncoding] andTimestamp:[self getMainAuthorization:timestamp]andRequestType:ERequestType_IvrDial];//注意最后一个参数是住帐号鉴权
    [self printLogWithName:@"ivrDial" andUrl:requestUrl andRequest:xmlBody andResponse:ret];//打印日志
    return ret;
}

#pragma mark - 话单下载
/**
 * 话单下载 （话单下载是云通讯平台为开发者提供的话单获取通道，通过此接口开发者可以获取前一天、前一周、前一个月的话单数据）
 * @param   date        必选参数 : 用户数据，在<startservice>通知中返回，只允许填写数字字符，为Dial节点的属性
 * @param   keywords    可选参数 : 客户的查询条件，由客户自行定义并提供给云通讯平台。默认不填忽略此参数
 * @return  NSMutableDictionary对象
 */
- (NSMutableDictionary*)billRecordsWithDate:(NSString*)date andKeywords:(NSString*)keywords
{
    NSString *timestamp = [self getTimestamp];
    NSString *requestUrl =[NSString stringWithFormat:@"https://%@:%d/%@/Accounts/%@/BillRecords?sig=%@",self.server_IP,(int)self.server_Port,kServerVersion,self.main_Account,[self getMainSig:timestamp]];;
    
    NSString *xmlBody = nil;
    if (self.bodyType == EType_XML)
        xmlBody = [NSString stringWithFormat:@"<BillRecords><appId>%@</appId><date>%@</date><keywords>%@</keywords></BillRecords>",self.app_ID, date,keywords];
    else
        xmlBody = [NSString stringWithFormat:@"{\"appId\":\"%@\",\"date\":\"%@\",\"keywords\":\"%@\"}",self.app_ID, date,keywords];
    NSMutableDictionary* ret = [self goRestUrlWithType:@"POST" andUrlStr:requestUrl andBodyData:[xmlBody dataUsingEncoding:NSUTF8StringEncoding] andTimestamp:[self getMainAuthorization:timestamp]andRequestType:ERequestType_BillRecords];//注意最后一个参数是住帐号鉴权
    [self printLogWithName:@"billRecords" andUrl:requestUrl andRequest:xmlBody andResponse:ret];//打印日志
    return ret;
}

#pragma mark - 日志开关
/**
 * 日志开关
 * @param   enableLog        必选参数 : 是否输出日志，YES输出
 */
-(void) enableLog:(BOOL)enable
{
    if (enable)
    {
        LogFlag = 1;
    }
    else
        LogFlag = 0;
}

#pragma mark - 内部函数
//包装返回值为NSMutableDictionary
-(NSMutableDictionary*)builderWithCode:(NSInteger)code andMsg:(NSString*)msg
{
    NSMutableDictionary* dictRet = [[NSMutableDictionary alloc] init];
    NSString* strCode = @"000000";
    if (code != 0)
    {
        strCode = [NSString stringWithFormat:@"%d",(int)code];
    }
    [dictRet setObject:strCode forKey:@"statusCode"];
    NSString* strMsg = nil;
    if (code == 0 && !msg)
    {
        strMsg = @"成功";
    }
    else
        strMsg = msg;
    [dictRet setObject:strMsg forKey:@"statusMsg"];
    return dictRet;
}

//解析返回数据
-(NSMutableDictionary*)builderWithBody:(NSData*)responseData andRequestType:(ERequestType)requestType
{
    NSString * body = [[NSString alloc] initWithData:(NSData *)responseData  encoding:NSUTF8StringEncoding];
    if (LogFlag == 1)
        NSLog(@"%@",body);
    NSInteger status = 0;
    NSString* strStatusCode = nil;
    NSString* strMsg = nil;
    NSMutableDictionary* dataDict = nil;
    NSError *parseError = nil;
    if (bodyType == EType_XML)
    {
        NSMutableDictionary *xmlDictionary = [XMLReader dictionaryForXMLData:responseData error:&parseError];
        if (xmlDictionary)
        {
            NSMutableDictionary* tmpDict = [xmlDictionary objectForKey:@"Response"];
            if (tmpDict)
            {
                strStatusCode = [[tmpDict objectForKey:@"statusCode"] objectForKey:@"text"];
                if ([strStatusCode length] <=0)
                {
                    return [self builderWithCode:ECloopenRestSDK_BodyErr andMsg:@"返回包体错误"];
                }
                status = [strStatusCode integerValue];
                strMsg = [[tmpDict objectForKey:@"statusMsg"] objectForKey:@"text"];
                
                [self convertDictWithData:tmpDict];
                dataDict = [NSMutableDictionary dictionaryWithDictionary:tmpDict];
            }
            else
                return [self builderWithCode:ECloopenRestSDK_BodyErr andMsg:@"返回包体错误"];
        }
        else
        {
            if (LogFlag == 1)
                NSLog(@"解析XML出错，%@",parseError);
            return [self builderWithCode:ECloopenRestSDK_BodyErr andMsg:@"返回包体错误"];
        }
        
        
    }
    else
    {
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&parseError];
        if (dict)
        {
            strStatusCode = [dict objectForKey:@"statusCode"];
            if ([strStatusCode length] <=0)
            {
                return [self builderWithCode:ECloopenRestSDK_BodyErr andMsg:@"返回包体错误"];
            }
            status = [strStatusCode integerValue];
            strMsg = [dict objectForKey:@"statusMsg"];
            dataDict = [NSMutableDictionary dictionaryWithDictionary:dict];
        }
        else
        {
            return [self builderWithCode:ECloopenRestSDK_BodyErr andMsg:@"返回包体错误"];
//            if (LogFlag == 1)
//                NSLog(@"解析JSON出错，%@",parseError);
        }

    }
    
    NSMutableDictionary* dictRet = [self builderWithCode:status andMsg:strMsg];
    if (dataDict)
    {
        [dataDict removeObjectForKey:@"statusCode"];
        [dataDict removeObjectForKey:@"statusMsg"];
    }
    
    if ([[dataDict allKeys] count]>0)
    {
        [dictRet setValue:dataDict forKey:@"data"];
    }
    return dictRet;
}

//转换处理NSMutableDictionary的数据
-(void)convertDictWithData:(NSMutableDictionary*) dataDict
{
    NSArray* array= [dataDict allKeys];
    for (NSString *key in array)
    {
        NSMutableDictionary* subItem = [dataDict objectForKey:key];
        if ([subItem isKindOfClass:[NSMutableDictionary class]])
        {
            NSMutableDictionary* subDict = (NSMutableDictionary*)subItem;
            NSString * text = [subDict objectForKey:@"text"];
            if (text)
            {
                [dataDict removeObjectForKey:key];
                [dataDict setObject:text forKey:key];
            }
            else
            {
                [self convertDictWithData:subDict];
            }
        }
        else if ([subItem isKindOfClass:[NSMutableArray class]])
        {
            NSMutableArray* subArr = (NSMutableArray*)subItem;
            for (NSMutableDictionary* dict in subArr)
            {
                [self convertDictWithData:dict];
            }
        }
    }
    return;
}

//检查初始化
-(NSMutableDictionary*)checkInitValue
{
    if ([self.app_ID length]<=0 )
    {
        return [self builderWithCode:ECloopenRestSDK_AppIDNull andMsg:@"应用ID为空"];
    }
    if ([self.server_IP length]<=0)
    {
        return [self builderWithCode:ECloopenRestSDK_IPNull andMsg:@"IP为空"];
    }
    if (self.server_Port <=0)
    {
        return [self builderWithCode:ECloopenRestSDK_PortErr andMsg:@"端口错误"];
    }
    if ([self.main_Account length]<=0)
    {
        return [self builderWithCode:ECloopenRestSDK_AccountNull andMsg:@"主帐号为空"];
    }
    if ([self.main_Token length]<=0 )
    {
        return [self builderWithCode:ECloopenRestSDK_AccountTokenNull andMsg:@"主帐号令牌为空"];
    }
    return nil;
}

//检查子帐号
-(NSMutableDictionary*)checkSubAccount
{
    if ([self.sub_AccountSid length]<=0)
    {
        return [self builderWithCode:ECloopenRestSDK_SubAccountNull andMsg:@"子帐号为空"];
    }
    if (self.sub_AccountToken <=0)
    {
        return [self builderWithCode:ECloopenRestSDK_SubAccountTokenNull andMsg:@"子帐号令牌为空"];
    }
    else if ([self.voip_Account length]<=0)
    {
        return [self builderWithCode:ECloopenRestSDK_VoIPAccountNull andMsg:@"VoIP帐号为空"];
    }
    if ([self.voip_Password length]<=0 )
    {
        return [self builderWithCode:ECloopenRestSDK_VoIPPassWordNull andMsg:@"VoIP密码为空"];
    }
    return nil;
}

//发起rest请求
-(NSMutableDictionary*)goRestUrlWithType:(NSString*)type andUrlStr:(NSString*) urlStr andBodyData:(NSData*) bodyData andTimestamp:(NSString*)timestamp andRequestType:(ERequestType) requestType
{
    NSMutableDictionary *ret = nil;
    if (requestType == ERequestType_CallBack)
    {
        if ([self.app_ID length]<=0 )
        {
            return [self builderWithCode:ECloopenRestSDK_AppIDNull andMsg:@"应用ID为空"];
        }
    }
    else
        ret =[self checkInitValue];
    if(ret)
        return ret;
    NSString* strBodyType = @"";
    if (self.bodyType == EType_XML)
    {
        strBodyType = @"xml";
    }
    else
    {
        strBodyType = @"json";
    }
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:urlStr]];
    request.requestType = requestType;
    if ([type isEqualToString:@"POST"])
        [request setRequestMethod:@"POST"];
    else
        [request setRequestMethod:@"GET"];    
    [request addRequestHeader:@"Accept" value:[NSString stringWithFormat:@"application/%@",strBodyType]];
    [request addRequestHeader:@"Content-Type" value:[NSString stringWithFormat:@"application/%@;charset=utf-8",strBodyType]];
    [request addRequestHeader:@"Authorization" value:timestamp];
    [request appendPostData:bodyData];
    [request setDelegate:self];
    [request setValidatesSecureCertificate:NO];
    [request startSynchronous];
    NSData *received = request.responseData;
    NSString* strResponse = [[NSString alloc]initWithData:received encoding:NSUTF8StringEncoding];
    if (request.error)
    {
        return [self builderWithCode:ECloopenRestSDK_NetErr andMsg:@"网络错误"];
    }
    else if ([strResponse length] <=0)
    {
        return [self builderWithCode:ECloopenRestSDK_NoResNull andMsg:@"无返回包体"];
    }
    else
    {
        NSMutableDictionary* retDict = [self builderWithBody:received andRequestType:requestType];
        if (retDict)
        {
            [retDict setObject:strResponse forKey:@"ResponseBody"];
            return retDict;
        }
    }
    return nil;
}

//得到当前时间的字符串
- (NSString *)getTimestamp
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMddHHmmss"];
    NSString *currentDateStr = [dateFormatter stringFromDate:[NSDate date]];
    return currentDateStr;
}

//base64编码
- (NSString*)base64forData:(NSData*)theData {
	
	const uint8_t* input = (const uint8_t*)[theData bytes];
	NSInteger length = [theData length];
	
    static char table[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";
	
    NSMutableData* data = [NSMutableData dataWithLength:((length + 2) / 3) * 4];
    uint8_t* output = (uint8_t*)data.mutableBytes;
	
	NSInteger i,i2;
    for (i=0; i < length; i += 3) {
        NSInteger value = 0;
		for (i2=0; i2<3; i2++) {
            value <<= 8;
            if (i+i2 < length) {
                value |= (0xFF & input[i+i2]);
            }
        }
		
        NSInteger theIndex = (i / 3) * 4;
        output[theIndex + 0] =                    table[(value >> 18) & 0x3F];
        output[theIndex + 1] =                    table[(value >> 12) & 0x3F];
        output[theIndex + 2] = (i + 1) < length ? table[(value >> 6)  & 0x3F] : '=';
        output[theIndex + 3] = (i + 2) < length ? table[(value >> 0)  & 0x3F] : '=';
    }
	
    return [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
}

//根据子帐号sid和当前时间字符串获取一个Authorization编码
- (NSString *)getSubAuthorization:(NSString *)timestamp
{
    NSString *authorizationString = [NSString stringWithFormat:@"%@:%@",self.sub_AccountSid,timestamp];
    return [self base64forData:[authorizationString dataUsingEncoding:NSUTF8StringEncoding]];
}

//根据主帐号sid和当前时间字符串获取一个Authorization编码
- (NSString *)getMainAuthorization:(NSString *)timestamp
{
    NSString *authorizationString = [NSString stringWithFormat:@"%@:%@",self.main_Account,timestamp];
    return [self base64forData:[authorizationString dataUsingEncoding:NSUTF8StringEncoding]];
}

//获取子帐号sig编码
- (NSString *)getSubSig:(NSString *)timestamp
{
    NSString *sigString = [NSString stringWithFormat:@"%@%@%@", self.sub_AccountSid, self.sub_AccountToken, timestamp];
    const char *cStr = [sigString UTF8String];
	unsigned char result[16];
	CC_MD5(cStr, (CC_LONG)strlen(cStr), result);
	return [NSString stringWithFormat:@"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",result[0], result[1], result[2], result[3], result[4], result[5], result[6], result[7],result[8], result[9], result[10], result[11],result[12], result[13], result[14], result[15]];
}

//获取主帐号sig编码
- (NSString *)getMainSig:(NSString *)timestamp
{
    NSString *sigString = [NSString stringWithFormat:@"%@%@%@", self.main_Account, self.main_Token, timestamp];
    const char *cStr = [sigString UTF8String];
	unsigned char result[16];
	CC_MD5(cStr, (CC_LONG)strlen(cStr), result);
	return [NSString stringWithFormat:@"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",result[0], result[1], result[2], result[3], result[4], result[5], result[6], result[7],result[8], result[9], result[10], result[11],result[12], result[13], result[14], result[15]];
}

-(NSString*)getTimeStr
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss SSS"];
    return [dateFormatter stringFromDate:[NSDate date]];
}

//输出日志
-(void) printLogWithName:(NSString*) name andUrl:(NSString*) url andRequest:(NSString*)request andResponse:(NSMutableDictionary*)responseData
{
    NSString* strLog = nil;
    if (LogFlag == 1)
    {
        strLog = [NSString stringWithFormat:@"%@ url = %@",name,url];
        NSLog(@"%@",strLog);
        [self redirectConsoleLogToDocumentFolder:[NSString stringWithFormat:@"\n%@ %@",[self getTimeStr],strLog]];
        if ([request length]>0)
        {
            strLog = [NSString stringWithFormat:@"%@ request body = %@",name,request];
            NSLog(@"%@",strLog);
            [self redirectConsoleLogToDocumentFolder:[NSString stringWithFormat:@"\n%@ %@",[self getTimeStr],strLog]];
        }
        if ([responseData objectForKey:@"ResponseBody"])
        {
            strLog = [NSString stringWithFormat:@"%@ response body = %@",name,[responseData objectForKey:@"ResponseBody"]];
            NSLog(@"%@",strLog);
            [self redirectConsoleLogToDocumentFolder:[NSString stringWithFormat:@"\n%@ %@",[self getTimeStr],strLog]];
            [responseData removeObjectForKey:@"ResponseBody"];
        }
    }
}

-(void) redirectConsoleLogToDocumentFolder:(NSString*)log
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *logPath = [documentsDirectory stringByAppendingPathComponent:@"cloopenRest_log.txt"];
    FILE *logFile = fopen((const char *)[logPath UTF8String], "a+");
    fwrite([log UTF8String], sizeof(char), [log length], logFile);
    fclose(logFile);
}
@end


