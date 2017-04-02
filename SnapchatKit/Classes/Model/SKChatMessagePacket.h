//
//  SKChatMessagePacket.h
//  Pods
//
//  Created by Tanner on 1/6/16.
//
//

#import "SKConversationMessagePacket.h"


@interface SKChatMessagePacket : SKConversationMessagePacket

@property (nonatomic, readonly) NSString     *text;
@property (nonatomic, readonly) NSDictionary *media;
@property (nonatomic, readonly) NSString     *messageType;
@property (nonatomic, readonly) NSArray<NSDictionary*> *attributes;

@property (nonatomic, readonly) NSString     *chatMessageIdentifier;
@property (nonatomic, readonly) NSDictionary *state;
@property (nonatomic, readonly) NSInteger    sequenceNumber;
@property (nonatomic, readonly) NSDate       *timestamp;

@end
