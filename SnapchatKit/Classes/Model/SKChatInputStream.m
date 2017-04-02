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


@implementation NSInputStream (SKChatInputStream)

// For testing
- (NSData *)readData {
    uint8_t buffer[1];
    if ([self read:buffer maxLength:4] > 0) {
        int length = NSSwapInt(buffer[0]);
        
        if (length >= USHRT_MAX || length < 0) { return nil; }
        
        uint8_t buff[length];
        if ([self read:buff maxLength:length] > 0) {
            return [NSData dataWithBytes:buff length:length];
        }
    }
    
    return nil;
}

- (SKPacket *)recievePacket {
    return [SKPacket packetFromData:[self readData]];
}

@end
