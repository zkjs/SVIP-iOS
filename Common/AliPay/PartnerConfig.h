//
//  PartnerConfig.h
//  AlipaySdkDemo
//
//  Created by ChaoGanYing on 13-5-3.
//  Copyright (c) 2013年 RenFei. All rights reserved.
//
//  提示：如何获取安全校验码和合作身份者id
//  1.用您的签约支付宝账号登录支付宝网站(www.alipay.com)
//  2.点击“商家服务”(https://b.alipay.com/order/myorder.htm)
//  3.点击“查询合作者身份(pid)”、“查询安全校验码(key)”
//

#ifndef PartnerConfig_h
#define PartnerConfig_h

//合作身份者id，以2088开头的16位纯数字
#define PartnerID @"2088021086279355"
//收款支付宝账号
#define SellerID  @"caozhao@zkjinshi.com"

////安全校验码（MD5）密钥，以数字和字母组成的32位字符
//#define MD5_KEY @"3aeabie2qme7bamq92lwrzrjknbnc7hh"


//商户私钥，自助生成
#define PartnerPrivKey @"MIICdgIBADANBgkqhkiG9w0BAQEFAASCAmAwggJcAgEAAoGBAK3gPktnK5WlcVZRIFBOP6qk+xOqdECVaoFu4rxY7UWyLXE6tDcDDLHwK3QG58gwd47W9x3YOUMk5lOo84RzZa1RwqXcgaXcZwhquIqqRRCq846dR4sm1WhN5zubN2mIRSarSl3gEniX9X2C7JDkh+cpNJQ5s/pTq6hvHQr4dondAgMBAAECgYB9MGFpxOSaoD3UGiEb8NriMFseM7Hz9iBzBLV3Sse7UKhrSAsNOMLhMrz2kyo69rp+O8Q81ruT3nN/dLuwd62SRqPPJTZf3JdyyV7ap6R2iO5eyxxSri8V7Q0cAlpP0mrGSOhiOLcpR/RsS3KJp2bMyYan6Xkp9QexMJkfwOGduQJBANviki1mAD/4+1PJ3WjMuEcSaV7X+KWw7vsrZm59Bu4DUSlKdn2pAZA8yRlImBj4233eIe4numgpUqBoNQjuls8CQQDKbyTrkhC8CqmNSFi8tL06kOf+oLdUM0NGdLu7mOCYvuUlNjznSu5hrNq86jlYnXcRSGXcClv9VrQTmHsgVz+TAkAU0LH90jYb2DoSiH2JOjgHolqPO+qx5Ln61PTxaKyLQ40fV4k4BBO9z8NJvXGIi6Zbl/emT+R5j8/el37NxahJAkEAmQJpZaWCAKAOiDum1vvGC/57XHseFwaoUxjozWNAYDPp/7Z/UlPQ2wNMUn632cMrvGR8mVU7MsHWWvlmF4vbAQJAUUWguvqXVog0Z7uvGHLZdZKHulVoCLlSupzNTUDxCeU4viTjS0ZUyM/lGW163D2ISeG8XGh0z5nANgVbdB0vgA=="


////支付宝公钥
//#define AlipayPubKey   @"MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCFPkvwN4WPFq9sHxMs2UKfsJ9VkdLj9lEb9FGd KwN/7Byj6UIkfqE3eKOlHkQ0EbWR21kQDPK1kw6tLSvSVhvZKCo2Ti3eYEq+lat8P+Y88gnfgm3Z aVyVNG9qaoroN4PnCA6wPV+4DLNSGnvJrjcgLs3LARWFTlR0VnnBgboaYwIDAQAB"

#endif