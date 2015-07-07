//
//  MessageModel.h
//  SVIP
//
//  Created by Hanton on 7/7/15.
//  Copyright (c) 2015 zkjinshi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface MessageModel : NSManagedObject

@property (nonatomic, retain) NSData * photo;
@property (nonatomic, retain) NSString * sender;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSDate * timestamp;
@property (nonatomic, retain) NSData * audio;

@end
