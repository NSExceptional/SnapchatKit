//
//  SKConversationMessageResponsePacket.h
//  Pods
//
//  Created by Tanner on 1/3/16.
//
//

#import "SKPacket.h"

@interface SKConversationMessageResponsePacket : SKPacket

@property (nonatomic, readonly) NSString *ACKIdentifier;
@property (nonatomic, readonly) NSString *conversationIdentifier;
@property (nonatomic, readonly) NSString *failureReason;
@property (nonatomic, readonly) BOOL successful;
@property (nonatomic, readonly) NSDate *timestamp;

@end
