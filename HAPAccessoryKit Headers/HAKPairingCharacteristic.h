/*
 *     Generated by class-dump 3.3.4 (64 bit).
 *
 *     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2011 by Steve Nygard.
 */

#import "HAKCharacteristic.h"

#import "HAKPairingSessionDelegate-Protocol.h"

@class NSMapTable,  NSString;

@interface HAKPairingCharacteristic : HAKCharacteristic <HAKPairingSessionDelegate>
{
    NSMapTable *_connections;
    dispatch_queue_t_connectionsQ;
}

+ (long long)writeResponseStatusWithPairingSessionStatus:(long long)arg1;
@property(retain, nonatomic) dispatch_queue_tconnectionsQ; // @synthesize connectionsQ=_connectionsQ;
@property(retain, nonatomic) NSMapTable *connections; // @synthesize connections=_connections;

- (id)handleWriteRequest:(id)arg1;
- (id)handleReadRequest:(id)arg1;
- (void)setValue:(id)arg1 forKey:(id)arg2;
- (id)value;
- (id)identifierForPairingSession:(id)arg1;
- (void)removePairingSessionForConnection:(id)arg1;
- (void)setPairingSession:(id)arg1 forConnection:(id)arg2;
- (id)pairingSessionForConnection:(id)arg1;
- (id)connectionForPairingSession:(id)arg1;
- (id)initWithType:(id)arg1 properties:(unsigned long long)arg2 format:(unsigned long long)arg3;


@end

