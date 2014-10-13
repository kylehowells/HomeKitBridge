//
//  HKBLightAccessory.m
//  HomeKitBridge
//
//  Created by Kyle Howells on 11/10/2014.
//  Copyright (c) 2014 Kyle Howells. All rights reserved.
//

#import "HKBLightAccessory.h"
#import "HKBLightAccessory+Subclass.h"

@implementation HKBLightAccessory

+(NSDictionary*)defaultInformation{
	return @{NameKey: @"Lightbulb", ModelKey: @"WiFi Lightbulb v1.0", ManufacturerKey: @"Kyle Tech"};
}



#pragma mark - Setup

-(instancetype)initWithInformation:(NSDictionary*)information andCharacteristics:(HKBLightCharacteristics)characteristics{
	_characteristics = characteristics;
	
	if (self = [super initWithInformation:information]) {
		
	}
	
	return self;
}


-(void)setupServices{
	[super setupServices]; //IMPORTANT!
	
	HAKAccessoryInformationService *infomationService = self.accessory.accessoryInformationService;
	NSString *modelName = infomationService.modelCharacteristic.model;
	NSUInteger count = self.accessory.services.count;
	NSString *bulbName = [NSString stringWithFormat:@"LED Bulb %@ %lu", modelName, count];
	
	// Setup the lightbulb
	_lightBulbService = [[HAKLightBulbService alloc] init];
	
	
	// Name characteristic
	HAKNameCharacteristic *serviceName = [HAKNameCharacteristic new];
	serviceName.name = bulbName;
	[_lightBulbService setNameCharacteristic:serviceName];
	
	
	// If supports controlling brightness
	if (self.characteristics & HKBLightCharacteristicBrightness) {
		HAKBrightnessCharacteristic *brightnessCharacteristic = [[HAKBrightnessCharacteristic alloc] init];
		_lightBulbService.brightnessCharacteristic = brightnessCharacteristic;
	}
	
	// If supports controlling Hue
	if (self.characteristics & HKBLightCharacteristicHue) {
		HAKHueCharacteristic *hueCharacteristic = [[HAKHueCharacteristic alloc] init];
		_lightBulbService.hueCharacteristic = hueCharacteristic;
	}

	// If supports controlling Saturation
	if (self.characteristics & HKBLightCharacteristicSaturation) {
		HAKSaturationCharacteristic *saturationCharacteristic = [[HAKSaturationCharacteristic alloc] init];
		_lightBulbService.saturationCharacteristic = saturationCharacteristic;
	}
	
	
	[self.accessory addService:_lightBulbService];
}






#pragma mark - HomeKit Notification

-(void)characteristicDidUpdateValue:(HAKCharacteristic*)characteristic{
	
	if ([characteristic isKindOfClass:[HAKOnCharacteristic class]]) {
		HAKOnCharacteristic *onCharacteristic = (HAKOnCharacteristic*)characteristic;
		[self.delegate setLight:self powerState:onCharacteristic.boolValue];
	}
	
	
	if ([characteristic isKindOfClass:[HAKBrightnessCharacteristic class]]) {
		HAKBrightnessCharacteristic *_characteristic = (HAKBrightnessCharacteristic*)characteristic;
		
		if ([self.delegate respondsToSelector:@selector(setLight:brightness:)]) {
			[self.delegate setLight:self brightness:_characteristic.brightness];
		}
	}
	
	
	if ([characteristic isKindOfClass:[HAKSaturationCharacteristic class]]) {
		HAKSaturationCharacteristic *_characteristic = (HAKSaturationCharacteristic*)characteristic;
		
		if ([self.delegate respondsToSelector:@selector(setLight:saturation:)]) {
			[self.delegate setLight:self saturation:_characteristic.saturation];
		}
	}
	
	
	if ([characteristic isKindOfClass:[HAKHueCharacteristic class]]) {
		HAKHueCharacteristic *_characteristic = (HAKHueCharacteristic*)characteristic;
		
		if ([self.delegate respondsToSelector:@selector(setLight:hue:)]) {
			[self.delegate setLight:self hue:_characteristic.hue];
		}
	}
}






#pragma mark - Update HomeKit to changes

-(void)updatePowerState:(BOOL)newPowerState{
	[self.lightBulbService.onCharacteristic setBoolValue:newPowerState];
}

-(void)updateBrightness:(NSInteger)brightness{
	HAKBrightnessCharacteristic *bright = self.lightBulbService.brightnessCharacteristic;
	
	NSInteger min = [bright.minimumValue integerValue];
	NSInteger max = [bright.maximumValue integerValue];
	
	// Cap to min and max
	brightness = MIN(max, brightness);
	brightness = MAX(min, brightness);
	
	// Set it
	[bright setIntegerValue:brightness];
}

-(void)updateSaturation:(NSInteger)saturation{
	HAKSaturationCharacteristic *sat = self.lightBulbService.saturationCharacteristic;
	
	CGFloat min = [sat.minimumValue floatValue];
	CGFloat max = [sat.maximumValue floatValue];
	
	// Cap to min and max
	saturation = MIN(max, saturation);
	saturation = MAX(min, saturation);
	
	[sat setFloatValue:saturation];
}

-(void)updateHue:(NSInteger)hue{
	HAKHueCharacteristic *hueChar = self.lightBulbService.hueCharacteristic;
	
	CGFloat min = [hueChar.minimumValue floatValue];
	CGFloat max = [hueChar.maximumValue floatValue];
	
	// Cap to min and max
	hue = MIN(max, hue);
	hue = MAX(min, hue);
	
	[hueChar setFloatValue:hue];
}

@end
