//
//  HKBLightAccessoryLIFX.h
//  HomeKitBridge
//
//  Created by Kyle Howells on 13/10/2014.
//  Copyright (c) 2014 Kyle Howells. All rights reserved.
//

#import "HKBLightAccessory.h"

@class LFXLight;


@interface HKBLightAccessoryLIFX : HKBLightAccessory

// Remove old init method
-(instancetype)initWithInformation:(NSDictionary*)information andCharacteristics:(HKBLightCharacteristics)characteristics NS_UNAVAILABLE;

/**
 *  Creates an accessory lightbulb object to match a LIFX bulb
 *
 *  @param lightBulb The LIFX bulbs API object for that light.
 */
-(instancetype)initWithLightBulb:(LFXLight*)lightBulb;


// We are our own delegate in for this class
-(void)setDelegate:(id<HKBLightDelegate>)delegate NS_UNAVAILABLE;

@end
