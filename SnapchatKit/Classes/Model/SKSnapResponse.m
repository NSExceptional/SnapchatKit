//
//  SKSnapResponse.m
//  SnapchatKit
//
//  Created by Tanner Bennett on 6/29/15.
//  Copyright (c) 2015 Tanner Bennett. All rights reserved.
//

#import "SKSnapResponse.h"


@implementation SKSentSnap

- (id)initWithDictionary:(NSDictionary *)json sender:(NSString *)sender {
    self = [super initWithDictionary:json];
    if (self) {
        _sender = sender;
    }
    
    return self;
}

/// Do not use

- (id)initWithDictionary:(NSDictionary *)json error:(NSError *__autoreleasing *)error { [NSException raise:NSInternalInconsistencyException format:@"Use -initWithDictionary:sender:"]; return nil; }

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@ sender=%@, id=%@, ts=%@>",
            NSStringFromClass(self.class), _sender, _identifier, @(_timestamp.timeIntervalSince1970).stringValue];
}

#pragma mark - Mantle

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{@"identifier": @"id",
             @"timestamp": @"timestamp"};
}

MTLTransformPropertyDate(timestamp)

@end


@implementation SKSnapResponse

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@ success=%d> Snaps:\n%@",
            NSStringFromClass(self.class), _success, _sentSnaps];
}

#pragma mark - Mantle

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{@"success": @"snap_response.success",
             @"sentSnaps": @"snap_response.snaps"};
}

+ (NSValueTransformer *)sentSnapsJSONTransformer {
    return [MTLValueTransformer transformerUsingForwardBlock:^id(NSDictionary *snaps, BOOL *success, NSError *__autoreleasing *error) {
        NSMutableArray *temp = [NSMutableArray array];
        for (NSString *sender in snaps.allKeys)
            [temp addObject:[[SKSentSnap alloc] initWithDictionary:snaps[sender] sender:sender]];
        return temp.copy;
    } reverseBlock:^id(NSArray *snaps, BOOL *success, NSError *__autoreleasing *error) {
        NSMutableDictionary *json = [NSMutableDictionary dictionary];
        for (SKSentSnap *snap in snaps)
            json[snap.sender] = snap.JSONDictionary;
        return json.copy;
    }];
}

@end