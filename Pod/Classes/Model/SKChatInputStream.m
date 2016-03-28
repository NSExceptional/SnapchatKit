//
//  SKChatInputStream.m
//  Pods
//
//  Created by Tanner on 1/3/16.
//
//

#import "SKChatInputStream.h"

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

#define num int
#define NUM_MAX 90000


@implementation NSInputStream (SKChatInputStream)

// For testing
- (NSData *)readData {
    if (!self.hasBytesAvailable) return nil;
    
    int buffer[1];
    if ([self read:buffer maxLength:4] > 0) {
        int length = NSSwapInt(buffer[0]);
        
        if (length >= USHRT_MAX || length < 0) { return nil; }
        // This feels wrong
        //    while (!self.hasBytesAvailable) {}
        char buff[length];
        [self read:buff maxLength:length];
        
        return [NSData dataWithBytes:buff length:length];
    }
    
    return nil;
}

- (SKPacket *)recievePacket {
    return [self packetFromData:[self readData]];
}

- (SKPacket *)packetFromData:(NSData *)data {
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

@end
