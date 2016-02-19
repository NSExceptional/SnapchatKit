//
//  SKChatInputStream.m
//  Pods
//
//  Created by Tanner on 1/3/16.
//
//

#import "SKChatInputStream.h"

#import "SKConnectPacket.h"
#import "SKChatMessagePacket.h"
#import "SKPresencePacket.h"
#import "SKMessageStatePacket.h"
#import "SKMessagePacket.h"
#import "SKErrorPacket.h"
#import "SKProtocolErrorPacket.h"
#import "SKConversationMessageResponsePacket.h"
#import "SKSnapStatePacket.h"
#import "SKPingPacket.h"

@implementation NSInputStream (SKChatOutputStream)

- (SKPacket *)recievePacket {
    // Read length
    union { uint8_t buffer[8]; NSUInteger length; } result;
    [self read:result.buffer maxLength:8];
    
    if (result.length > 900000) {
        [NSException raise:NSInternalInconsistencyException format:@"Bad packet length from server: %@", @(result.length)];
    }
    
    NSMutableData *data = [NSMutableData dataWithCapacity:result.length];
    [self read:(uint8_t *)data.bytes maxLength:result.length];
    
    return [self packetFromData:data];
}

- (SKPacket *)packetFromData:(NSData *)data {
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
            return [SKConnectPacket packet:json];
        }
        case SKPacketTypePresence: {
            return [SKPresencePacket packet:json];
        }
        case SKPacketTypeMessageState: {
            return [SKMessageStatePacket packet:json];
        }
        case SKPacketTypeMessageRelease: {
            return [SKMessagePacket packet:json];
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
            return [SKPingPacket packet:json];
        }
    }
}

@end
