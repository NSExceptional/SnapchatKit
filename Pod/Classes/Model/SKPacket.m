//
//  SKPacket.m
//  Pods
//
//  Created by Tanner on 1/3/16.
//
//

#import "SKPacket.h"
#import "SKConnectPacket.h"
#import "SKConnectResponsePacket.h"
#import "SKChatMessagePacket.h"
#import "SKPresencePacket.h"
#import "SKMessageStatePacket.h"
#import "SKReleaseMessagePacket.h"
#import "SKErrorPacket.h"
#import "SKProtocolErrorPacket.h"
#import "SKConversationMessageResponsePacket.h"
#import "SKSnapStatePacket.h"
#import "SKPingResponsePacket.h"


extern NSString * SKStringFromPacketType(SKPacketType packetType) {
    switch (packetType) {
        case SKPacketTypeDefault:
            return @"";
        case SKPacketTypeConnect:
            return @"connect";
        case SKPacketTypeConnectResponse:
            return @"connect_response";
        case SKPacketTypeDisconnect:
            return @"disconnect";
        case SKPacketTypePresence:
            return @"presence";
        case SKPacketTypeMessageState:
            return @"message_state";
        case SKPacketTypeMessageRelease:
            return @"message_release";
        case SKPacketTypeChatMessage:
            return @"chat_message";
        case SKPacketTypeError:
            return @"error";
        case SKPacketTypeProtocolError:
            return @"protocol_error";
        case SKPacketTypeConversationMessageResponse:
            return @"conversation_message_response";
        case SKPacketTypeSnapState:
            return @"snap_state";
        case SKPacketTypePing:
            return @"ping";
        case SKPacketTypePingResponse:
            return @"ping_response";
    }
    
    [NSException raise:NSInternalInconsistencyException format:@"Cannot convert packetType to string: %@", @(packetType)];
    return nil;
}

extern SKPacketType SKPacketTypeFromString(NSString *packetType) {
    if ([packetType isEqualToString:@"connect"])
        return SKPacketTypeConnect;
    if ([packetType isEqualToString:@"connect_response"])
        return SKPacketTypeConnectResponse;
    if ([packetType isEqualToString:@"disconnect"])
        return SKPacketTypeDisconnect;
    if ([packetType isEqualToString:@"presence"])
        return SKPacketTypePresence;
    if ([packetType isEqualToString:@"message_state"])
        return SKPacketTypeMessageState;
    if ([packetType isEqualToString:@"message_release"])
        return SKPacketTypeMessageRelease;
    if ([packetType isEqualToString:@"chat_message"])
        return SKPacketTypeChatMessage;
    if ([packetType isEqualToString:@"error"])
        return SKPacketTypeError;
    if ([packetType isEqualToString:@"protocol_error"])
        return SKPacketTypeProtocolError;
    if ([packetType isEqualToString:@"conversation_message_response"])
        return SKPacketTypeConversationMessageResponse;
    if ([packetType isEqualToString:@"snap_state"])
        return SKPacketTypeSnapState;
    if ([packetType isEqualToString:@"ping"])
        return SKPacketTypePing;
    if ([packetType isEqualToString:@"ping_response"])
        return SKPacketTypePingResponse;
    
    return SKPacketTypeDefault;
}


@implementation SKPacket

+ (instancetype)packet:(NSDictionary *)json {
    NSError *error = nil;
    SKPacket *packet = [MTLJSONAdapter modelOfClass:[self class] fromJSONDictionary:json error:&error];
    
    if (error) {
        NSLog(@"%@", error.localizedDescription);
    } else {
        packet->_json = json;
        packet->_packetType = SKPacketTypeFromString(json[@"type"]);
    }
    
    return packet;
}

+ (instancetype)packetFromData:(NSData *)data {
    if (data.length == 0) return nil;
    
    NSError *jsonError = nil;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
    if (jsonError) {
        [NSException raise:NSInternalInconsistencyException format:@"Bad JSON from server: %@", jsonError.localizedDescription];
    }
    
    switch (SKPacketTypeFromString(json[@"type"])) {
        case SKPacketTypeDefault: {
            return [SKPacket packet:json];
        }
        case SKPacketTypeConnectResponse: {
            return [SKConnectResponsePacket packet:json];
        }
        case SKPacketTypePresence: {
            return [SKPresencePacket packet:json];
        }
        case SKPacketTypeMessageState: {
            return [SKMessageStatePacket packet:json];
        }
        case SKPacketTypeMessageRelease: {
            return [SKReleaseMessagePacket packet:json];
        }
        case SKPacketTypeChatMessage: {
            return [SKChatMessagePacket packet:json];
        }
        case SKPacketTypeError: {
            return [SKErrorPacket packet:json];
        }
        case SKPacketTypeProtocolError: {
            return [SKProtocolErrorPacket packet:json];
        }
        case SKPacketTypeConversationMessageResponse: {
            return [SKConversationMessageResponsePacket packet:json];
        }
        case SKPacketTypeSnapState: {
            return [SKSnapStatePacket packet:json];
        }
        case SKPacketTypePingResponse: {
            return [SKPingResponsePacket packet:json];
        }
    }
}

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{@"type": @"type", @"identifier": @"id"};
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@> JSON:\n%@",
            NSStringFromClass(self.class), self.json];
}

+ (NSValueTransformer *)propertypacketTypeJSONTransformer {
    return [MTLValueTransformer transformerUsingForwardBlock:^id(NSString *value, BOOL *success, NSError *__autoreleasing *error) {
        return @(SKPacketTypeFromString(value));
    } reverseBlock:^id(NSNumber *value, BOOL *success, NSError *__autoreleasing *error) {
        return SKStringFromPacketType(value.integerValue);
    }];
}

+ (NSValueTransformer *)sk_dateTransformer {
    return [MTLValueTransformer transformerUsingForwardBlock:^id(NSString *ts, BOOL *success, NSError *__autoreleasing *error) {
        return ts.doubleValue > 0 ? [NSDate dateWithTimeIntervalSince1970:ts.doubleValue/1000.f] : nil;
    } reverseBlock:^id(NSDate *ts, BOOL *success, NSError *__autoreleasing *error) {
        return ts ? @([ts timeIntervalSince1970] * 1000.f).stringValue : nil;
    }];
}

@end
