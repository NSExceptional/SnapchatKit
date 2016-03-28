//
//  SKConversationMessagePacket.h
//  Pods
//
//  Created by Tanner on 3/25/16.
//
//

#import "SKPacket.h"

@interface SKConversationMessagePacket : SKPacket

/// mac, payload
@property (nonatomic, readonly) NSDictionary *auth;
@property (nonatomic, readonly) NSInteger connSequenceNumber;
@property (nonatomic, readonly) NSString *header_conversationIdentifier;
@property (nonatomic, readonly) NSString *from;
@property (nonatomic, readonly) NSArray<NSString*> *to;
@property (nonatomic, readonly) BOOL retried;

@property (nonatomic, readonly) BOOL canSendOverHTTP;
@property (nonatomic, readonly) BOOL needsACK;

@end
