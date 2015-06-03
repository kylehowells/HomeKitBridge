//
//  HKBLightAccessoryLIFX.m
//  HomeKitBridge
//
//  Created by Kyle Howells on 13/10/2014.
//  Copyright (c) 2014 Kyle Howells. All rights reserved.
//

#import "HAKNumberConstraints.h"
#import "HKBLightAccessoryLIFX.h"

#import <LIFXKit/LIFXKit.h>
#import "HKBLightAccessory+Subclass.h"

@interface HKBLightAccessoryLIFX () <LFXLightObserver>
@property (nonatomic, strong) LFXLight *lifxBulb;

@property (nonatomic, strong) HAKCharacteristic *kelvinCharacteristic;
@end


#pragma mark -

@implementation HKBLightAccessoryLIFX

+(NSDictionary*)defaultInformation{
	return @{NameKey:@"Lightbulb", ModelKey:@"WiFi bulb white v1", ManufacturerKey:@"LIFX"};
}


-(void)dealloc{
	[self.lifxBulb removeLightObserver:self];
}


#pragma mark - Setup

-(instancetype)initWithLightBulb:(LFXLight*)lightBulb{
	// Settings
	HKBLightCapabilities lightAbilities = (HKBLightCapabilityBrightness | HKBLightCapabilityHue | HKBLightCapabilitySaturation);
	NSDictionary *information = @{NameKey : lightBulb.label, SerialNumberKey : lightBulb.deviceID};
	
	// Create light
	if (self = [super initWithInformation:information andCharacteristics:lightAbilities]) {
		self.lifxBulb = lightBulb;
		[self updateHKColorValues];
		[self updateHKPowerState];

		[self.lifxBulb addLightObserver:self];
	}
	
	return self;
}


// TODO: work out how to define custom characteristics and add the kelvin value of LIFX bulbs
-(void)setupServices{
	[super setupServices];

	_kelvinCharacteristic = [[HAKCharacteristic alloc] initWithType:[HAKUUID UUIDWithUUIDString:@"0836D660-26E5-4D17-A714-A15DB6EAC9A5"] properties:11 format:HAKCharacteristicFormatUInt16];
	HAKNumberConstraints *kelvinConstraints = [[HAKNumberConstraints alloc] initWithMinimumValue:@(LFXHSBKColorMinKelvin) maximumValue:@(LFXHSBKColorMaxKelvin)];
	_kelvinCharacteristic.constraints = kelvinConstraints;
	
	[self.lightBulbService addCharacteristic:_kelvinCharacteristic];
}

-(void)characteristicDidUpdateValue:(HAKCharacteristic*)characteristic
{
	[super characteristicDidUpdateValue:characteristic];
	
	if (characteristic == self.kelvinCharacteristic) {
		[self updateExternalKelvin:[characteristic.value unsignedIntValue]];
	}
	
	//if (characteristic.service == self.lightBulbService) {}
}




#pragma mark - LFXLightObserver

// I choose not to bridge label=name as I have my LIFX bulbs and HomeKit bulbs named very differently
//-(void)light:(LFXLight *)light didChangeLabel:(NSString *)label{
//	self.accessory.name = light.label;
//}
-(void)light:(LFXLight *)light didChangeColor:(LFXHSBKColor *)color{
	[self updateHKColorValues];
}
-(void)light:(LFXLight *)light didChangePowerState:(LFXPowerState)powerState{
	[self updateHKPowerState];
}






#pragma mark - Update HomeKit to LIFX values

-(void)updateHKPowerState{
	[self updateHomeKitPowerState:(self.lifxBulb.powerState == LFXPowerStateOn)];
}

-(void)updateHKColorValues{
	// - Conversion:	LIFX		HomeKit
	// hue;			//	[0, 360] -  [0, 360]
	// saturation;	//	[0, 1]	 -  [0, 100]
	// brightness;	//	[0, 1]	 -  [0, 100]
	
	[self updateHomeKitBrightness:(self.lifxBulb.color.brightness * 100)];
	[self updateHomeKitSaturation:(self.lifxBulb.color.saturation * 100)];
	[self updateHomeKitHue:self.lifxBulb.color.hue];
	
	[self updateHomeKitKelvin:self.lifxBulb.color.kelvin];
}

-(void)updateHomeKitKelvin:(NSUInteger)kelvin{
	HAKCharacteristic *characteristic = self.kelvinCharacteristic;
	
	if ([characteristic.constraints validateValue:@(kelvin)]) {
		characteristic.value = @(kelvin);
	}
}




#pragma mark - Update LIFX API to HomeKit changes

-(void)updateExternalPowerState:(BOOL)powerState{
	[self.lifxBulb setPowerState:powerState ? LFXPowerStateOn : LFXPowerStateOff];
}

-(void)updateExternalBrightness:(NSInteger)brightness{
	CGFloat _brightness = brightness * 0.01;
	
	LFXLight *lfxLight = self.lifxBulb;
	
	LFXHSBKColor *currentColor = [lfxLight color];
	LFXHSBKColor *newColor = [LFXHSBKColor colorWithHue:currentColor.hue saturation:currentColor.saturation brightness:_brightness];
	
	[lfxLight setColor:newColor];
}

-(void)updateExternalSaturation:(NSInteger)saturation{
	CGFloat _saturation = saturation * 0.01;
	
	LFXLight *lfxLight = self.lifxBulb;
	
	LFXHSBKColor *currentColor = [lfxLight color];
	LFXHSBKColor *newColor = [LFXHSBKColor colorWithHue:currentColor.hue saturation:_saturation brightness:currentColor.brightness];
	
	[lfxLight setColor:newColor];
}

-(void)updateExternalHue:(NSInteger)hue{
	LFXLight *lfxLight = [self lifxBulb];
	
	LFXHSBKColor *currentColor = [lfxLight color];
	LFXHSBKColor *newColor = [LFXHSBKColor colorWithHue:hue saturation:currentColor.saturation brightness:currentColor.brightness];
	
	[lfxLight setColor:newColor];
}

-(void)updateExternalKelvin:(uint16_t)kelvin{
	LFXLight *lfxLight = [self lifxBulb];
	
	LFXHSBKColor *currentColor = [lfxLight color];
	LFXHSBKColor *newColor = [LFXHSBKColor colorWithHue:currentColor.hue saturation:currentColor.saturation brightness:currentColor.brightness kelvin:kelvin];
	
	[lfxLight setColor:newColor];
}






#pragma mark - Properties

-(NSString*)deviceID{
	return self.accessory.serialNumber;
}

@end
