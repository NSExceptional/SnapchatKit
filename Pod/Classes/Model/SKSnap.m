//
//  SKSnap.m
//  SnapchatKit
//
//  Created by Tanner on 5/19/15.
//  Copyright (c) 2015 Tanner Bennett. All rights reserved.
//

#import "SKSnap.h"
#import "SKBlob.h"
#import "SKClient+Snaps.h"

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
        _sentDate               = [NSDate dateWithTimeIntervalSince1970:[json[@"sts"] doubleValue]/1000];
        _sentDate               = [NSDate dateWithTimeIntervalSince1970:[json[@"ts"] doubleValue]/1000];
        _zipped                 = [json[@"zipped"] boolValue];
    }
    
    [[self class] addKnownJSONKeys:@[@"sn", @"rp", @"id", @"c_id", @"m", @"st", @"c", @"t", @"sts", @"ts", @"timer", @"zipped"]];
    
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@ to/from=%@, kind=%lu, duration=%f, screenshots=%lu>",
            NSStringFromClass(self.class), self.sender?:self.recipient, (long)self.mediaKind, self.mediaTimer, (unsigned long)self.screenshots];
}

- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:[SKSnap class]])
        return [self isEqualToSnap:object];
    
    return [super isEqual:object];
}

- (BOOL)isEqualToSnap:(SKSnap *)snap {
    return [self.identifier isEqualToString:snap.identifier];
}

- (NSUInteger)hash {
    return self.identifier.hash;
}

@end


@implementation SKSnap (SKClient)

- (void)load:(ErrorBlock)completion {
    NSParameterAssert(completion);
    [[SKClient sharedClient] loadSnap:self completion:^(SKBlob *blob, NSError *error) {
        if (!error) {
            _blob = blob;
            completion(nil);
        } else {
            completion(error);
        }
    }];
}

- (NSString *)suggestedFilename {
    if (!self.blob)
        return nil;
    return [NSString stringWithFormat:@"%@~%@", self.sender, self.identifier];
//    if (self.blob.isImage)
//        return [NSString stringWithFormat:@"%@.jpg", self.identifier];
//    else if (self.blob.overlay)
//        return self.identifier;
//    else
//        return [NSString stringWithFormat:@"%@.mp4", self.identifier];
}

@end