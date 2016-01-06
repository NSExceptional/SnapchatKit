//
//  SKChatRoom.m
//  Pods
//
//  Created by Tanner on 1/3/16.
//
//

#import "SKChatRoom.h"
#import "SKChatInputStream.h"
#import "SKChatOutputStream.h"
#import "TBQueue.h"

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

//@class SKPacket, SKConnectPacket, SKPresencePacket, SKMessageStatePacket, SKMessagePacket, SKErrorPacket, SKProtocolErrorPacket, SKConversationMessageResponsePacket, SKSnapStatePacket, SKPingPacket;

typedef NSInputStream SKChatInputStream;
typedef NSOutputStream SKChatOutputStream;

@interface SKChatRoom ()

@property (nonatomic) SKChatInputStream  *inputStream;
@property (nonatomic) SKChatOutputStream *outputStream;

@property (nonatomic) TBQueue *outgoingMessages;

@property (nonatomic) NSString *user;
@property (nonatomic) NSString *recipient;

@property (nonatomic) NSString *conversationMac;
@property (nonatomic) NSString *conversationPayload;
@property (nonatomic) NSString *gatewayMac;
@property (nonatomic) NSString *gatewayPayload;
@property (nonatomic) NSString *server;
@property (nonatomic) NSInteger port;

@end

@implementation SKChatRoom

+ (instancetype)chatRoomForConversation:(SKConversation *)convo messagingGatewayAuth:(NSDictionary *)gatewayAuth {
    return [[self alloc] initWithConversation:convo messagingGatewayAuth:gatewayAuth];
}

- (id)initWithConversation:(SKConversation *)convo messagingGatewayAuth:(NSDictionary *)gatewayAuth {
    NSParameterAssert(convo); NSParameterAssert(gatewayAuth);
    
    self = [super init];
    if (self) {
        // Get server info
        NSArray *parts = [gatewayAuth[@"gateway_server"] componentsSeparatedByString:@":"];
        _server = parts[0];
        _port = [parts[1] integerValue];
        
        _user = convo.recipient;
        _recipient = convo.sender;
        
        _conversationMac     = convo.messagingAuth[@"mac"];
        _conversationPayload = convo.messagingAuth[@"payload"];
        _gatewayMac          = gatewayAuth[@"gateway_auth_token"][@"mac"];
        _gatewayPayload      = gatewayAuth[@"gateway_auth_token"][@"payload"];
        
        _outgoingMessages = [TBQueue new];
    }
    
    return self;
}

- (void)enterRoom {
    [self.outgoingMessages clear];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        // Init I/O streams
        CFReadStreamRef readStream;
        CFWriteStreamRef writeStream;
        CFStreamCreatePairWithSocketToHost(NULL, (__bridge CFStringRef)_server, (unsigned int)_port, &readStream, &writeStream);
        _inputStream = (__bridge SKChatInputStream *)readStream;
        _outputStream = (__bridge SKChatOutputStream *)writeStream;
        
        [self startIncomingThread];
        [self startOutgoingThread];
        [self sendConnectMessage];
    });
}

- (void)leaveRoom {
    
}

- (void)sendConnectMessage {
    SKConnectPacket *connected = nil;
    [self sendPacket:connected];
}

- (void)startIncomingThread {
    
}

- (void)startOutgoingThread {
    
}

- (void)sendPacket:(SKPacket *)packet {
    
}



@end
