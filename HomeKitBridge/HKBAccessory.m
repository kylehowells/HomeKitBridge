//
//  HKBAccessory.m
//  HomeKitBridge
//
//  Created by Kyle Howells on 11/10/2014.
//  Copyright (c) 2014 Kyle Howells. All rights reserved.
//

#import <objc/runtime.h>
#import "HKBAccessory.h"


@interface HKBAccessory (Transport_Cache)
+(HAKTransportManager*)transportManagerForSerialNumber:(NSString*)serialNumber;
@end






@implementation HKBAccessory (Default_Information)

/**
 *  The default device information to be used if none is supplied.
 */
+(NSDictionary*)defaultInformation{
	return objc_getAssociatedObject(self, @selector(defaultInformation));
}
/**
 *  Set the default device information to be used if none is supplied
 *
 *  @param information Keys: "name", "manufacturer", "model"
 */
+(void)setDefaultInformation:(NSDictionary*)information{
	objc_setAssociatedObject(self, @selector(defaultInformation), information, OBJC_ASSOCIATION_COPY);
}

@end




@implementation HKBAccessory{
	NSDictionary *setupInformation;
	
	HAKTransportManager *transportManager;
}

-(void)dealloc{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	NSLog(@"-[HKBAccessory(%p) dealloc];", self);
}

-(instancetype)initWithInformation:(NSDictionary*)information{
	if (self = [super init]) {
		_accessory = [[HAKAccessory alloc] init];
		
		setupInformation = information;
		[self setupServices]; // Subclass customisation point
		[self activateAccessory];
		
		// TODO: Proper Characteristic notification monitoring
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(characteristicDidUpdateValueNotification:) name:@"HAKCharacteristicDidUpdateValueNotification" object:nil];
	}
	
	return self;
}





-(void)characteristicDidUpdateValueNotification:(NSNotification *)aNote {
	HAKCharacteristic *characteristic = aNote.object;
	
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
	infoService.nameCharacteristic.name = name;
	infoService.manufacturerCharacteristic.manufacturer = manufacturer;
	infoService.modelCharacteristic.model = model;
	infoService.serialNumberCharacteristic.serialNumber = serialNumber;
	[self.accessory addService:infoService];
}

-(void)activateAccessory{
	HAKAccessoryInformationService *informationService = [self.accessory accessoryInformationService];
	NSString *name = [informationService nameCharacteristic].name;
	NSString *serialNumber = [informationService serialNumberCharacteristic].serialNumber;
	
	transportManager = [[self class] transportManagerForSerialNumber:serialNumber];
	[self.transport addAccessory:self.accessory];
	
	NSLog(@"Transport: %@", self.transport);
	NSLog(@"Password: %@", self.transport.password);
	
	[transportManager setName:name];
	[self.transport setName:name];
	
	[self.transport start];
}

-(void)characteristicDidUpdateValue:(HAKCharacteristic*)characteristic{
	
}






#pragma mark - Property Getters

-(HAKTransport*)transport{
	return [transportManager.transports firstObject];
}

-(NSString *)name{
	return self.accessory.accessoryInformationService.nameCharacteristic.name;
}

-(NSString*)passcode{
	return self.transport.password;
}

@end









@implementation HKBAccessory (Transport_Cache)

+(HAKTransportManager*)transportManagerForSerialNumber:(NSString*)serialNumber{
	NSString *filename = [serialNumber stringByAppendingString:@".plist"];
	NSURL *cacheFile = [[self cacheFolderURL] URLByAppendingPathComponent:filename];
	
	HAKTransportManager *transportManager = nil;
	
	if ([[NSFileManager defaultManager] fileExistsAtPath:[cacheFile path]]) {
		transportManager = [[HAKTransportManager alloc] initWithURL:cacheFile];
		NSLog(@"Recovered transport manager: %@", transportManager);
	}
	
	// Loading the file failed
	if (transportManager == nil) {
		HAKIPTransport *transport = [HAKIPTransport new];
		
		// Can we cache just the HAKTransportManager and kick out all the services first?
		transportManager = [HAKTransportManager new];
		[transportManager addTransport:transport];
		
		NSLog(@"Created new Transport Manager: %@", transportManager);
		
		[transport password]; // This init's the pass without this it breaks
		[transportManager writeToURL:cacheFile atomically:YES];
	}
	
	return transportManager;
}


+(NSURL*)cacheFolderURL{
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSURL *appFolder = [[fileManager URLForDirectory:NSApplicationSupportDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:YES error:nil] URLByAppendingPathComponent:[[NSBundle mainBundle] bundleIdentifier]];
	
	if ([fileManager fileExistsAtPath:[appFolder path]] == NO) {
		[fileManager createDirectoryAtPath:[appFolder path] withIntermediateDirectories:NO attributes:nil error:nil];
	}
	
	return appFolder;
}

@end



