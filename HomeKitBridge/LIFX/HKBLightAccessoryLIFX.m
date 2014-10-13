//
//  HKBLightAccessoryLIFX.m
//  HomeKitBridge
//
//  Created by Kyle Howells on 13/10/2014.
//  Copyright (c) 2014 Kyle Howells. All rights reserved.
//

#import "HKBLightAccessoryLIFX.h"

#import <LIFXKit/LIFXKit.h>
#import "HKBLightAccessory+Subclass.h"

@interface HKBLightAccessoryLIFX () <HKBLightDelegate, LFXLightObserver>
@property (nonatomic, strong) LFXLight *lifxBulb;
@end


#pragma mark -

@implementation HKBLightAccessoryLIFX

-(void)dealloc{
	[self.lifxBulb removeLightObserver:self];
}


#pragma mark - Setup

-(instancetype)initWithLightBulb:(LFXLight*)lightBulb{
	// Settings
	HKBLightCharacteristics lightAbilities = (HKBLightCharacteristicBrightness | HKBLightCharacteristicHue | HKBLightCharacteristicSaturation);
	NSDictionary *information = @{NameKey : lightBulb.label, SerialNumberKey : lightBulb.deviceID};
	
	// Create light
	if (self = [super initWithInformation:information andCharacteristics:lightAbilities]) {
//		self.lifxBulb = lightBulb;
//		[self updateHKColorValues];
//		
//		[self.lifxBulb addLightObserver:self];
//		self.delegate = self;
	}
	
	return self;
}


#pragma mark - Update HomeKit to LIFX values

-(void)updateHKColorValues{
	// - Conversion:	LIFX		HomeKit
	// hue;			//	[0, 360] -  [0, 360]
	// saturation;	//	[0, 1]	 -  [0, 100]
	// brightness;	//	[0, 1]	 -  [0, 100]
	
	[self.lightBulbService.brightnessCharacteristic setIntegerValue:(self.lifxBulb.color.brightness * 100)];
	[self.lightBulbService.saturationCharacteristic setFloatValue:(self.lifxBulb.color.saturation * 100)];
	[self.lightBulbService.hueCharacteristic setFloatValue:(self.lifxBulb.color.hue)];
}
-(void)updateHKPowerState{
	[self.lightBulbService.onCharacteristic setBoolValue:(self.lifxBulb.powerState == LFXPowerStateOn)];
}






#pragma mark - LFXLightObserver

-(void)light:(LFXLight *)light didChangeLabel:(NSString *)label{
	[self.lightBulbService.accessory.accessoryInformationService.nameCharacteristic setStringValue:light.label];
}
-(void)light:(LFXLight *)light didChangeColor:(LFXHSBKColor *)color{
	[self updateHKColorValues];
}
-(void)light:(LFXLight *)light didChangePowerState:(LFXPowerState)powerState{
	[self updateHKPowerState];
}






#pragma mark - HKBLightDelegate

-(void)setLight:(HKBLightAccessory *)light powerState:(BOOL)_powerState {
	LFXPowerState powerState = _powerState ? LFXPowerStateOn : LFXPowerStateOff;
	[self.lifxBulb setPowerState:powerState];
}

-(void)setLight:(HKBLightAccessory *)light hue:(NSInteger)hue {
	LFXLight *lfxLight = [self lifxBulb];
	
	LFXHSBKColor *currentColor = [lfxLight color];
	LFXHSBKColor *newColor = [LFXHSBKColor colorWithHue:hue saturation:currentColor.saturation brightness:currentColor.brightness];
	
	[lfxLight setColor:newColor];
}
-(void)setLight:(HKBLightAccessory *)light brightness:(NSInteger)brightness {
	CGFloat _brightness = brightness * 0.01;
	
	LFXLight *lfxLight = self.lifxBulb;
	
	LFXHSBKColor *currentColor = [lfxLight color];
	LFXHSBKColor *newColor = [LFXHSBKColor colorWithHue:currentColor.hue saturation:currentColor.saturation brightness:_brightness];
	
	[lfxLight setColor:newColor];
}
-(void)setLight:(HKBLightAccessory *)light saturation:(NSInteger)saturation {
	CGFloat _saturation = saturation * 0.01;
	
	LFXLight *lfxLight = self.lifxBulb;
	
	LFXHSBKColor *currentColor = [lfxLight color];
	LFXHSBKColor *newColor = [LFXHSBKColor colorWithHue:currentColor.hue saturation:_saturation brightness:currentColor.brightness];
	
	[lfxLight setColor:newColor];
}







#pragma mark - Properties

-(NSString*)deviceID{
	return self.accessory.accessoryInformationService.serialNumberCharacteristic.serialNumber;
}

@end
