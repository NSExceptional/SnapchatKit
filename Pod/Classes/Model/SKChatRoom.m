//
//  SKChatRoom.m
//  Pods
//
//  Created by Tanner on 1/3/16.
//
//

#import "SKChatRoom.h"
#import "NSDictionary+Networking.h"
#import "SKChatInputStream.h"
#import "SKChatOutputStream.h"
#import "TBQueue.h"
#import "GCDAsyncSocket.h"

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

NSInteger const kConnectMessageTag = &kConnectMessageTag;
NSInteger const kLengthTag = &kLengthTag;

//@class SKPacket, SKConnectPacket, SKPresencePacket, SKMessageStatePacket, SKMessagePacket, SKErrorPacket, SKProtocolErrorPacket, SKConversationMessageResponsePacket, SKSnapStatePacket, SKPingResponsePacket;

typedef NSInputStream SKChatInputStream;
typedef NSOutputStream SKChatOutputStream;

@interface SKChatRoom () <NSStreamDelegate, GCDAsyncSocketDelegate>

@property (nonatomic) SKChatInputStream  *inputStream;
@property (nonatomic) SKChatOutputStream *outputStream;
@property (nonatomic) GCDAsyncSocket *socket;
@property (nonatomic) NSTimer *outboundTimer;

@property TBQueue<SKPacket*> *outgoingMessages;
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
    
    NSLog(@"Connecting to host...");
    
    // Init I/O streams
    NSError *connectError = nil;
    self.socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    [self.socket connectToHost:_server onPort:_port withTimeout:5 error:&connectError];
    
    if (connectError) {
        // notify delegate
        NSLog(@"%@", connectError.localizedDescription);
    }
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
                [self.outboundTimer invalidate];
                self.socket = nil;
            });
        }
    });
}

#pragma mark Socket delegate

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port {
    NSLog(@"Connected to host. Starting TLS...");
    // Backgrouding on iOS
#if __has_include(<UIKit/UIApplication.h>)
    [self.socket performBlock:^{
        [self.socket enableBackgroundingOnSocket];
    }];
#endif
    
    [self.socket startTLS:@{GCDAsyncSocketSSLProtocolVersionMin: @2}];
}

// Not ever called so far
- (void)socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket {
    self.socket = sock;
}

- (void)socketDidSecure:(GCDAsyncSocket *)sock {
    NSLog(@"Connection complete.");
    self.outboundTimer = [NSTimer scheduledTimerWithTimeInterval:.8 target:self selector:@selector(outboundListener) userInfo:nil repeats:YES];
    [self sendConnectMessage];
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)error {
    if (error) {
        // notify delegate
        NSLog(@"Disconnected: %@", error.localizedDescription);
    }
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    if (tag == kLengthTag) {
        // Get length, read packet
        int length = NSSwapInt(*(int*)(data.bytes));
        [self.socket readDataToLength:length withTimeout:-1 tag:kLengthTag];
        
        NSLog(@"Read length: %@", @(length));
    } else if (tag == 0) {
        // Packet read, read next length
        [self packetRecieved:[SKPacket packetFromData:data]];
        [self.socket readDataToLength:4 withTimeout:-1 tag:kLengthTag];
    }
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag {
    if (tag == kConnectMessageTag) {
        NSLog(@"Sent connect message. Reading data...");
        // Begin reading length
        [self.socket readDataToLength:4 withTimeout:-1 tag:kLengthTag];
    }
    // notify delegate
}

#pragma mark Packets and listeners

- (NSTimer *)presenceTimer {
    if (!_presenceTimer) {
        _presenceTimer = [NSTimer timerWithTimeInterval:6 target:self selector:@selector(sendPresnceStatePacket) userInfo:nil repeats:YES];
    }
    
    return _presenceTimer;
}

- (void)outboundListener {
    if (self.outgoingMessages.count) {
        SKPacket *packet = [self.outgoingMessages take];
        
        // Write packet with type tag
        if (packet.packetType == SKPacketTypeConnect) {
            NSLog(@"Sending connect message...");
            [self.socket writeData:[packet.json.JSONString dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:kConnectMessageTag];
        } else {
            NSLog(@"Sending some packet...");
            [self.socket writeData:[packet.json.JSONString dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:0];
        }
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

- (void)sendPresnceStatePacket { [self sendPresenceStatePacketPresent:YES]; }

- (void)sendPresenceStatePacketPresent:(BOOL)present {
    // Comment this return out and the input stream
    // never notifies its delegate of hasBytesAvailable
    return;
    SKPresencePacket *presence = [SKPresencePacket presences:@{_recipient: @(present), _user: @(present)}
                                                       video:NO to:@[_recipient] from:_user
                                                        auth:@{@"mac": _conversationMac, @"payload": _conversationPayload}];
    [self sendPacket:presence];
}

@end























