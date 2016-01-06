//
//  SKConversationState.h
//  Pods
//
//  Created by Tanner on 1/6/16.
//
//

#import "SKThing.h"


/**
 Keys:
 
 - "user_chat_releases"
 Contains a dictionary with keys for each participant,
 mapping the number of messages from each participant, as
 they see it. So if Bob sends Sally a message and Sally hasn't
 read it, state["user_chat_releases"]["Sally"]["Bob"] will
 be one less than state["user_chat_releases"]["Bob"]["Sally"],
 because Sally has not read it yet but Bob can see it.
 
 - "user_sequences"
 A dictionary with keys for each participant, mapping
 the total number of messages and snaps sent by that user.
 
 - "user_snap_releases"
 Same as "user_chat_releases" but with timestamps. Might just be for snaps.
 */
@interface SKConversationState : SKThing

+ (instancetype)state:(NSDictionary *)json recipient:(NSString *)recipient;

@property (nonatomic, readonly) NSUInteger recipientUnreadCount;
@property (nonatomic, readonly) NSUInteger senderUnreadCount;

@property (nonatomic, readonly) NSUInteger recipientSentCount;
@property (nonatomic, readonly) NSUInteger senderSentCount;

@end
