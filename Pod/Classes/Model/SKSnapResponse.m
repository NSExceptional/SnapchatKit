//
//  SKSnapResponse.m
//  SnapchatKit
//
//  Created by Tanner on 6/29/15.
//  Copyright (c) 2015 Tanner Bennett. All rights reserved.
//

#import "SKSnapResponse.h"

@implementation SKSentSnap

- (id)initWithDictionary:(NSDictionary *)json sender:(NSString *)sender {
    self = [super initWithDictionary:json];
    if (self) {
        _sender     = sender;
        _identifier = json[@"id"];
        _timestamp  = [NSDate dateWithTimeIntervalSince1970:[json[@"timestamp"] doubleValue]/1000];
    }
    
    return self;
}

- (id)initWithDictionary:(NSDictionary *)json {
    [NSException raise:NSInternalInconsistencyException format:@"Use -initWithDictionary:sender:"];
    return nil;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@ sender=%@, id=%@, ts=%lu>",
            NSStringFromClass(self.class), self.sender, self.identifier, (unsigned long)self.timestamp.timeIntervalSince1970];
}

@end


@implementation SKSnapResponse

- (id)initWithDictionary:(NSDictionary *)json {
    self = [super initWithDictionary:json];
    json = json[@"snap_response"];
    if (self) {
        _success = [json[@"success"] boolValue];
        
        NSMutableArray *snaps = [NSMutableArray array];
        for (NSString *sender in [json[@"snaps"] allKeys])
            [snaps addObject:[[SKSentSnap alloc] initWithDictionary:json[@"snaps"][sender] sender:sender]];
        
        _sentSnaps = snaps;
    }
    
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@ success=%d> Snaps:\n%@",
            NSStringFromClass(self.class), self.success, self.sentSnaps];
}

@end