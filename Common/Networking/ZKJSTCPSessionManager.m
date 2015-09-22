//
//  ZKJSTCPSessionManager.m
//  BeaconMall
//
//  Created by Hanton on 5/11/15.
//  Copyright (c) 2015 zkjinshi. All rights reserved.
//

#import "ZKJSTCPSessionManager.h"
#import "Networkcfg.h"
#import "SRWebSocket.h"
#import "CocoaLumberjack.h"

static const DDLogLevel ddLogLevel = DDLogLevelInfo;

@interface ZKJSTCPSessionManager () <NSStreamDelegate, SRWebSocketDelegate> {
  NSInputStream *_inputStream;
  NSOutputStream *_outputStream;
  uint8_t _buffer[kBufferLength];
  NSUInteger _bufferLength;
  BOOL _isReadingHeader;
  NSUInteger _bodyLength;
  SRWebSocket *_webSocket;
}

@end

@implementation ZKJSTCPSessionManager

+ (instancetype)sharedInstance
{
  static dispatch_once_t once;
  static id sharedInstance;
  dispatch_once(&once, ^{
    sharedInstance = [[self alloc] init];
  });
  return sharedInstance;
}

- (id)init
{
  self = [super init];
  if (self) {
    _isReadingHeader = YES;
  }
  return self;
}

- (void)dealloc {
  _webSocket.delegate = nil;
  [_webSocket close];
  _webSocket = nil;
  
//  if (_inputStream != nil) {
//    [_inputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
//    _inputStream.delegate = nil;
//    [_inputStream close];
//    _inputStream = nil;
//  }
//  
//  if (_outputStream != nil) {
//    [_outputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
//    _outputStream.delegate = nil;
//    [_outputStream close];
//    _outputStream = nil;
//  }
}

- (void)startHeartbeat {
  [NSTimer scheduledTimerWithTimeInterval:kHeartBeatInterval
                                   target:self
                                 selector:@selector(heartBeat)
                                 userInfo:nil
                                  repeats:YES];
}

#pragma mark - SRWebSocketDelegate

- (void)webSocketDidOpen:(SRWebSocket *)webSocket {
  DDLogInfo(@"Websocket Connected");
    
  if (self.delegate && [self.delegate respondsToSelector:@selector(didOpenTCPSocket)]) {
    [self.delegate didOpenTCPSocket];
  }
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error {
  DDLogInfo(@"Websocket Failed With Error %@", error);
  _webSocket = nil;
}

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message {
  NSData *jsonData = [message dataUsingEncoding:NSUTF8StringEncoding];
  NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:jsonData
                                                             options:NSJSONReadingMutableContainers
                                                               error:nil];
  DDLogInfo(@"Feedback: %@", dictionary);
  if ([dictionary[@"type"] integerValue] == MessageIMClientLogin_RSP) {
    DDLogInfo(@"startHeartbeat");
    [self startHeartbeat];
  }
  
  if (self.delegate && [self.delegate respondsToSelector:@selector(didReceivePacket:)]) {
    [self.delegate didReceivePacket:dictionary];
  }
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean {
  DDLogInfo(@"WebSocket closed");
  _webSocket = nil;
}

- (void)webSocket:(SRWebSocket *)webSocket didReceivePong:(NSData *)pongPayload {
  DDLogInfo(@"Websocket received pong");
}

#pragma mark Public Method

- (void)initNetworkCommunicationWithIP:(NSString *)ip Port:(NSString *)port {
  _webSocket.delegate = nil;
  [_webSocket close];
  _webSocket = nil;
  
  NSString *websocketURL = [NSString stringWithFormat:@"%@://%@:%@/zkjs2", WEBSOCKET_PREFIX, ip, port];
  _webSocket = [[SRWebSocket alloc] initWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:websocketURL]]];
  _webSocket.delegate = self;
  
  [_webSocket open];
}

- (void)initNetworkCommunication {
  _webSocket.delegate = nil;
  [_webSocket close];
  _webSocket = nil;
  
  NSString *websocketURL = [NSString stringWithFormat:@"%@://%@:%@/ws", WEBSOCKET_PREFIX, HOST, PORT];
  _webSocket = [[SRWebSocket alloc] initWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:websocketURL]]];
  _webSocket.delegate = self;
  
  [_webSocket open];
  
//  CFReadStreamRef readStream;
//  CFWriteStreamRef writeStream;
//  CFStreamCreatePairWithSocketToHost(NULL, (CFStringRef)HOST, PORT, &readStream, &writeStream);
//  _inputStream = (__bridge NSInputStream *)readStream;
//  _outputStream = (__bridge NSOutputStream *)writeStream;
//  _inputStream.delegate = self;
//  _outputStream.delegate = self;
//  [_inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
//  [_outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
//  [_inputStream open];
//  [_outputStream open];
}

- (void)deinitNetworkCommunication {
  _webSocket.delegate = nil;
  [_webSocket close];
  _webSocket = nil;
  
//  if (_inputStream != nil) {
//    [_inputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
//    _inputStream.delegate = nil;
//    [_inputStream close];
//    _inputStream = nil;
//  }
//  
//  if (_outputStream != nil) {
//    [_outputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
//    _outputStream.delegate = nil;
//    [_outputStream close];
//    _outputStream = nil;
//  }
}

- (void)clientLogin:(NSString *)clientID name:(NSString *)name deviceToken:(NSString *)deviceToken {
  NSNumber *timestamp = [NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970]];
#if DEBUG
  NSString *appid = @"HOTELVIP_DEBUG";
#else
  NSString *appid = @"HOTELVIP";
#endif
  NSDictionary *dictionary = @{
    @"type": [NSNumber numberWithInteger:MessageIMClientLogin],
    @"id": clientID,
    @"name": name,
    @"devtoken": deviceToken,
    @"role": @0,  //0: APP用户 1:商家
    @"appid": appid,
    @"platform": @"I",
    @"timestamp": timestamp
  };
  
  [self sendPacketFromDictionary:dictionary];
}

- (void)shopLogin:(NSString *)shopID {
  NSNumber *timestamp = [NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970]];
  NSDictionary *dictionary = @{
    @"type": [NSNumber numberWithInteger:MessageIMClientLogin],
    @"id": shopID,
    @"role": @1,  //0: APP用户 1:商家
    @"timestamp": timestamp
  };
  
  [self sendPacketFromDictionary:dictionary];
}

- (void)sendPacketFromDictionary:(NSDictionary *)dictionary {
  NSString *jsonString = [self jsonFromDictionary:dictionary];
  NSData *packet = [[NSData alloc] initWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding]];
  [_webSocket send:packet];
  
//  NSString *jsonString = [self jsonFromDictionary:dictionary];
//  NSData *packet = [self packet:jsonString];
//  [_outputStream write:[packet bytes] maxLength:[packet length]];
  
  DDLogInfo(@"%@", jsonString);
}

#pragma mark NSStreamDelegate
- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode {
  switch (eventCode) {
    case NSStreamEventNone:
      DDLogInfo(@"NSStreamEventNone");
      break;
      
    case NSStreamEventOpenCompleted:
      DDLogInfo(@"Stream opened");
      break;
      
    case NSStreamEventHasBytesAvailable:
      DDLogInfo(@"NSStreamEventHasBytesAvailable");
      if (aStream == _inputStream) {
        if ([_inputStream hasBytesAvailable]) {
          uint8_t inputData[4096];  // 每次最多读4k
          NSUInteger inputDataLength;
          
          inputDataLength = [_inputStream read:inputData maxLength:sizeof(inputData)];
          DDLogInfo(@"inputDataLength: %tu", inputDataLength);
          (void)memcpy(_buffer + _bufferLength, inputData, inputDataLength);
          _bufferLength += inputDataLength;
          
          while (1) {
            if (_isReadingHeader) {
              if (_bufferLength >= kPacketHeaderLength) {
                _isReadingHeader = NO;
                uint8_t lenBytes[kPacketHeaderLength];
                (void)memcpy(lenBytes, _buffer, kPacketHeaderLength);
                _bodyLength = CFSwapInt32BigToHost(*(int*)(lenBytes));
                
                // 包体过大, 包已经乱了
                if (_bodyLength > (kBufferLength - kPacketHeaderLength)) {
                  _isReadingHeader = YES;
                  _bodyLength = 0;
                  // 重置缓冲区
                  uint8_t nullBuffer[kBufferLength];
                  (void)memcpy(_buffer, nullBuffer, kBufferLength);
                  return;
                }
              } else {
                // 包头还没传完整, 等待新包
                return;
              }
            } else {
              // 读包体
              while (_bufferLength < (_bodyLength + kPacketHeaderLength)) {
                inputDataLength = [_inputStream read:inputData maxLength:sizeof(inputData)];
                DDLogInfo(@"inputDataLength: %tu", inputDataLength);
                if (inputDataLength == 0) {
                  // 已无数据可读, 但包体还没读完整
                  return;
                } else {
                  (void)memcpy(_buffer + _bufferLength, inputData, inputDataLength);
                  _bufferLength += inputDataLength;
                }
              }
              
              uint8_t bodyBytes[_bodyLength];
              (void)memcpy(bodyBytes, _buffer + kPacketHeaderLength, _bodyLength);
              NSData *bodyData = [NSData dataWithBytes:bodyBytes length:_bodyLength];
              NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:bodyData
                                                                         options:NSJSONReadingMutableContainers
                                                                           error:nil];
              
              DDLogInfo(@"Feedback: %@", dictionary);
              if ([dictionary[@"type"] integerValue] == MessageIMClientLogin_RSP) {
                DDLogInfo(@"startHeartbeat");
                [self startHeartbeat];
              }
              
              if (self.delegate && [self.delegate respondsToSelector:@selector(didReceivePacket:)]) {
                [self.delegate didReceivePacket:dictionary];
              }
              
              // 重置buffer
              _isReadingHeader = YES;
              uint8_t tmpBuffer[kBufferLength];
              uint8_t nullBuffer[kBufferLength];
              NSUInteger packetLength = _bodyLength + kPacketHeaderLength;
              _bufferLength -= packetLength;
              if (_bufferLength > 0) {
                (void)memcpy(tmpBuffer, _buffer+packetLength, _bufferLength);
                (void)memcpy(_buffer, nullBuffer, kBufferLength);
                (void)memcpy(_buffer, tmpBuffer, _bufferLength);
              } else {
                (void)memcpy(_buffer, nullBuffer, kBufferLength);
              }
            }
          }
        }
      }
      break;
      
    case NSStreamEventHasSpaceAvailable: {
      DDLogInfo(@"NSStreamEventHasSpaceAvailable");
      break;
    }
      
    case NSStreamEventErrorOccurred: {
      NSError *error = [aStream streamError];
      DDLogInfo(@"Stream Error: %@", error);
      break;
    }
      
    case NSStreamEventEndEncountered:
      DDLogInfo(@"NSStreamEventEndEncountered");
      break;
      
    default:
      DDLogInfo(@"Unknown event");
  }
}

#pragma mark TCP Protocol
// 心跳包
- (void)heartBeat {
  NSDictionary *dictionary = @{
                               @"type": [NSNumber numberWithInteger:MessageIMHeartbeat]
                               };
  [self sendPacketFromDictionary:dictionary];
}

#pragma mark Private Method
- (NSData *)packet:(NSString *)body {
  NSData *data = [[NSData alloc] initWithData:[body dataUsingEncoding:NSUTF8StringEncoding]];
  uint32_t myInt32Value = (uint32_t)[data length];
  uint32_t myInt32AsABigEndianNumber = CFSwapInt32HostToBig(myInt32Value);
  char *bigEndian = (char *) &myInt32AsABigEndianNumber;
  NSMutableData *packet = [NSMutableData data];
  [packet appendBytes:bigEndian length:sizeof(uint32_t)];
  [packet appendData:data];
  return packet;
}

- (NSNumber *)timestamp {
  return [NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970]];
}

- (NSString *)jsonFromDictionary:(NSDictionary *)dictionary {
  NSError *error;
  NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary
                                                     options:NSJSONWritingPrettyPrinted
                                                       error:&error];
  NSString *jsonString = @"";
  if (jsonData) {
    jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
  } else {
    DDLogInfo(@"Got an error: %@", error);
  }
  
  return jsonString;
}

@end
