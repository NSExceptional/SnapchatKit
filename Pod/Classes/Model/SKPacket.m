//
//  SKPacket.m
//  Pods
//
//  Created by Tanner on 1/3/16.
//
//

#import "SKPacket.h"


extern NSString * SKStringFromPacketType(SKPacketType packetType) {
    switch (packetType) {
        case SKPacketTypeDefault:
            return @"";
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
