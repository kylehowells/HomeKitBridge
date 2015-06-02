//
//  HKBLightAccessory.h
//  HomeKitBridge
//
//  Created by Kyle Howells on 11/10/2014.
//  Copyright (c) 2014 Kyle Howells. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HKBAccessory.h"

@class HKBLightAccessory;



@protocol HKBLightAccessoryDelegate <NSObject>
@required
-(void)lightAccessory:(HKBLightAccessory*)light didChangePowerState:(BOOL)powerState;

@optional
-(void)lightAccessory:(HKBLightAccessory*)light didChangeBrightness:(NSInteger)brightness; // 0-100
-(void)lightAccessory:(HKBLightAccessory*)light didChangeSaturation:(NSInteger)saturation; // 0-100
-(void)lightAccessory:(HKBLightAccessory*)light didChangeHue:(NSInteger)hue; // 0-360
@end



/**
 *  What abilities the light has. (Note: Must have power state)
 */
typedef NS_OPTIONS(NSInteger, HKBLightCapabilities) {
	HKBLightCapabilityHue =			1 << 0,
	HKBLightCapabilitySaturation =	1 << 1,
	HKBLightCapabilityBrightness =	1 << 2
};



@interface HKBLightAccessory : HKBAccessory

-(instancetype)initWithInformation:(NSDictionary*)information NS_UNAVAILABLE;

/**
 *  Create a new accessory with the supplied device information. If a key is missing the default information for that key will be used. "serialNumber" is a required key and will not be subsituted.
 *
 *  @param information Keys: "name", "serialNumber", "manufacturer", "model"
 *  @param characteristics The abilities the light has, an combo of: brightness, hue and saturation.
 */
-(instancetype)initWithInformation:(NSDictionary*)information andCharacteristics:(HKBLightCapabilities)capabilities;

@property (nonatomic, assign) id <HKBLightAccessoryDelegate> delegate;
@property (nonatomic, readonly) HKBLightCapabilities capabilities;

@end

