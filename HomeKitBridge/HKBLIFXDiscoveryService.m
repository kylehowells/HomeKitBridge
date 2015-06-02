//
//  HKBLIFXDiscoveryService.m
//  HomeKitBridge
//
//  Created by Kyle Howells on 02/06/2015.
//  Copyright (c) 2015 Kyle Howells. All rights reserved.
//

#import "HKBLIFXDiscoveryService.h"

#import <LIFXKit/LIFXKit.h>
#import "HKBLightAccessoryLIFX.h"


@interface HKBLIFXDiscoveryService () <LFXLightCollectionObserver>
@property (nonatomic, strong) NSMutableDictionary *lightAccessories;
@end


@implementation HKBLIFXDiscoveryService

-(instancetype)init{
	if (self = [super init]) {
		self.lightAccessories = [NSMutableDictionary dictionary];
	}
	return self;
}


-(NSString*)displayName{
	return @"LIFX";
}


-(void)startDiscovering{
	[super startDiscovering];
	[[[LFXClient sharedClient] localNetworkContext].allLightsCollection addLightCollectionObserver:self];
}

-(void)stopDiscovering{
	[[[LFXClient sharedClient] localNetworkContext].allLightsCollection removeLightCollectionObserver:self];
	[super stopDiscovering];
}



-(NSArray*)allAccesories{
	return [[self.lightAccessories objectEnumerator] allObjects];
}




#pragma mark LFXLightCollectionObserver

-(void)lightCollection:(LFXLightCollection *)lightCollection didAddLight:(LFXLight *)light{
	[self addLight:light];
}
-(void)lightCollection:(LFXLightCollection *)lightCollection didRemoveLight:(LFXLight *)light{
	[self removeLight:light]; // TODO add this to -didBecomeUnAvailable as well
}


-(void)addLight:(LFXLight*)lifxLight{
	if (self.lightAccessories[lifxLight.deviceID] != nil) { return; }
	
	// Create light
	HKBLightAccessoryLIFX *light = [[HKBLightAccessoryLIFX alloc] initWithLightBulb:lifxLight];
	
	self.lightAccessories[lifxLight.deviceID] = light;
	[self.delegate discoveryService:self didDiscoverAccessory:light];
}
-(void)removeLight:(LFXLight*)lifxLight{
	if (self.lightAccessories[lifxLight.deviceID] == nil) { return; }
	
	HKBLightAccessoryLIFX *light = self.lightAccessories[lifxLight.deviceID];
	
	// Get rid of it
	[self.lightAccessories removeObjectForKey:lifxLight.deviceID];
	[self.delegate discoveryService:self didLoseAccessory:light];
}

@end
