//
//  SKMessageStatePacket.h
//  Pods
//
//  Created by Tanner on 1/3/16.
//
//

#import "SKConversationMessagePacket.h"


@interface SKMessageStatePacket : SKConversationMessagePacket

@property (nonatomic, readonly) NSString *chatMessageIdentifier;
@property (nonatomic, readonly) NSString *state;
@property (nonatomic, readonly) NSInteger version;

@end
