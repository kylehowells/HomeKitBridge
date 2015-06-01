//
//  HKBLightAccessory+Subclass.h
//  HomeKitBridge
//
//  Created by Kyle Howells on 13/10/2014.
//  Copyright (c) 2014 Kyle Howells. All rights reserved.
//


@interface HKBLightAccessory ()
@property (nonatomic, readonly) HAKService *lightBulbService;


// Update HomeKit that these properties have changed externally from its commands.

/// Update HomeKit to a power change
-(void)updatePowerState:(BOOL)newPowerState;

/// Update HomeKit to a brightness change
-(void)updateBrightness:(NSInteger)brightness;

/// Update HomeKit to a saturation change
-(void)updateSaturation:(NSInteger)saturation;

/// Update HomeKit to a hue change
-(void)updateHue:(NSInteger)hue;
@end

