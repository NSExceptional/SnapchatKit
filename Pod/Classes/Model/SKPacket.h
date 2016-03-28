//
//  SKPacket.h
//  Pods
//
//  Created by Tanner on 1/3/16.
//
//

#import <Foundation/Foundation.h>
#import "Mantle.h"


// ts to NSDate transform
#define MTLTransformPropertyDate(property) + (NSValueTransformer *) property##JSONTransformer { \
return [self sk_dateTransformer]; }

typedef NS_ENUM(NSUInteger, SKPacketType)
{
    SKPacketTypeDefault,
    SKPacketTypeConnect,
    SKPacketTypeConnectResponse,
    SKPacketTypeDisconnect,
    SKPacketTypePresence,
    SKPacketTypeMessageState,
    SKPacketTypeMessageRelease,
    SKPacketTypeChatMessage,
    SKPacketTypeError,
    SKPacketTypeProtocolError,
    SKPacketTypeConversationMessageResponse,
    SKPacketTypeSnapState,
    SKPacketTypePing,
    SKPacketTypePingResponse
};

NS_ASSUME_NONNULL_BEGIN

extern NSString * SKStringFromPacketType(SKPacketType);
extern SKPacketType SKPacketTypeFromString(NSString *);


@interface SKPacket : MTLModel <MTLJSONSerializing>

+ (instancetype)packet:(NSDictionary *)json;
+ (instancetype)packetFromData:(NSData *)data;

+ (NSValueTransformer *)sk_dateTransformer;

@property (nonatomic, readonly) NSDictionary *json;
@property (nonatomic, readonly) SKPacketType packetType;
@property (nonatomic, readonly) NSString *type;
@property (nonatomic, readonly) NSString *identifier;

@end
NS_ASSUME_NONNULL_END

