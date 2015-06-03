//
//  HKBDiscoveryService.h
//  HomeKitBridge
//
//  Created by Kyle Howells on 02/06/2015.
//  Copyright (c) 2015 Kyle Howells. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import "HKBAccessory.h"


@class HKBDiscoveryService;

@protocol HKBDiscoveryServiceDelegate <NSObject>
-(void)discoveryService:(HKBDiscoveryService *)service didDiscoverAccessory:(HKBAccessory *)accessory;
-(void)discoveryService:(HKBDiscoveryService *)service didLoseAccessory:(HKBAccessory *)accessory;
@end



@interface HKBDiscoveryService : NSObject
/**
*  Returns all the HKBDiscoveryService subclasses
*
*  @return Array of Class objects
*/
+(NSArray*)allServices;




/// Display name to be shown in the menu bar
-(NSString*)displayName; // Sub to be overriden

@property (nonatomic, assign) id <HKBDiscoveryServiceDelegate> delegate;

/// All the HKBAccessory objects it has discovered
-(NSArray*)allAccesories; // Sub to be overriden



///  Is it currently searching for accessories
-(BOOL)isDiscovering NS_REQUIRES_SUPER;

/// Start discovering accessories
-(void)startDiscovering NS_REQUIRES_SUPER; // Sub to be overriden

/// Stop discovering accessories
-(void)stopDiscovering NS_REQUIRES_SUPER; // Sub to be overriden


-(NSMenuItem*)createMenuItemForAccessory:(HKBAccessory*)accessory;

@end

