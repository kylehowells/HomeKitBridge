//
//  HKBTransportCache.h
//  HomeKitBridge
//
//  Created by Kyle Howells on 31/05/2015.
//  Copyright (c) 2015 Kyle Howells. All rights reserved.
//

#import <Foundation/Foundation.h>

@class HAKTransport;

@interface HKBTransportCache : NSObject
+(HAKTransport*)transportForSerialNumber:(NSString*)serialNumber;
@end
