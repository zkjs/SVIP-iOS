//
//  ZKJSDiffie-HellmanProtocol.m
//  BeaconMall
//
//  Created by Hanton on 5/19/15.
//  Copyright (c) 2015 zkjinshi. All rights reserved.
//

#import "ZKJSDiffie-HellmanProtocol.h"
#include <openssl/dh.h>
#include <openssl/evp.h>

@interface ZKJSDiffie_HellmanProtocol() {
  DH *_dh;
}

@end

@implementation ZKJSDiffie_HellmanProtocol

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
    //
  }
  return self;
}

- (void)dealloc {
  DH_free(_dh);
}

- (NSString *)base64StringFrom:(unsigned char *)characters withLength:(int)in_len {
  EVP_ENCODE_CTX ectx;
  unsigned char out[128];
  int out_len, total;
  
  EVP_EncodeInit(&ectx);
  out_len = 0;
  total = 0;
  EVP_EncodeUpdate(&ectx, out, &out_len, characters, in_len);
  total+=out_len;
  EVP_EncodeFinal(&ectx, out+total, &out_len);
  total+=out_len;
  
  return [NSString stringWithUTF8String:(char *)out];
}

- (NSString *)jsonFromDictionary:(NSDictionary *)dictionary {
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

- (NSString *)generateDHJSON {
  int ret, size, codes;
  int prime_len = 128;
  
  /* 构造DH数据结构 */
  _dh = DH_new();

  /* 生成 dh 的密钥参数,该密钥参数是可以公开的 */
  ret = DH_generate_parameters_ex(_dh, prime_len, DH_GENERATOR_2, NULL);
  if(ret != 1) {
    printf("DH_generate_parameters_ex err!\n");
  }
  
  /* 检查密钥参数 */
  ret = DH_check(_dh, &codes);
  if(ret != 1) {
    printf("DH_check err!\n");
    if(codes & DH_CHECK_P_NOT_PRIME)
      printf("p value is not prime\n");
    if(codes & DH_CHECK_P_NOT_SAFE_PRIME)
      printf("p value is not a safe prime\n");
    if (codes & DH_UNABLE_TO_CHECK_GENERATOR)
      printf("unable to check the generator value\n");
    if (codes & DH_NOT_SUITABLE_GENERATOR)
      printf("the g value is not a generator\n");
  }
  
  printf("DH parameters appear to be ok.\n");
  
  /* 密钥大小 */
  size = DH_size(_dh);
  printf("DH key1 size : %d\n", size);
  
  /* 生成公私钥 */
  ret = DH_generate_key(_dh);
  if(ret != 1) {
    printf("DH_generate_key err!\n");
  }
  
  char *pChar = BN_bn2dec(_dh->p);
  NSString *p = [NSString stringWithUTF8String:pChar];
  char *gChar = BN_bn2dec(_dh->g);
  NSString *g = [NSString stringWithUTF8String:gChar];
  char *pub_keyChar = BN_bn2dec(_dh->pub_key);
  NSString *pub_key = [NSString stringWithUTF8String:pub_keyChar];
  
  NSDictionary *dict = @{
                         @"p": p,
                         @"g": g,
                         @"pub_key": pub_key
                         };
  
  NSString *json = [self jsonFromDictionary:dict];
  return json;
}

- (NSString *)generateSessionKeyWithPublicKey:(NSString *)publicKey prime:(NSString *)prime generator:(NSString *)generator {
  DH *d1;
  int ret, size, codes;
  unsigned char sharekey[128];
  BIGNUM *d2_pub_key;
  
  /* 构造DH数据结构 */
  d1 = DH_new();
  
  BN_dec2bn(&d1->p, [prime UTF8String]);
  BN_dec2bn(&d1->g, [generator UTF8String]);
  
  d2_pub_key = BN_new();
  BN_dec2bn(&d2_pub_key, [publicKey UTF8String]);
  
  /* 检查密钥参数 */
  ret = DH_check(d1, &codes);
  if(ret != 1) {
    printf("DH_check err!\n");
    if(codes & DH_CHECK_P_NOT_PRIME)
      printf("p value is not prime\n");
    if(codes & DH_CHECK_P_NOT_SAFE_PRIME)
      printf("p value is not a safe prime\n");
    if (codes & DH_UNABLE_TO_CHECK_GENERATOR)
      printf("unable to check the generator value\n");
    if (codes & DH_NOT_SUITABLE_GENERATOR)
      printf("the g value is not a generator\n");
  }
  
  printf("DH parameters appear to be ok.\n");
  
  /* 密钥大小 */
  size = DH_size(d1);
  printf("DH key1 size : %d\n", size);
  
  /* 生成公私钥 */
  ret = DH_generate_key(d1);
  if(ret != 1) {
    printf("DH_generate_key err!\n");
  }
  
  char *p = BN_bn2dec(d1->pub_key);
  NSString *pub_key = [NSString stringWithUTF8String:p];
  
  /* 计算共享密钥 */
  int len = DH_compute_key(sharekey, d2_pub_key, d1);
  
  DH_free(d1);
  
  NSString *session_key = [self base64StringFrom:sharekey withLength:len];
  
  NSDictionary *dict = @{
                         @"pub_key": pub_key,
                         @"session_key": session_key
                         };
  
  NSString *json = [self jsonFromDictionary:dict];
  return json;
}

- (NSString *)generateSessionKeyWithPublicKey:(NSString *)public_key {
  unsigned char sharekey[128];
  BIGNUM *dh2_pub_key;
  dh2_pub_key = BN_new();
  BN_dec2bn(&dh2_pub_key, [public_key UTF8String]);
  
  /* 计算共享密钥 */
  int len = DH_compute_key(sharekey, dh2_pub_key, _dh);
  NSString *session_key = [self base64StringFrom:sharekey withLength:len];
  
  return session_key;
}

- (int)test {
  DH *d1, *d2;
  BIO *b;
  int ret, size, codes, len1, len2;
  unsigned char sharekey1[128], sharekey2[128];
  int prime_len = 128;
  
  /* 构造DH数据结构 */
  d1 = DH_new();
  d2 = DH_new();
  
  /* 生成 d1 的密钥参数,该密钥参数是可以公开的 */
  // int DH_generate_parameters_ex(DH *dh, int prime_len, int generator, BN_GENCB *cb);
  ret = DH_generate_parameters_ex(d1, prime_len, DH_GENERATOR_2, NULL);
  if(ret != 1) {
    printf("DH_generate_parameters_ex err!\n");
    return -1;
  }
  
  /* 检查密钥参数 */
  ret = DH_check(d1, &codes);
  if(ret != 1) {
    printf("DH_check err!\n");
    if(codes & DH_CHECK_P_NOT_PRIME)
      printf("p value is not prime\n");
    if(codes & DH_CHECK_P_NOT_SAFE_PRIME)
      printf("p value is not a safe prime\n");
    if (codes & DH_UNABLE_TO_CHECK_GENERATOR)
      printf("unable to check the generator value\n");
    if (codes & DH_NOT_SUITABLE_GENERATOR)
      printf("the g value is not a generator\n");
  }
  
  printf("DH parameters appear to be ok.\n"); /* 密钥大小 */
  size = DH_size(d1);
  printf("DH key1 size : %d\n", size);
  
  /* 生成公私钥 */
  ret = DH_generate_key(d1);
  if(ret != 1) {
    printf("DH_generate_key err!\n");
    return -1;
  }
  
  /* p 和 g 为公开的密钥参数,因此可以拷贝 */
  d2->p = BN_dup(d1->p);
  d2->g = BN_dup(d1->g);
  char *p = BN_bn2dec(d1->p);
  printf("%s\n", p);
  
  /* 生成公私钥,用于测试生成共享密钥 */
  ret = DH_generate_key(d2);
  if(ret != 1) {
    printf("DH_generate_key err!\n");
    return -1;
  }
  
  /* 检查公钥 */
  ret = DH_check_pub_key(d1, d1->pub_key, &codes);
  if(ret != 1) {
    if (codes & DH_CHECK_PUBKEY_TOO_SMALL)
      printf("pub key too small \n");
    if (codes & DH_CHECK_PUBKEY_TOO_LARGE)
      printf("pub key too large \n");
  }
  
  /* 计算共享密钥 */
  len1 = DH_compute_key(sharekey1, d2->pub_key, d1);
  len2 = DH_compute_key(sharekey2, d1->pub_key, d2);
  if(len1 != len2) {
    printf("生成共享密钥失败 1\n");
    return -1;
  }
  
  EVP_ENCODE_CTX ectx, dctx;
  unsigned char in[500], out[800], d[500];
  int inl, outl, i, total, total2;
  EVP_EncodeInit(&ectx);
  for(i=0; i<500; i++)
    memset(&in[i], i, 1);
  inl = 128;
  total = 0;
  EVP_EncodeUpdate(&ectx, out, &outl, sharekey1, inl);
  total+=outl;
  EVP_EncodeFinal(&ectx, out+total, &outl);
  total+=outl;
  printf("Share Key: %s\n", out);
  
  EVP_DecodeInit(&dctx);
  outl = 500;
  total2 = 0; ret = EVP_DecodeUpdate(&dctx, d, &outl, out, total);
  
  if(ret<0){
    printf("EVP_DecodeUpdate err!\n");
    return -1;
  }
  total2 += outl;
  ret=EVP_DecodeFinal(&dctx, d, &outl);
  total2+=outl;

  if(memcmp(sharekey1, sharekey2, len1) != 0) {
    printf("生成共享密钥失败 2\n");
    return -1;
  }
  printf("生成共享密钥成功\n");
  b = BIO_new(BIO_s_file());
  BIO_set_fp(b, stdout, BIO_NOCLOSE);
  
  /* 打印密钥 */
  DHparams_print(b, d1);
  
  BIO_free(b);
  DH_free(d1);
  DH_free(d2);
  
  return 0;
}

@end
