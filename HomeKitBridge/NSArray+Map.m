//
//  NSArray+Map.m
//  HomeKitBridge
//
//  Created by Kyle Howells on 02/06/2015.
//  Copyright (c) 2015 Kyle Howells. All rights reserved.
//

#import "NSArray+Map.h"

@implementation NSArray (Map)

-(NSArray*)mapObjectsUsingBlock:(id (^)(id obj, NSUInteger idx))block {
	NSMutableArray *result = [NSMutableArray arrayWithCapacity:[self count]];
	[self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		[result addObject:block(obj, idx)];
	}];
	return result;
}

@end