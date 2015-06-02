//
//  HKBDiscoveryService.m
//  HomeKitBridge
//
//  Created by Kyle Howells on 02/06/2015.
//  Copyright (c) 2015 Kyle Howells. All rights reserved.
//

#import "HKBDiscoveryService.h"
#import <objc/runtime.h>

NSArray *ClassGetSubclasses(Class parentClass);


@interface HKBDiscoveryService ()
@property (nonatomic, assign, getter=isDiscovering) BOOL discovering;
@end

@implementation HKBDiscoveryService

+(NSArray*)allServices{
	static NSArray *allServices = nil;
	
	if (allServices == nil) {
		// Get all HKBDiscoveryService subclasses automatically
		// From: http://www.cocoawithlove.com/2010/01/getting-subclasses-of-objective-c-class.html
		Class parentClass = [HKBDiscoveryService class];
		int numClasses = objc_getClassList(NULL, 0);
		Class *classes = NULL;
		
		classes = (Class*)malloc(sizeof(Class) * numClasses);
		numClasses = objc_getClassList(classes, numClasses);
		
		NSMutableArray *result = [NSMutableArray array];
		for (NSInteger i = 0; i < numClasses; i++)
		{
			Class superClass = classes[i];
			do
			{
				superClass = class_getSuperclass(superClass);
			} while(superClass && superClass != parentClass);
			
			if (superClass == nil) {
				continue;
			}
			
			[result addObject:classes[i]];
		}
		free(classes);
		
		allServices = result;
	}
	
	return allServices;
}




-(NSString *)displayName{
	return @"OVERRIDE";
}

-(void)startDiscovering
{
	self.discovering = YES;
	
	// Do nothing, implement in subclass
}

-(void)stopDiscovering
{
	self.discovering = NO;
	
	// Do nothing, implement in subclass
}

-(NSArray*)allAccesories{
	// Implement in subclass
	
	return nil;
}

@end

