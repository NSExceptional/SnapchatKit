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

//@class SKPacket, SKConnectPacket, SKPresencePacket, SKMessageStatePacket, SKMessagePacket, SKErrorPacket, SKProtocolErrorPacket, SKConversationMessageResponsePacket, SKSnapStatePacket, SKPingResponsePacket;

typedef NSInputStream SKChatInputStream;
typedef NSOutputStream SKChatOutputStream;

@interface SKChatRoom ()

@property (nonatomic) SKChatInputStream  *inputStream;
@property (nonatomic) SKChatOutputStream *outputStream;
@property (nonatomic) NSTimer *inboundTimer;
@property (nonatomic) NSTimer *outboundTimer;

@property (nonatomic) TBQueue<SKPacket*> *outgoingMessages;
@property (nonatomic) NSTimer *presenceTimer;

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

+ (instancetype)chatRoomForConversation:(SKConversation *)convo gatewayAuth:(NSDictionary *)gatewayAuth server:(NSString *)server {
    return [[self alloc] initWithConversation:convo gatewayAuth:gatewayAuth server:server];
}

- (id)initWithConversation:(SKConversation *)convo gatewayAuth:(NSDictionary *)gatewayAuth server:(NSString *)server {
    NSParameterAssert(convo); NSParameterAssert(gatewayAuth[@"mac"] && gatewayAuth[@"payload"]);
    
    self = [super init];
    if (self) {
        // Get server info
        NSArray<NSString*> *parts = [server componentsSeparatedByString:@":"];
        _server = parts[0];
        _port   = parts[1].integerValue;
        
        _user = convo.recipient;
        _recipient = convo.sender;
        
        _conversationMac     = convo.messagingAuth[@"mac"];
        _conversationPayload = convo.messagingAuth[@"payload"];
        _gatewayMac          = gatewayAuth[@"mac"];
        _gatewayPayload      = gatewayAuth[@"payload"];
        
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
        _inputStream  = (__bridge SKChatInputStream *)readStream;
        _outputStream = (__bridge SKChatOutputStream *)writeStream;
        [_inputStream  setProperty:NSStreamSocketSecurityLevelSSLv3 forKey:NSStreamSocketSecurityLevelKey];
        [_outputStream setProperty:NSStreamSocketSecurityLevelSSLv3 forKey:NSStreamSocketSecurityLevelKey];
        [_inputStream  scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        [_outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        [_inputStream  open];
        [_outputStream open];
        
        [self startInboundThread];
        [self startOutboundThread];
        
        [self sendConnectMessage];
    });
}

- (void)leaveRoom {
    [self shutdown:YES];
    // notify delegate
}

- (void)sendConnectMessage {
    SKConnectPacket *connected = [SKConnectPacket withUsername:self.user auth:@{@"mac": _gatewayMac, @"payload": _gatewayPayload}];
    [self sendPacket:connected];
}

- (void)shutdown:(BOOL)forGood {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self.outgoingMessages clear];
        self.sendPresence = NO;
        
        // Interrupt presence, cancel packet listeners, close sockets
        if (forGood) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [self sendPresenceStatePacketPresent:NO];
                [self.inboundTimer invalidate];
                [self.outboundTimer invalidate];
                [self.inputStream close];
                [self.outputStream close];
            });
        }
    });
}

#pragma mark Packets and listeners

- (NSTimer *)presenceTimer {
    if (!_presenceTimer) {
        _presenceTimer = [NSTimer timerWithTimeInterval:6 target:self selector:@selector(sendPresnceStatePacket) userInfo:nil repeats:YES];
    }
    
    return _presenceTimer;
}

- (void)startInboundThread {
    self.inboundTimer = [NSTimer timerWithTimeInterval:.01 target:self selector:@selector(inboundListener) userInfo:nil repeats:YES];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[NSRunLoop mainRunLoop] addTimer:self.inboundTimer forMode:NSDefaultRunLoopMode];
    });
}

- (void)startOutboundThread {
    self.outboundTimer = [NSTimer timerWithTimeInterval:.01 target:self selector:@selector(outboundListener) userInfo:nil repeats:YES];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[NSRunLoop mainRunLoop] addTimer:self.outboundTimer forMode:NSDefaultRunLoopMode];
    });
}

- (void)inboundListener {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        SKPacket *packet = [self.inputStream recievePacket];
        if (packet) {
            [self packetRecieved:packet];
        }
    });
}

- (void)outboundListener {
    if (self.outgoingMessages.count) {
        SKPacket *packet = [self.outgoingMessages take];
        [self.outputStream sendPacket:packet];
    }
}

- (void)sendPacket:(SKPacket *)packet {
    [self.outgoingMessages enqueue:packet];
}

- (void)packetRecieved:(SKPacket *)packet {
    if (packet.packetType == SKPacketTypeConnectResponse) {
        SKConnectResponsePacket *connectResponse = (id)packet;
        
        if (connectResponse.successful) {
            self.sendPresence = YES;
            // Connected, notify delegate
        }
        else if ([connectResponse.failureReason isEqualToString:@"wrong_server"]) {
            NSLog(@"Wrong server: %@, switching to %@", self.server, connectResponse.alternateServer);
            
            // Pause, reset server
            [self shutdown:NO];
            NSArray<NSString*> *parts = [connectResponse.alternateServer componentsSeparatedByString:@":"];
            _server = parts[0];
            _port   = parts[1].integerValue;
            
            // Reconnect
            [self enterRoom];
        } else if ([connectResponse.failureReason isEqualToString:@"authentication_failure"]) {
            NSLog(@"Failed to authenticate for chat");
            // Notify delegate
        }
    } else if (packet.packetType == SKPacketTypeDisconnect) {
        [self leaveRoom];
    }
    
    NSLog(@"Packet recieved:\n%@\n", packet);
    // Notify delegate
}

#pragma mark Presence

- (void)setSendPresence:(BOOL)sendPresence {
    if (_sendPresence == sendPresence) return;
    _sendPresence = sendPresence;
    
    if (!sendPresence) {
        self.presenceTimer = nil;
    } else {
        [[NSRunLoop mainRunLoop] addTimer:self.presenceTimer forMode:NSDefaultRunLoopMode];
        [self.presenceTimer fire];
    }
}

- (void)sendPresnceStatePacket {[self sendPresenceStatePacketPresent:YES]; }

- (void)sendPresenceStatePacketPresent:(BOOL)present {
    SKPresencePacket *presence = [SKPresencePacket presences:@{_recipient: @(present), _user: @(present)}
                                                       video:NO to:@[_recipient] from:_user auth:@{@"mac": _conversationMac, @"payload": _conversationPayload}];
    [self sendPacket:presence];
}


@end























