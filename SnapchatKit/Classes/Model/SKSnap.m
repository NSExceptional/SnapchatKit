//
//  SKSnap.m
//  SnapchatKit
//
//  Created by Tanner on 5/19/15.
//  Copyright (c) 2015 Tanner Bennett. All rights reserved.
//

#import "SKSnap.h"

@implementation SKSnap

- (id)initWithDictionary:(NSDictionary *)json {
    self = [super initWithDictionary:json];
    
    if (self) {
        _sender                 = json[@"sn"];
        _recipient              = json[@"rp"];
        _identifier             = json[@"id"];
        _conversationIdentifier = json[@"c_id"];
        _mediaKind              = [json[@"m"] integerValue];
        _status                 = [json[@"st"] integerValue];
        _screenshots            = [json[@"c"] integerValue];
        _timer                  = [json[@"t"] integerValue];
        _mediaTimer             = [json[@"timer"] floatValue];
        _sentDate               = [NSDate dateWithTimeIntervalSince1970:[json[@"test"] doubleValue]/1000];
    }
    
    [self.knownJSONKeys addObjectsFromArray:@[@"sn", @"rp", @"id", @"c_id", @"m", @"st", @"c", @"t", @"timer"]];
    
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@ to/from=%@, kind=%lu, duration=%f, screenshots=%lu>",
            NSStringFromClass(self.class), self.sender?:self.recipient, self.mediaKind, self.mediaTimer, self.screenshots];
}

- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:[SKSnap class]])
        return [self isEqualToSnap:object];
    
    return [super isEqual:object];
}

- (BOOL)isEqualToSnap:(SKSnap *)snap {
    return [self.identifier isEqualToString:snap.identifier];
}

@end
