//
//  HKBLIFXDiscoveryService.h
//  HomeKitBridge
//
//  Created by Kyle Howells on 02/06/2015.
//  Copyright (c) 2015 Kyle Howells. All rights reserved.
//

#import "HKBDiscoveryService.h"
#import "HKBLightAccessoryLIFX.h"

@interface HKBLIFXDiscoveryService : HKBDiscoveryService
-(NSMenuItem*)createMenuItemForAccessory:(HKBLightAccessoryLIFX*)accessory;
@end
