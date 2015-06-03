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
-(void)updateHomeKitPowerState:(BOOL)newPowerState;

/// Update HomeKit to a brightness change
-(void)updateHomeKitBrightness:(NSInteger)brightness;

/// Update HomeKit to a saturation change
-(void)updateHomeKitSaturation:(NSInteger)saturation;

/// Update HomeKit to a hue change
-(void)updateHomeKitHue:(NSInteger)hue;



// Update the external API that these properties have changed in HomeKit.

/// Update external API to a new power state
-(void)updateExternalPowerState:(BOOL)powerState;

/// Update external API to a new brightness
-(void)updateExternalBrightness:(NSInteger)brightness;

/// Update external API to a new saturation
-(void)updateExternalSaturation:(NSInteger)saturation;

/// Update external API to a new hue
-(void)updateExternalHue:(NSInteger)hue;
@end

