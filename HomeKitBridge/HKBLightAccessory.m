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
	self = [super initWithInformation:information];
	return self;
}


-(void)setupServices{
	[super setupServices]; //IMPORTANT!
	
	HAKAccessoryInformationService *infomationService = (HAKAccessoryInformationService*)self.accessory.accessoryInformationService;
	NSString *modelName = infomationService.modelCharacteristic.value;
	NSUInteger count = self.accessory.services.count;
	NSString *bulbName = [NSString stringWithFormat:@"LED Bulb %@ %lu", modelName, count];
	NSLog(@"bulbName: %@", bulbName);
	
	// Setup the lightbulb
	_lightBulbService = [[HAKService alloc] initWithType:[[HAKUUID alloc] initWithUUIDString:@"00000043"] name:@"Lightbulb"];
	_powerCharacteristic = [_lightBulbService characteristicWithType:[[HAKUUID alloc] initWithUUIDString:@"00000025"]];
	
	// If supports controlling brightness
	if (self.characteristics & HKBLightCharacteristicBrightness)
	{
		_brightnessCharacteristic = [[HAKCharacteristic alloc] initWithType:[[HAKUUID alloc] initWithUUIDString:@"00000008"]];
		[_lightBulbService addCharacteristic:_brightnessCharacteristic];
	}
	
	// If supports controlling Hue
	if (self.characteristics & HKBLightCharacteristicHue)
	{
		_hueCharacteristic = [[HAKCharacteristic alloc] initWithType:[[HAKUUID alloc] initWithUUIDString:@"00000013"]];
		[_lightBulbService addCharacteristic:_hueCharacteristic];
	}

	// If supports controlling Saturation
	if (self.characteristics & HKBLightCharacteristicSaturation)
	{
		_saturationCharacteristic = [[HAKCharacteristic alloc] initWithType:[[HAKUUID alloc] initWithUUIDString:@"0000002F"]];
		[_lightBulbService addCharacteristic:_saturationCharacteristic];
	}
	
	[self.accessory addService:_lightBulbService];
}






#pragma mark - HomeKit Notification

-(void)characteristicDidUpdateValue:(HAKCharacteristic*)characteristic{
	if (characteristic == _powerCharacteristic)
	{
		[self.delegate setLight:self powerState:[characteristic.value boolValue]];
	}
	else if (characteristic == _brightnessCharacteristic)
	{
		NSInteger brightness = [characteristic.value integerValue];
		
		if ([self.delegate respondsToSelector:@selector(setLight:brightness:)]) {
			[self.delegate setLight:self brightness:brightness];
		}
	}
	else if (characteristic == _saturationCharacteristic)
	{
		NSInteger saturation = [characteristic.value integerValue];
		
		if ([self.delegate respondsToSelector:@selector(setLight:saturation:)]) {
			[self.delegate setLight:self saturation:saturation];
		}
	}
	else if (characteristic == _hueCharacteristic)
	{
		NSInteger hue = [characteristic.value integerValue];
		
		if ([self.delegate respondsToSelector:@selector(setLight:hue:)]) {
			[self.delegate setLight:self hue:hue];
		}
	}
}






#pragma mark - Update HomeKit to changes

// - Conversion:	HomeKit
// hue;			//  [0, 360]
// saturation;	//	[0, 100]
// brightness;	//	[0, 100]

-(void)updatePowerState:(BOOL)newPowerState{
	_powerCharacteristic.value = @(newPowerState);
}

-(void)updateBrightness:(NSInteger)brightness{
	NSInteger min = 0;
	NSInteger max = 100;
	
	// Cap to min and max
	brightness = MIN(max, brightness);
	brightness = MAX(min, brightness);
	
	// Set it
	_brightnessCharacteristic.value = @(brightness);
}

-(void)updateSaturation:(NSInteger)saturation{
	NSInteger min = 0;
	NSInteger max = 100;
	
	// Cap to min and max
	saturation = MIN(max, saturation);
	saturation = MAX(min, saturation);
	
	_saturationCharacteristic.value = @(saturation);
}

-(void)updateHue:(NSInteger)hue{
	NSInteger min = 0;
	NSInteger max = 360;
	
	// Cap to min and max
	hue = MIN(max, hue);
	hue = MAX(min, hue);
	
	_hueCharacteristic.value = @(hue);
}

@end
