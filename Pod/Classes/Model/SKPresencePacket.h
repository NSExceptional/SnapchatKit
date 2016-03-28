//
//  SKPresencePacket.h
//  Pods
//
//  Created by Tanner on 1/3/16.
//
//

#import "SKConversationMessagePacket.h"


@interface SKPresencePacket : SKConversationMessagePacket

+ (instancetype)presences:(NSDictionary *)presences video:(BOOL)video to:(NSArray *)to from:(NSString *)from auth:(NSString *)auth;

@property (nonatomic, readonly) NSDictionary *hereAuth;
@property (nonatomic, readonly) NSDictionary<NSString*, NSNumber*> *presences;
@property (nonatomic, readonly) BOOL receivingVideo;
@property (nonatomic, readonly) BOOL supportsHere;

@end
