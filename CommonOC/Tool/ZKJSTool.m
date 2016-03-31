//
//  JSGtool.m
//  BeaconMall
//
//  Created by dai.fengyi on 4/28/15.
//  Copyright (c) 2015 zkjinshi. All rights reserved.
//

#import "ZKJSTool.h"
#import "MBProgressHUD.h"
#define APP [UIApplication sharedApplication]
#define IOS_CELLULAR    @"pdp_ip0"
#define IOS_WIFI        @"en0"
#define IOS_VPN         @"utun0"
#define IP_ADDR_IPv4    @"ipv4"
#define IP_ADDR_IPv6    @"ipv6"

#include <ifaddrs.h>
#include <arpa/inet.h>
#include <net/if.h>
@implementation ZKJSTool

#pragma mark - HUD
+ (MBProgressHUD *)Hud
{
    MBProgressHUD *hud = [MBProgressHUD HUDForView:APP.keyWindow];
    if (hud){
        [hud removeFromSuperview];
    }else{
        hud = [[MBProgressHUD alloc] initWithWindow:APP.keyWindow];
        hud.removeFromSuperViewOnHide = YES;
    }
    [APP.keyWindow addSubview:hud];
    return hud;
}

#pragma mark - 显示提示信息

+ (void)showMsg:(NSString *)message {
  MBProgressHUD * hud = [self Hud];
  hud.removeFromSuperViewOnHide = YES;
  hud.labelText = message;
  hud.mode = MBProgressHUDModeText;
  hud.labelFont = [UIFont systemFontOfSize:16];
  [hud show:YES];
  [hud hide:YES afterDelay:2.0];
}

#pragma mark - 检测手机号码是否合法

+ (BOOL)validateMobile:(NSString *)mobileNum {
  /**
   * 手机号码
   * 移动：134[0-8],135,136,137,138,139,150,151,157,158,159,181,182,187,188
   * 联通：130,131,132,152,155,156,185,186
   * 电信：133,1349,153,180,189
   */
  NSString * MOBILE = @"^1(3[0-9]|5[0-35-9]|8[0125-9])\\d{8}$";
  /**
   10         * 中国移动：China Mobile
   11         * 134[0-8],135,136,137,138,139,150,151,157,158,159,178,182,187,188
   12         */
  NSString * CM = @"^1(34[0-8]|(3[5-9]|7[8]|5[017-9]|8[278])\\d)\\d{7}$";
  /**
   15         * 中国联通：China Unicom
   16         * 130,131,132,152,155,156,176,185,186
   17         */
  NSString * CU = @"^1(3[0-2]|7[6]|5[256]|8[56])\\d{8}$";
  /**
   20         * 中国电信：China Telecom
   21         * 133,1349,153,180,189,170,177
   22         */
  NSString * CT = @"^1((33|53|7[07]|8[09])[0-9]|349)\\d{7}$";
    /**
     25         * 大陆地区固话及小灵通
     26         * 区号：010,020,021,022,023,024,025,027,028,029
     27         * 号码：七位或八位
     28         */
    // NSString * PHS = @"^0(10|2[0-5789]|\\d{3})\\d{7,8}$";
    /**
     * 虚拟运营商 170
     */
    NSString * VO = @"^1(7[0-9])\\d{8}$";
    
    NSPredicate *regextestmobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", MOBILE];
    NSPredicate *regextestcm = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CM];
    NSPredicate *regextestcu = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CU];
    NSPredicate *regextestct = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CT];
    NSPredicate *regextestvo = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", VO];
    
    if (([regextestmobile evaluateWithObject:mobileNum] == YES)
        || ([regextestcm evaluateWithObject:mobileNum] == YES)
        || ([regextestct evaluateWithObject:mobileNum] == YES)
        || ([regextestcu evaluateWithObject:mobileNum] == YES)
        || ([regextestvo evaluateWithObject:mobileNum] == YES))
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

#pragma mark - 检测邮箱格式

+ (BOOL)validateEmail:(NSString *)email {
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES%@",emailRegex];
    return [emailTest evaluateWithObject:email];
}

#pragma mark - 获取手机分辨率
+ (int)getResolution {
  //得到当前屏幕的尺寸：
  CGRect rect_screen = [[UIScreen mainScreen]bounds];
  CGSize size_screen = rect_screen.size;
  if (size_screen.width <= 375) {
    return 720;
  }else {
    return 1080;
  }
  
}
#pragma mark - 获取手机设备地址

+ (NSString *)getIPAddress:(BOOL)preferIPv4
{
  NSArray *searchArray = preferIPv4 ?
  @[ IOS_VPN @"/" IP_ADDR_IPv4, IOS_VPN @"/" IP_ADDR_IPv6, IOS_WIFI @"/" IP_ADDR_IPv4, IOS_WIFI @"/" IP_ADDR_IPv6, IOS_CELLULAR @"/" IP_ADDR_IPv4, IOS_CELLULAR @"/" IP_ADDR_IPv6 ] :
  @[ IOS_VPN @"/" IP_ADDR_IPv6, IOS_VPN @"/" IP_ADDR_IPv4, IOS_WIFI @"/" IP_ADDR_IPv6, IOS_WIFI @"/" IP_ADDR_IPv4, IOS_CELLULAR @"/" IP_ADDR_IPv6, IOS_CELLULAR @"/" IP_ADDR_IPv4 ] ;
  
  NSDictionary *addresses = [self getIPAddresses];
  __block NSString *address;
  [searchArray enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL *stop)
   {
     address = addresses[key];
     if(address) *stop = YES;
   } ];
  return address ? address : @"0.0.0.0";
}

+ (NSDictionary *)getIPAddresses
{
  NSMutableDictionary *addresses = [NSMutableDictionary dictionaryWithCapacity:8];
  
  // retrieve the current interfaces - returns 0 on success
  struct ifaddrs *interfaces;
  if(!getifaddrs(&interfaces)) {
    // Loop through linked list of interfaces
    struct ifaddrs *interface;
    for(interface=interfaces; interface; interface=interface->ifa_next) {
      if(!(interface->ifa_flags & IFF_UP) /* || (interface->ifa_flags & IFF_LOOPBACK) */ ) {
        continue; // deeply nested code harder to read
      }
      const struct sockaddr_in *addr = (const struct sockaddr_in*)interface->ifa_addr;
      char addrBuf[ MAX(INET_ADDRSTRLEN, INET6_ADDRSTRLEN) ];
      if(addr && (addr->sin_family==AF_INET || addr->sin_family==AF_INET6)) {
        NSString *name = [NSString stringWithUTF8String:interface->ifa_name];
        NSString *type;
        if(addr->sin_family == AF_INET) {
          if(inet_ntop(AF_INET, &addr->sin_addr, addrBuf, INET_ADDRSTRLEN)) {
            type = IP_ADDR_IPv4;
          }
        } else {
          const struct sockaddr_in6 *addr6 = (const struct sockaddr_in6*)interface->ifa_addr;
          if(inet_ntop(AF_INET6, &addr6->sin6_addr, addrBuf, INET6_ADDRSTRLEN)) {
            type = IP_ADDR_IPv6;
          }
        }
        if(type) {
          NSString *key = [NSString stringWithFormat:@"%@/%@", name, type];
          addresses[key] = [NSString stringWithUTF8String:addrBuf];
        }
      }
    }
    // Free memory
    freeifaddrs(interfaces);
  }
  return [addresses count] ? addresses : nil;
}

// JSON String to Dictionary
+ (NSDictionary *)convertJSONStringToDictionary:(NSString *)jsonString {
  NSError *jsonError;
  NSData *objectData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
  NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:objectData
                                                             options:NSJSONReadingMutableContainers
                                                               error:&jsonError];
  if (jsonError) {
    NSLog(@"%@", jsonError);
  }
  return dictionary;
}

+ (NSString *)convertJSONStringFromDictionary:(NSDictionary *)dictionary {
  NSError *error;
  NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary
                                                     options:0 //NSJSONWritingPrettyPrinted
                                                       error:&error];
  NSString *jsonString = @"";
  if (jsonData) {
    jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
  } else {
    NSLog(@"Got an error: %@", error);
  }
  
  return jsonString;
}

+(int)compareOneDay:(NSString *)oneDay withAnotherDay:(NSString *)anotherDay
{
//  NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//  [dateFormatter setDateFormat:@"dd-MM-yyyy"];
//  NSString *oneDayStr = [dateFormatter stringFromDate:oneDay];
//  NSString *anotherDayStr = [dateFormatter stringFromDate:anotherDay];
//  NSDate *dateA = [dateFormatter dateFromString:oneDayStr];
//  NSDate *dateB = [dateFormatter dateFromString:anotherDayStr];
  NSComparisonResult result = [oneDay compare:anotherDay];
  NSLog(@"date1 : %@, date2 : %@", oneDay, anotherDay);
  if (result == NSOrderedDescending) {
    //NSLog(@"Date1  is in the future");
    return 1;
  }
  else if (result == NSOrderedAscending){
    //NSLog(@"Date1 is in the past");
    return -1;
  }
  //NSLog(@"Both dates are the same");
  return 0;
  
}

@end