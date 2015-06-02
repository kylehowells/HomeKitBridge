//
//  NSArray+Map.h
//  HomeKitBridge
//
//  Created by Kyle Howells on 02/06/2015.
//  Copyright (c) 2015 Kyle Howells. All rights reserved.
//
// http://stackoverflow.com/a/7248251/458205

#import <Foundation/Foundation.h>

@interface NSArray (Map)
-(NSArray*)mapObjectsUsingBlock:(id (^)(id obj, NSUInteger idx))block;
@end
