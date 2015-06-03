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




#pragma mark - Delegate methods

-(void)notifyDelegateOfPowerChange{
	[self.delegate lightAccessory:self didChangePowerState:self.powerState];
}
-(void)notifyDelegateOfBrightnessChange{
	if ([self.delegate respondsToSelector:@selector(lightAccessory:didChangeBrightness:)]) {
		[self.delegate lightAccessory:self didChangeBrightness:self.brightness];
	}
}
-(void)notifyDelegateOfSaturationChange{
	if ([self.delegate respondsToSelector:@selector(lightAccessory:didChangeSaturation:)]) {
		[self.delegate lightAccessory:self didChangeSaturation:self.saturation];
	}
}
-(void)notifyDelegateOfHueChange{
	if ([self.delegate respondsToSelector:@selector(lightAccessory:didChangeHue:)]) {
		[self.delegate lightAccessory:self didChangeHue:self.hue];
	}
}




#pragma mark - Update external API to HomeKit changes

-(void)updateExternalPowerState:(BOOL)powerState
{
	// Do nothing, implement in subclass
	[self notifyDelegateOfPowerChange];
}
-(void)updateExternalBrightness:(NSInteger)brightness
{
	// Do nothing, implement in subclass
	[self notifyDelegateOfBrightnessChange];
}
-(void)updateExternalSaturation:(NSInteger)saturation
{
	// Do nothing, implement in subclass
	[self notifyDelegateOfSaturationChange];
}
-(void)updateExternalHue:(NSInteger)hue
{
	// Do nothing, implement in subclass
	[self notifyDelegateOfHueChange];
}









#pragma mark - Update HomeKit to external changes

// - Conversion:	HomeKit
// hue;			//  [0, 360]
// saturation;	//	[0, 100]
// brightness;	//	[0, 100]

-(void)updateHomeKitPowerState:(BOOL)newPowerState{
	_powerCharacteristic.value = @(newPowerState);
	
	[self notifyDelegateOfPowerChange];
}

-(void)updateHomeKitBrightness:(NSInteger)brightness{
	HAKCharacteristic *characteristic = _brightnessCharacteristic;
	
	if ([characteristic.constraints validateValue:@(brightness)])
	{
		characteristic.value = @(brightness);
		
		[self notifyDelegateOfBrightnessChange];
	}
}

-(void)updateHomeKitSaturation:(NSInteger)saturation{
	HAKCharacteristic *characteristic = _saturationCharacteristic;
	
	if ([characteristic.constraints validateValue:@(saturation)])
	{
		characteristic.value = @(saturation);
		
		[self notifyDelegateOfSaturationChange];
	}
}

-(void)updateHomeKitHue:(NSInteger)hue{
	HAKCharacteristic *characteristic = _hueCharacteristic;
	
	if ([characteristic.constraints validateValue:@(hue)])
	{
		characteristic.value = @(hue);
		
		[self notifyDelegateOfHueChange];
	}
}






#pragma mark - Commands

-(BOOL)powerState{
	return [self.powerCharacteristic.value boolValue];
}
-(void)setPowerState:(BOOL)powerState{
	[self updateExternalPowerState:powerState];
	[self updateHomeKitPowerState:powerState];
	// TODO: This calls the delegate twice, need to think of a fix
}

-(NSInteger)brightness{
	return [self.brightnessCharacteristic.value integerValue];
}
-(void)setBrightness:(NSInteger)brightness{
	[self updateExternalBrightness:brightness];
	[self updateHomeKitBrightness:brightness];
}

-(NSInteger)saturation{
	return [self.saturationCharacteristic.value integerValue];
}
-(void)setSaturation:(NSInteger)saturation{
	[self updateExternalSaturation:saturation];
	[self updateHomeKitSaturation:saturation];
}

-(NSInteger)hue{
	return [self.hueCharacteristic.value integerValue];
}
-(void)setHue:(NSInteger)hue{
	[self updateExternalHue:hue];
	[self updateHomeKitHue:hue];
}

@end
