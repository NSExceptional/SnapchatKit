//
//  SKPacket.h
//  Pods
//
//  Created by Tanner on 1/3/16.
//
//

#import <Foundation/Foundation.h>
#import "Mantle.h"


typedef NS_ENUM(NSUInteger, SKPacketType)
{
    SKPacketTypeDefault,
    SKPacketTypeConnectResponse,
    SKPacketTypePresence,
    SKPacketTypeMessageState,
    SKPacketTypeMessageRelease,
    SKPacketTypeChatMessage,
    SKPacketTypeError,
    SKPacketTypeProtocolError,
    SKPacketTypeConversationMessageResponse,
    SKPacketTypeSnapState,
    SKPacketTypePingResponse
};

NS_ASSUME_NONNULL_BEGIN

extern NSString * SKStringFromPacketType(SKPacketType);
extern SKPacketType SKPacketTypeFromString(NSString *);


@interface SKPacket : MTLModel <MTLJSONSerializing>

+ (instancetype)packet:(NSDictionary *)json;

@property (nonatomic, readonly) NSString *type;
@property (nonatomic, readonly) NSString *identifier;

@end
NS_ASSUME_NONNULL_END

