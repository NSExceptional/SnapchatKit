//
//  SKSnap.m
//  SnapchatKit
//
//  Created by Tanner Bennett on 5/19/15.
//  Copyright (c) 2015 Tanner Bennett. All rights reserved.
//

#import "SKSnap.h"
#import "SKBlob.h"
#import "SKClient+Snaps.h"

@implementation SKSnap

- (id)initWithDictionary:(NSDictionary *)json error:(NSError *__autoreleasing *)error {
    if (!json.allKeys.count) return nil;
    
    self = [super initWithDictionary:json error:error];
    if (self) {
        _isOutgoing = [_identifier hasSuffix:@"s"];
    }
    
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@ to/from=%@, kind=%lu, duration=%f, screenshots=%lu>",
            NSStringFromClass(self.class), self.sender?:self.recipient, (long)self.mediaKind, self.mediaTimer, (unsigned long)self.screenshots];
}

#pragma mark - Mantle

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{@"sender": @"sn",
             @"recipient": @"rp",
             @"identifier": @"id",
             @"conversationIdentifier": @"c_id",
             @"mediaKind": @"m",
             @"status": @"st",
             @"screenshots": @"c",
             @"timer": @"t",
             @"mediaTimer": @"timer",
             @"sentDate": @"sts",
             @"timestamp": @"ts",
             @"zipped": @"zipped",
             @"esIdentifier": @"es_id",
             @"mo": @"mo"};
}

MTLTransformPropertyDate(sentDate)
MTLTransformPropertyDate(timestamp)

#pragma mark - Equality

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