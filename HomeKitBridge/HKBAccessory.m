//
//  HKBAccessory.m
//  HomeKitBridge
//
//  Created by Kyle Howells on 11/10/2014.
//  Copyright (c) 2014 Kyle Howells. All rights reserved.
//

#import <objc/runtime.h>
#import "HKBAccessory.h"
#import "HKBTransportCache.h"




@implementation HKBAccessory{
	NSDictionary *setupInformation;
	
	HAKTransport *transport;
}
@synthesize accessory = accessory;

+(NSDictionary*)defaultInformation{
	return @{NameKey: @"Accessory", ModelKey: @"Accessory v1.0", ManufacturerKey: @"Kyle Tech"};
}


-(void)dealloc{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[transport stop];
	
	NSLog(@"-[HKBAccessory(%p) dealloc];", self);
}

-(instancetype)initWithInformation:(NSDictionary*)information{
	if (self = [super init]) {
		accessory = [[HAKAccessory alloc] init];
		
		setupInformation = information;
		[self setupServices]; // Subclass customisation point
		[self activateAccessory];
		
		// TODO: Proper Characteristic notification monitoring
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(characteristicDidUpdateValueNotification:) name:@"HAKCharacteristicDidUpdateValueNotification" object:nil];
	}
	
	return self;
}





-(void)characteristicDidUpdateValueNotification:(NSNotification *)notification {
	HAKCharacteristic *characteristic = notification.object;
	
	// If this notification is about us
	if ([characteristic.service.accessory isEqual:self.accessory]) {
		// Send the message off to the main thread, latency isn't an issue as this command has already made a network call.
		dispatch_async(dispatch_get_main_queue(), ^{
			[self characteristicDidUpdateValue:characteristic];
		});
	}
}









-(void)setupServices{
	NSDictionary *defaultInfomation = [[self class] defaultInformation];
	
	NSString *name = setupInformation[NameKey] ?: defaultInfomation[NameKey];
	NSString *manufacturer = setupInformation[ManufacturerKey] ?: defaultInfomation[ManufacturerKey];
	NSString *model = setupInformation[ModelKey] ?: defaultInfomation[ModelKey];
	
	NSString *serialNumber = setupInformation[SerialNumberKey];
	
	
	HAKAccessoryInformationService *infoService = [[HAKAccessoryInformationService alloc] init];
	infoService.nameCharacteristic.value = name;
	infoService.manufacturerCharacteristic.value = manufacturer;
	infoService.modelCharacteristic.value = model;
	infoService.serialNumberCharacteristic.value = serialNumber;
	[self.accessory addService:infoService];
	
	NSLog(@"Name should be: %@", name);
	NSLog(@"accessory.name: %@", accessory.name);
}

-(void)activateAccessory{
	HAKAccessoryInformationService *informationService = (HAKAccessoryInformationService*)[self.accessory accessoryInformationService];
	NSString *serialNumber = [informationService serialNumberCharacteristic].value;
	
	transport = [HKBTransportCache transportForSerialNumber:serialNumber];
	[transport addAccessory:self.accessory];
	
	NSLog(@"Transport: %@", transport);
	NSLog(@"Password: %@", transport.password);
	
	[transport start];
}

-(void)characteristicDidUpdateValue:(HAKCharacteristic*)characteristic{
	
}






#pragma mark - Property Getters

-(NSString *)name{
	return self.accessory.name;
}

-(NSString*)passcode{
	return transport.password;
}

@end

