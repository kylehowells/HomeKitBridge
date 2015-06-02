//
//  HKBLightAccessory.m
//  HomeKitBridge
//
//  Created by Kyle Howells on 11/10/2014.
//  Copyright (c) 2014 Kyle Howells. All rights reserved.
//

#import "HKBLightAccessory.h"
#import "HKBLightAccessory+Subclass.h"


@interface HKBLightAccessory ()
@property (nonatomic, readonly) HAKCharacteristic *powerCharacteristic;
@property (nonatomic, readonly) HAKCharacteristic *saturationCharacteristic;
@property (nonatomic, readonly) HAKCharacteristic *hueCharacteristic;
@property (nonatomic, readonly) HAKCharacteristic *brightnessCharacteristic;
@end



@implementation HKBLightAccessory

+(NSDictionary*)defaultInformation{
	return @{NameKey: @"Lightbulb", ModelKey: @"WiFi Lightbulb v1.0", ManufacturerKey: @"Kyle Tech"};
}


#pragma mark - Setup

-(instancetype)initWithInformation:(NSDictionary*)information andCharacteristics:(HKBLightCapabilities)capabilities{
	_capabilities = capabilities;
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
	if (self.capabilities & HKBLightCapabilityBrightness)
	{
		_brightnessCharacteristic = [[HAKCharacteristic alloc] initWithType:[[HAKUUID alloc] initWithUUIDString:@"00000008"]];
		[_lightBulbService addCharacteristic:_brightnessCharacteristic];
	}
	
	// If supports controlling Hue
	if (self.capabilities & HKBLightCapabilityHue)
	{
		_hueCharacteristic = [[HAKCharacteristic alloc] initWithType:[[HAKUUID alloc] initWithUUIDString:@"00000013"]];
		[_lightBulbService addCharacteristic:_hueCharacteristic];
	}

	// If supports controlling Saturation
	if (self.capabilities & HKBLightCapabilitySaturation)
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
		[self updateExternalPowerState:[characteristic.value boolValue]];
	}
	else if (characteristic == _brightnessCharacteristic)
	{
		NSInteger brightness = [characteristic.value integerValue];
		[self updateExternalBrightness:brightness];
	}
	else if (characteristic == _saturationCharacteristic)
	{
		NSInteger saturation = [characteristic.value integerValue];
		[self updateExternalSaturation:saturation];
	}
	else if (characteristic == _hueCharacteristic)
	{
		NSInteger hue = [characteristic.value integerValue];
		[self updateExternalHue:hue];
	}
}


-(void)updateExternalPowerState:(BOOL)powerState{
	[self.delegate lightAccessory:self didChangePowerState:powerState];
}
-(void)updateExternalBrightness:(NSInteger)brightness{
	if ([self.delegate respondsToSelector:@selector(lightAccessory:didChangeBrightness:)]) {
		[self.delegate lightAccessory:self didChangeBrightness:brightness];
	}
}
-(void)updateExternalSaturation:(NSInteger)saturation{
	if ([self.delegate respondsToSelector:@selector(lightAccessory:didChangeSaturation:)]) {
		[self.delegate lightAccessory:self didChangeSaturation:saturation];
	}
}
-(void)updateExternalHue:(NSInteger)hue{
	if ([self.delegate respondsToSelector:@selector(lightAccessory:didChangeHue:)]) {
		[self.delegate lightAccessory:self didChangeHue:hue];
	}
}







#pragma mark - Update HomeKit to external changes

// - Conversion:	HomeKit
// hue;			//  [0, 360]
// saturation;	//	[0, 100]
// brightness;	//	[0, 100]

-(void)updateHomeKitPowerState:(BOOL)newPowerState{
	_powerCharacteristic.value = @(newPowerState);
}

-(void)updateHomeKitBrightness:(NSInteger)brightness{
	NSInteger min = 0;
	NSInteger max = 100;
	
	// Cap to min and max
	brightness = MIN(max, brightness);
	brightness = MAX(min, brightness);
	
	// Set it
	_brightnessCharacteristic.value = @(brightness);
}

-(void)updateHomeKitSaturation:(NSInteger)saturation{
	NSInteger min = 0;
	NSInteger max = 100;
	
	// Cap to min and max
	saturation = MIN(max, saturation);
	saturation = MAX(min, saturation);
	
	_saturationCharacteristic.value = @(saturation);
}

-(void)updateHomeKitHue:(NSInteger)hue{
	NSInteger min = 0;
	NSInteger max = 360;
	
	// Cap to min and max
	hue = MIN(max, hue);
	hue = MAX(min, hue);
	
	_hueCharacteristic.value = @(hue);
}

@end
