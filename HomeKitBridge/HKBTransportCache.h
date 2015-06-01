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
/**
 *  Creates and persists a HAKTransport for a given device.
 *
 *  @param serialNumber The unique serial number of the device.
 *
 *  @return A HAKTransport object for the device.
 */
+(HAKTransport*)transportForSerialNumber:(NSString*)serialNumber;
@end
