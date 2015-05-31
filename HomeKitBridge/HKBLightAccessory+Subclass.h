//
//  HKBLightAccessory+Subclass.h
//  HomeKitBridge
//
//  Created by Kyle Howells on 13/10/2014.
//  Copyright (c) 2014 Kyle Howells. All rights reserved.
//


@interface HKBLightAccessory ()
@property (nonatomic, readonly) HAKService *lightBulbService;

@property (nonatomic, readonly) HAKCharacteristic *powerCharacteristic;
@property (nonatomic, readonly) HAKCharacteristic *saturationCharacteristic;
@property (nonatomic, readonly) HAKCharacteristic *hueCharacteristic;
@property (nonatomic, readonly) HAKCharacteristic *brightnessCharacteristic;
@end

