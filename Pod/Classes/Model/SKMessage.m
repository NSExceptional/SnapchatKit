//
//  SKMessage.m
//  SnapchatKit
//
//  Created by Tanner Bennett on 5/19/15.
//  Copyright (c) 2015 Tanner Bennett. All rights reserved.
//

#import "SKMessage.h"

SKMessageKind SKMessageKindFromString(NSString *messageKindString) {
    if ([messageKindString isEqualToString:@"text"])
        return SKMessageKindText;
    if ([messageKindString isEqualToString:@"media"])
        return SKMessageKindMedia;
    if ([messageKindString isEqualToString:@"discover_share_v2"])
        return SKMessageKindDiscoverShared;
    if ([messageKindString isEqualToString:@"story_reply_v2"])
        return SKMessageKindStoryReply;
    
    return 0;
}

NSString * SKStringFromMessageKind(SKMessageKind messageKind) {
    switch (messageKind) {
        case SKMessageKindText:
            return @"text";
        case SKMessageKindMedia:
            return @"media";
        case SKMessageKindDiscoverShared:
            return @"discover_share_v2";
        case SKMessageKindStoryReply:
            return @"story_reply_v2";
    }
    
    [NSException raise:NSInternalInconsistencyException format:@"Invalid message kind: %@", @(messageKind).stringValue];
    return nil;
}

@implementation SKMessage

- (id)initWithDictionary:(NSDictionary *)json {
    self = [super initWithDictionary:json];
    if (self) {
        // Debugging //
        if (!self.messageKind)
            SKLog(@"Unknown message kind: %@", json[@"chat_message"][@"body"][@"type"]);
        
        if (!self.mediaType)
            _mediaType = @"UNSPECIFIED";
        else if (!([self.mediaType isEqualToString:@"VIDEO"] || [self.mediaType isEqualToString:@"IMAGE"]))
            NSLog(@"New media type: %@", self.mediaType);
        
        if (![_type isEqualToString:@"chat_message"])
            SKLog(@"Unknown chat message type: %@", _type);
    }
    
    return self;
}

- (NSString *)description {
    CGFloat width, height;
#ifndef UIKIT_EXTERN
    width = self.mediaWidth;
    height = self.mediaHeight;
#else
    width = self.mediaSize.width;
    height = self.mediaSize.height;
#endif
    return [NSString stringWithFormat:@"<%@ to/from=%@, text=%@, size={%f, %f}, index=%lu>",
            NSStringFromClass(self.class), self.sender?:self.recipients[0], self.text, width, height, (unsigned long)self.index];
}

#pragma mark - Mantle

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{@"identifier": @"chat_message.id",
             @"messageIdentifier": @"chat_message.chat_message_id",
             @"pagination": @"iter_token",
             @"messageKind": @"chat_message.body.type",
             @"created": @"chat_message.timestamp",
             
             // SKMessageKindMedia
             @"text": @"chat_message.body.text",
             @"mediaIdentifier": @"chat_message.body.media.media_id",
             @"mediaIV": @"chat_message.body.media.iv",
             @"mediaKey": @"chat_message.body.media.key",
             @"mediaType": @"chat_message.body.media.media_type",
#ifndef UIKIT_EXTERN
             @"mediaWidth": @"chat_message.body.media.width",
             @"mediaHeight": @"chat_message.body.media.height",
#else
             @"mediaSize": @"chat_message.body.media",
#endif
             @"conversationIdentifier": @"chat_message.header.conv_id",
             @"recipients": @"chat_message.header.to",
             @"sender": @"chat_message.header.from",
             @"index": @"chat_message.seq_num",
             @"savedState": @"chat_message.saved_state",
             @"type": @"chat_message.type",
             @"storyIdentifier": @"chat_message.body.media.media_attributes.story_id",
             @"zipped": @"chat_message.body.media.media_attributes.is_zipped"};
}

+ (NSArray *)ignoredJSONKeyPathPrefixes {
    static NSArray *ignored = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ignored = @[@"chat_message.saved_state", @"chat_message.preservations"];
    });
    
    return ignored;
}

+ (NSValueTransformer *)messageKindJSONTransformer {
    return [MTLValueTransformer transformerUsingForwardBlock:^id(NSString *type, BOOL *success, NSError *__autoreleasing *error) {
        return @(SKMessageKindFromString(type));
    } reverseBlock:^id(NSNumber *type, BOOL *success, NSError *__autoreleasing *error) {
        return SKStringFromMessageKind(type.integerValue);
    }];
}

#ifdef UIKIT_EXTERN
+ (NSValueTransformer *)mediaSizeJSONTransformer {
    return [MTLValueTransformer transformerUsingForwardBlock:^id(NSDictionary *media, BOOL *success, NSError *__autoreleasing *error) {
        if (!media) return nil;
        return [NSValue valueWithCGSize:CGSizeMake([media[@"width"] integerValue], [media[@"height"] integerValue])];
    } reverseBlock:^id(NSValue *size, BOOL *success, NSError *__autoreleasing *error) {
        if (size.CGSizeValue.width == 0 && size.CGSizeValue.height == 0) return nil;
        CGSize s = size.CGSizeValue;
        return @{@"width": @(s.width), @"height": @(s.height)};
    }];
}
#endif

MTLTransformPropertyDate(created)

#pragma mark - Equality

- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:[SKMessage class]])
        return [self isEqualToMessage:object];
    
    return [super isEqual:object];
}

- (BOOL)isEqualToMessage:(SKMessage *)message {
    return [self.identifier isEqualToString:message.identifier] && [self.text isEqualToString:message.text];
}

- (NSUInteger)hash {
    return self.identifier.hash;
}

- (NSComparisonResult)compare:(SKThing<SKPagination> *)thing {
    if ([thing respondsToSelector:@selector(created)])
        return [self.created compare:thing.created];
    return NSOrderedSame;
}

@end
