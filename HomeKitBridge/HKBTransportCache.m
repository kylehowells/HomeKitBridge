//
//  HKBTransportCache.m
//  HomeKitBridge
//
//  Created by Kyle Howells on 31/05/2015.
//  Copyright (c) 2015 Kyle Howells. All rights reserved.
//

#import "HKBTransportCache.h"
#import "HAKAccessoryKit.h"


@implementation HKBTransportCache

+(HAKTransport*)transportForSerialNumber:(NSString*)serialNumber{
	NSString *filename = [serialNumber stringByAppendingString:@".plist"];
	NSURL *cacheFile = [[self cacheFolderURL] URLByAppendingPathComponent:filename];
	
	HAKTransport *transport = [NSKeyedUnarchiver unarchiveObjectWithFile:[cacheFile path]];
	if (transport) {
		return transport;
	}
	
	transport = [[HAKIPTransport alloc] init];
	[transport password]; // This init's the pass without this it breaks
	
	[NSKeyedArchiver archiveRootObject:transport toFile:[cacheFile path]];
	
	return transport;
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
