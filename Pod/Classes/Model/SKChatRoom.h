//
//  SKChatRoom.h
//  Pods
//
//  Created by Tanner on 1/3/16.
//
//

#import <Foundation/Foundation.h>
#import "SKConversation.h"


@interface SKChatRoom : NSObject

+ (instancetype)chatRoomForConversation:(SKConversation *)convo messagingGatewayAuth:(NSDictionary *)gatewayAuth;

- (void)enterRoom;
- (void)leaveRoom;

@property (nonatomic) BOOL sendPresence;

@end
