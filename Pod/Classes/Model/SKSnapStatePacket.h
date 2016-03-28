//
//  SKSnapStatePacket.h
//  Pods
//
//  Created by Tanner on 1/3/16.
//
//

#import "SKConversationMessagePacket.h"


@interface SKSnapStatePacket : SKConversationMessagePacket

@property (nonatomic, readonly) NSString *snapIdentifier;
@property (nonatomic, readonly) NSInteger screenshotCount;
@property (nonatomic, readonly) BOOL replayed;
@property (nonatomic, readonly) BOOL opened;
@property (nonatomic, readonly) NSDate *timestamp;

@end
