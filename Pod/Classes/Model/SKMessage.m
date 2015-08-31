//
//  SKMessage.m
//  SnapchatKit
//
//  Created by Tanner on 5/19/15.
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
    
    return 0;
}

@implementation SKMessage

- (id)initWithDictionary:(NSDictionary *)json {
    NSDictionary *message = json[@"chat_message"];
    NSDictionary *media   = message[@"body"][@"media"];
    NSDictionary *header  = message[@"header"];
    NSString *type        = message[@"body"][@"type"];
    
    // I merge these dictionaries with the rest of
    // the JSON so that unknownJSONKeys is more thorough.
    if (kDebugJSON) {
        NSMutableDictionary *fullJSON = json.mutableCopy;
        [fullJSON addEntriesFromDictionary:message];
        [fullJSON addEntriesFromDictionary:media];
        [fullJSON addEntriesFromDictionary:header];
        
        message = message.mutableCopy;
        [(NSMutableDictionary *)message setValue:[message[@"body"] mutableCopy] forKey:@"body"];
        
        fullJSON[@"chat_message"] = message;
        fullJSON[@"chat_message"][@"body"][@"media"] = @{};
        fullJSON[@"chat_message"][@"header"] = @{};
        json = fullJSON;
    }
    
    self = [super initWithDictionary:json];
    
    if (self) {
        _identifier        = message[@"id"];
        _messageIdentifier = message[@"chat_message_id"];
        _pagination        = json[@"iter_token"];
        _messageKind       = SKMessageKindFromString(type);
        _created           = [NSDate dateWithTimeIntervalSince1970:[message[@"timestamp"] doubleValue]/1000];
        
        switch (self.messageKind) {
            case SKMessageKindText: {
                _text = message[@"body"][@"text"];
                break;
            }
            case SKMessageKindDiscoverShared:
            case SKMessageKindMedia: {
                _mediaIdentifier = media[@"media_id"];
                _mediaSize       = CGSizeMake([media[@"width"] integerValue], [media[@"height"] integerValue]);
                _mediaIV         = media[@"iv"];
                _mediaKey        = media[@"key"];
                _mediaType       = media[@"media_type"];
                if (!self.mediaType)
                    _mediaType = @"UNSPECIFIED";
                else if (![self.mediaType isEqualToString:@"VIDEO"])
                    NSLog(@"New media type: %@", self.mediaType);
                
                break;
            }
            default: {
                SKLog(@"Unknown message kind: %@", type);
            }
        }
        
        _conversationIdentifier = header[@"conv_id"];
        
        _recipients = header[@"to"];
        _sender     = header[@"from"];

        _index      = [message[@"seq_num"] integerValue];
        _savedState = message[@"saved_state"];
        _type       = message[@"type"];
        
        // Debugging
        if (![_type isEqualToString:@"chat_message"])
            SKLog(@"Unknown chat message type: %@", _type);
    }
    
    [[self class] addKnownJSONKeys:@[@"chat_message", @"body", @"header", @"id", @"chat_message_id", @"iter_token",
                                              @"timestamp", @"media_id", @"width", @"height", @"iv", @"key", @"conv_id",
                                              @"to", @"from", @"seq_num", @"saved_state", @"type", @"media_type"]];
    
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@ to/from=%@, text=%@, size={%f, %f}, index=%lu>",
            NSStringFromClass(self.class), self.sender?:self.recipients[0], self.text, self.mediaSize.width, self.mediaSize.height, (unsigned long)self.index];
}

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
