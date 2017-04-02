//
//  SKChatRoom.h
//  Pods
//
//  Created by Tanner on 1/3/16.
//
//

#import <Foundation/Foundation.h>
#import "SKConversation.h"

#define VALIDATE_CERTIFICATES 1


@interface SKChatRoom : NSObject

/// @param gatewayAuth See SKSession.messagingGatewayAuth
+ (instancetype)chatRoomForConversation:(SKConversation *)convo gatewayAuth:(NSDictionary *)gatewayAuth server:(NSString *)server;

- (void)enterRoom;
- (void)leaveRoom;

@property (nonatomic) BOOL sendPresence;

@end
